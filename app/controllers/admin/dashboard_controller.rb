module Admin
  class DashboardController < BaseController
    def index
      @tab = params[:tab]
      @tab = "users" unless %w[users daily_orders like_stats purchase_stats].include?(@tab)

      if @tab == "users"
        @users = User.order(created_at: :desc)
      elsif @tab == "daily_orders"
        load_daily_orders_data
      elsif @tab == "purchase_stats"
        load_purchase_stats_data
      else
        load_like_stats_data
      end
    end

    private

    def load_daily_orders_data
      apply_date_filters
      paid_orders = build_paid_orders
      paid_orders = paid_orders.order(updated_at: :desc)
      @orders_by_date = paid_orders.group_by { |order| order.updated_at.to_date }

      respond_to do |format|
        format.html
        format.pdf do
          pdf_data = AdminDailyOrdersPdf.new(
            orders_by_date: @orders_by_date,
            from_date: @from_date,
            to_date: @to_date
          ).render

          send_data pdf_data,
                    filename: "admin-daily-orders-#{Time.current.strftime('%Y%m%d-%H%M%S')}.pdf",
                    type: "application/pdf",
                    disposition: "attachment"
        end
      end
    end

    def load_like_stats_data
      @total_likes = ProductLike.count
      @today_likes = ProductLike.where(created_at: Time.zone.today.all_day).count
      @top_liked_products = Product
        .left_joins(:product_likes)
        .select("products.*, COUNT(product_likes.id) AS likes_count")
        .group("products.id")
        .order(Arel.sql("likes_count DESC"), created_at: :desc)
        .limit(15)

      @top_active_users = User
        .left_joins(:product_likes)
        .select("users.*, COUNT(product_likes.id) AS likes_count")
        .group("users.id")
        .order(Arel.sql("likes_count DESC"), created_at: :desc)
        .limit(15)
    end

    def load_purchase_stats_data
      apply_purchase_date_filters

      base_scope = OrderItem
        .joins(:order)
        .joins("INNER JOIN products ON products.id = order_items.product_id")
        .joins("INNER JOIN categorizations ON categorizations.product_id = products.id")
        .joins("INNER JOIN categories ON categories.id = categorizations.category_id")
        .where(orders: { status: "paid" })

      if @purchase_from_date && @purchase_to_date
        base_scope = base_scope.where(orders: { updated_at: @purchase_from_date.beginning_of_day..@purchase_to_date.end_of_day })
      end

      @category_product_stats = base_scope
        .select(
          "categories.id AS category_id, " \
          "categories.name AS category_name, " \
          "products.id AS product_id, " \
          "products.name AS product_name, " \
          "SUM(order_items.quantity) AS total_quantity, " \
          "SUM(order_items.subtotal) AS total_sales, " \
          "COUNT(DISTINCT orders.id) AS order_count"
        )
        .group("categories.id, categories.name, products.id, products.name")
        .order(Arel.sql("total_quantity DESC, total_sales DESC"))

      @category_product_stats_grouped = @category_product_stats.group_by { |row| row.attributes["category_name"] }

      @purchase_summary = {
        orders_count: base_scope.distinct.count("orders.id"),
        total_quantity: @category_product_stats.sum { |row| row.attributes["total_quantity"].to_i },
        total_sales: @category_product_stats.sum { |row| row.attributes["total_sales"].to_f }
      }

      respond_to do |format|
        format.html
        format.pdf do
          pdf_data = AdminPurchaseStatsPdf.new(
            category_product_stats_grouped: @category_product_stats_grouped,
            purchase_summary: @purchase_summary,
            from_date: @purchase_from_date,
            to_date: @purchase_to_date
          ).render

          send_data pdf_data,
                    filename: "admin-purchase-stats-#{Time.current.strftime('%Y%m%d-%H%M%S')}.pdf",
                    type: "application/pdf",
                    disposition: "attachment"
        end
      end
    end

    def build_paid_orders
      paid_orders = Order.includes(:user).where(status: "paid")
      return paid_orders unless @from_date && @to_date

      paid_orders.where(updated_at: @from_date.beginning_of_day..@to_date.end_of_day)
    end

    def apply_date_filters
      @recent_days = params[:recent_days].to_i
      if params[:recent_days].blank? && params[:from_date].blank? && params[:to_date].blank?
        @recent_days = 1
      end

      if @recent_days.positive?
        @to_date = Date.current
        # recent_days=1 => today 00:00:00 ~ today 23:59:59
        @from_date = @to_date - (@recent_days - 1)
      else
        @from_date = parse_date(params[:from_date])
        @to_date = parse_date(params[:to_date])
      end

      if @from_date && @to_date && @from_date > @to_date
        @from_date, @to_date = @to_date, @from_date
      end
    end

    def apply_purchase_date_filters
      @purchase_recent_days = params[:purchase_recent_days].to_i
      if params[:purchase_recent_days].blank? && params[:purchase_from_date].blank? && params[:purchase_to_date].blank?
        @purchase_recent_days = 30
      end

      if @purchase_recent_days.positive?
        @purchase_to_date = Date.current
        @purchase_from_date = @purchase_to_date - (@purchase_recent_days - 1)
      else
        @purchase_from_date = parse_date(params[:purchase_from_date])
        @purchase_to_date = parse_date(params[:purchase_to_date])
      end

      if @purchase_from_date && @purchase_to_date && @purchase_from_date > @purchase_to_date
        @purchase_from_date, @purchase_to_date = @purchase_to_date, @purchase_from_date
      end
    end

    def parse_date(value)
      return nil if value.blank?

      Date.iso8601(value)
    rescue ArgumentError
      nil
    end
  end
end
