class NotificationsController < ApplicationController
  before_action :require_login

  def index
    @notifications = current_user.notifications.recent_first
  end

  def update
    notification = current_user.notifications.find(params.expect(:id))
    notification.update(read_at: Time.current) unless notification.read?

    redirect_target = if notification.complaint_id.present?
      if admin?
        admin_complaint_path(notification.complaint_id)
      else
        complaint_path(notification.complaint_id)
      end
    else
      notifications_path
    end

    redirect_to redirect_target, status: :see_other
  end

  def read_all
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "모든 알림을 읽음 처리했습니다.", status: :see_other
  end
end
