class ProductsController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @selected_category = Category.find_by(id: params[:category_id])
    @categories = Category.order(:name)
    @products = Product.includes(:categories).order(created_at: :desc)

    if @query.present?
      term = "%#{@query.downcase}%"
      @products = @products.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", term, term)
    end

    if @selected_category
      @products = @products.joins(:categorizations).where(categorizations: { category_id: @selected_category.id }).distinct
    end

    @products = @products.to_a
    product_ids = @products.map(&:id)
    @product_like_counts = ProductLike.where(product_id: product_ids).group(:product_id).count
    @liked_product_ids = if logged_in?
      current_user.product_likes.where(product_id: product_ids).pluck(:product_id)
    else
      []
    end
    @products_by_category = group_products_by_category(@products)
  end

  def show
    @product = Product.includes(:categories, product_reviews: :user).find(params.expect(:id))
    @product_like_count = @product.product_likes.count
    @liked = logged_in? && current_user.product_likes.exists?(product: @product)
    @reviews = @product.product_reviews.order(created_at: :desc)
    @can_review = logged_in? && purchased_product?(@product) && !current_user.product_reviews.exists?(product: @product)
    @my_review = logged_in? ? current_user.product_reviews.find_by(product: @product) : nil
    @review = ProductReview.new
  end

  private

  def purchased_product?(product)
    current_user.orders
                .where(status: "paid")
                .joins(:order_items)
                .where("order_items.product_id = ? OR order_items.product_name = ?", product.id, product.name)
                .exists?
  end

  def group_products_by_category(products)
    if @selected_category
      return { @selected_category => products }
    end

    grouped = {}

    @categories.each do |category|
      items = products.select { |product| product.categories.any? { |c| c.id == category.id } }
      grouped[category] = items if items.any?
    end

    grouped
  end
end
