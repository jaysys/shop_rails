module Admin
  class ProductsController < BaseController
    before_action :load_categories, only: %i[new create edit update]
    before_action :set_product, only: %i[show edit update destroy]

    def index
      @products = Product.includes(:categories).order(created_at: :desc)
    end

    def show
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_product_path(@product), notice: "상품을 등록했습니다."
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "상품을 수정했습니다.", status: :see_other
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @product.destroy!
      redirect_to admin_products_path, notice: "상품을 삭제했습니다.", status: :see_other
    end

    private

    def set_product
      @product = Product.includes(:categories).find(params.expect(:id))
    end

    def product_params
      params.expect(product: [:name, :description, :price, :image, { category_ids: [] }])
    end

    def load_categories
      @categories = Category.order(:name)
    end
  end
end
