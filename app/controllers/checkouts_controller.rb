class CheckoutsController < ApplicationController
  before_action :require_login
  before_action :load_cart_items, only: :show

  def show
    if @cart_items.empty?
      redirect_to cart_path, alert: "장바구니가 비어 있습니다."
      return
    end

    @total_amount = @cart_items.sum { |item| item.subtotal }.to_i
    @order = find_or_create_pending_order(@total_amount)
    @client_key = ENV["TOSS_API_CLIENT_KEY"].to_s.strip
    @customer_key = current_cart_token
    @client_key_type = detect_client_key_type(@client_key)

    Rails.logger.info("[TossCheckout] key_type=#{@client_key_type} key_preview=#{masked_key(@client_key)} order_id=#{@order.order_id}")

    if @client_key.blank?
      flash.now[:alert] = "TOSS_API_CLIENT_KEY가 비어 있습니다. .env에 API 개별 연동 클라이언트 키(ck)를 설정하세요."
      @client_key = nil
    elsif @client_key_type != "api_individual_client"
      flash.now[:alert] = "결제창 SDK에는 API 개별 연동 클라이언트 키(ck)를 사용하세요. 결제위젯 키(gck)는 지원하지 않습니다."
      @client_key = nil
    end
  end

  def success
    payment_key = params[:paymentKey].to_s
    order_id = params[:orderId].to_s
    amount = params[:amount].to_i

    Rails.logger.info("[TossCheckout] success_callback order_id=#{order_id} amount=#{amount} payment_key_preview=#{masked_key(payment_key)}")

    if payment_key.blank? || order_id.blank? || amount <= 0
      Rails.logger.warn("[TossCheckout] invalid_success_params order_id=#{order_id} amount=#{amount}")
      redirect_to cart_path, alert: "결제 승인 파라미터가 올바르지 않습니다."
      return
    end

    @order = current_user.orders.find_by(order_id: order_id, cart_token: current_cart_token)
    unless @order
      Rails.logger.warn("[TossCheckout] order_not_found order_id=#{order_id} cart_token=#{current_cart_token}")
      redirect_to cart_path, alert: "주문을 찾을 수 없습니다."
      return
    end

    if @order.paid?
      redirect_to cart_path, notice: "이미 결제 완료된 주문입니다."
      return
    end

    if @order.amount != amount
      @order.update(status: "failed")
      Rails.logger.warn("[TossCheckout] amount_mismatch order_id=#{order_id} expected=#{@order.amount} actual=#{amount}")
      redirect_to cart_path, alert: "결제 금액 검증에 실패했습니다."
      return
    end

    result = TossPaymentsClient.new.confirm(payment_key: payment_key, order_id: order_id, amount: amount)

    if result[:ok]
      cart_items = current_cart_items.to_a

      ActiveRecord::Base.transaction do
        @order.update!(status: "paid", payment_key: payment_key, payment_payload: result[:payload])
        @order.order_items.delete_all

        cart_items.each do |item|
          @order.order_items.create!(
            product_id: item.product_id,
            product_name: item.product.name,
            unit_price: item.product.price,
            quantity: item.quantity,
            subtotal: item.subtotal
          )
        end

        current_cart_items.delete_all
      end

      session.delete(:pending_order_id)
      @payment_data = result[:payload]
      Rails.logger.info("[TossCheckout] confirm_success order_id=#{order_id} amount=#{amount} items=#{cart_items.size}")
      render :success_result
    else
      @order.update(status: "failed")
      Rails.logger.error("[TossCheckout] confirm_failed order_id=#{order_id} amount=#{amount} code=#{result[:code]} status=#{result[:http_status]} message=#{result[:error]}")
      redirect_to fail_checkout_path(code: "CONFIRM_FAILED", message: result[:error], orderId: order_id)
    end
  end

  def fail
    @code = params[:code]
    @message = params[:message]
    @order_id = params[:orderId]

    if @order_id.present?
      current_user.orders.where(order_id: @order_id, cart_token: current_cart_token, status: "pending").update_all(status: "failed")
    end

    Rails.logger.warn("[TossCheckout] fail_callback order_id=#{@order_id} code=#{@code} message=#{@message}")
  end

  def client_error
    payload = params[:checkout].presence || params
    order = payload[:order_id].present? ? current_user&.orders&.find_by(order_id: payload[:order_id]) : nil

    Rails.logger.error(
      "[TossCheckout] client_error " \
      "request_id=#{request.request_id} " \
      "ip=#{request.remote_ip} " \
      "method=#{request.request_method} " \
      "path=#{request.fullpath} " \
      "order_id=#{payload[:order_id]} " \
      "order_status=#{order&.status} " \
      "order_amount=#{order&.amount} " \
      "key_type=#{payload[:key_type]} " \
      "stage=#{payload[:stage]} " \
      "name=#{payload[:name]} " \
      "code=#{payload[:code]} " \
      "message=#{payload[:message]} " \
      "page_url=#{payload[:page_url]} " \
      "referrer=#{payload[:referrer]} " \
      "user_agent=#{payload[:user_agent]} " \
      "sdk_loaded=#{payload[:sdk_loaded]} " \
      "amount=#{payload[:amount]} " \
      "currency=#{payload[:currency]} " \
      "error_stack=#{payload[:stack]} " \
      "raw=#{payload[:raw]}"
    )

    head :ok
  end

  private

  def load_cart_items
    @cart_items = current_cart_items.order(created_at: :desc)
  end

  def find_or_create_pending_order(total_amount)
    pending = current_user.orders.find_by(id: session[:pending_order_id], cart_token: current_cart_token, status: "pending")

    return pending if pending && pending.amount == total_amount

    pending&.update(status: "expired")

    order = Order.create!(
      order_id: "order_#{SecureRandom.hex(10)}",
      user: current_user,
      cart_token: current_cart_token,
      order_name: "상품 #{@cart_items.size}건",
      amount: total_amount,
      status: "pending"
    )

    session[:pending_order_id] = order.id
    order
  end

  def widget_client_key?(key)
    key.to_s.include?("_gck_")
  end

  def detect_client_key_type(key)
    return "blank" if key.blank?
    return "widget_client" if key.include?("_gck_")
    return "api_individual_client" if key.include?("_ck_")

    "unknown"
  end

  def masked_key(key)
    return "(blank)" if key.blank?

    "#{key[0, 10]}...#{key[-6, 6]}"
  end
end
