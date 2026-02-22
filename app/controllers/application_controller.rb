class ApplicationController < ActionController::Base
  # Keep modern-browser enforcement for deployed envs, but allow local development/testing.
  allow_browser versions: :modern, unless: -> { Rails.env.development? || Rails.env.test? }

  helper_method :current_cart_count, :current_user, :logged_in?, :admin?, :unread_notifications_count

  private

  def current_cart_token
    session[:cart_token] ||= SecureRandom.hex(10)
  end

  def current_cart_items
    CartItem.includes(:product).where(cart_token: current_cart_token)
  end

  def current_cart_count
    current_cart_items.sum(:quantity)
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: "로그인이 필요합니다."
  end

  def admin?
    current_user&.admin?
  end

  def require_admin
    return if admin?

    redirect_to root_path, alert: "관리자 권한이 필요합니다."
  end

  def unread_notifications_count
    return 0 unless logged_in?

    current_user.notifications.unread.count
  end
end
