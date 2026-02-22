class CartItemsController < ApplicationController
  before_action :set_cart_item, only: %i[update destroy]

  def create
    product = Product.find(params.expect(:product_id))
    quantity = [params[:quantity].to_i, 1].max

    cart_item = CartItem.find_or_initialize_by(cart_token: current_cart_token, product: product)
    cart_item.quantity = cart_item.new_record? ? quantity : cart_item.quantity + quantity

    if cart_item.save
      redirect_back fallback_location: products_path, notice: "장바구니에 추가했습니다."
    else
      redirect_back fallback_location: products_path, alert: cart_item.errors.full_messages.to_sentence
    end
  end

  def update
    quantity = params.expect(cart_item: [:quantity])[:quantity].to_i

    if quantity <= 0
      @cart_item.destroy!
      redirect_to cart_path, notice: "상품을 장바구니에서 제거했습니다.", status: :see_other
      return
    end

    if @cart_item.update(quantity: quantity)
      redirect_to cart_path, notice: "수량을 변경했습니다.", status: :see_other
    else
      redirect_to cart_path, alert: @cart_item.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def destroy
    @cart_item.destroy!
    redirect_to cart_path, notice: "상품을 장바구니에서 제거했습니다.", status: :see_other
  end

  private

  def set_cart_item
    @cart_item = current_cart_items.find_by!(id: params.expect(:id))
  end
end
