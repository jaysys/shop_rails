class OrdersController < ApplicationController
  before_action :require_login
  before_action :set_order, only: :show

  def index
    @orders = current_user.orders.where(status: "paid").order(created_at: :desc)
  end

  def show
    @order_items = @order.order_items.order(:id)

    respond_to do |format|
      format.html
      format.pdf do
        pdf_data = OrderReceiptPdf.new(order: @order, order_items: @order_items).render
        disposition = params[:disposition] == "inline" ? "inline" : "attachment"
        send_data pdf_data,
                  filename: "order-#{@order.order_id}.pdf",
                  type: "application/pdf",
                  disposition: disposition
      end
    end
  end

  private

  def set_order
    @order = current_user.orders.find_by!(id: params.expect(:id), status: "paid")
  end
end
