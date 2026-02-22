class CartsController < ApplicationController
  def show
    @cart_items = current_cart_items.order(created_at: :desc)
    @total_amount = @cart_items.sum { |item| item.subtotal }
  end

  def destroy
    current_cart_items.delete_all
    redirect_to cart_path, notice: "장바구니를 비웠습니다."
  end
end
