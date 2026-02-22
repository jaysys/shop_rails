class NotifyStaleComplaintsJob < ApplicationJob
  queue_as :default

  def perform
    threshold_hours = ENV.fetch("COMPLAINT_STALE_HOURS", "24").to_i
    cutoff_time = threshold_hours.hours.ago

    stale_complaints = Complaint
      .includes(:user, :order)
      .where(status: "submitted")
      .where("created_at <= ?", cutoff_time)
      .order(created_at: :asc)
      .limit(200)

    return if stale_complaints.blank?

    admin_users = User.where(admin: true).where.not(email: [nil, ""])
    return if admin_users.blank?

    recipient_emails = admin_users.pluck(:email).uniq
    AdminComplaintAlertMailer
      .stale_complaints_alert(recipient_emails:, stale_complaints:, cutoff_time:, threshold_hours:)
      .deliver_now

    Rails.logger.info(
      "[ComplaintReminder] sent stale complaint alert recipients=#{recipient_emails.size} complaints=#{stale_complaints.size} cutoff=#{cutoff_time}"
    )
  end
end
