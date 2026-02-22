module Admin
  class OrdersController < BaseController
    def show
      @order = Order.includes(:order_items, :user).find(params.expect(:id))
      @order_items = @order.order_items.order(:id)
    end
  end
end
