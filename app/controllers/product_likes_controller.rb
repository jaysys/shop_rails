class ProductLikesController < ApplicationController
  before_action :require_login

  def create
    product = Product.find(params.expect(:product_id))
    current_user.product_likes.find_or_create_by(product: product)

    respond_to do |format|
      format.html { redirect_back fallback_location: product_path(product) }
      format.json { render json: { liked: true, like_count: product.product_likes.count } }
    end
  end

  def destroy
    product = Product.find(params.expect(:product_id))
    current_user.product_likes.where(product: product).delete_all

    respond_to do |format|
      format.html { redirect_back fallback_location: product_path(product) }
      format.json { render json: { liked: false, like_count: product.product_likes.count } }
    end
  end
end
