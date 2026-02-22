class ProductReviewsController < ApplicationController
  before_action :require_login

  def create
    product = Product.find(params.expect(:product_id))

    unless purchased_product?(product)
      redirect_to product_path(product), alert: "해당 상품을 구매한 사용자만 리뷰를 작성할 수 있습니다."
      return
    end

    review = current_user.product_reviews.new(product: product, content: review_params[:content])

    if review.save
      redirect_to product_path(product), notice: "리뷰가 등록되었습니다."
    else
      redirect_to product_path(product), alert: review.errors.full_messages.join(", ")
    end
  end

  private

  def review_params
    params.expect(product_review: [:content])
  end

  def purchased_product?(product)
    current_user.orders
                .where(status: "paid")
                .joins(:order_items)
                .where("order_items.product_id = ? OR order_items.product_name = ?", product.id, product.name)
                .exists?
  end
end
