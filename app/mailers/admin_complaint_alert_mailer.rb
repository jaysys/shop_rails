class AdminComplaintAlertMailer < ApplicationMailer
  def stale_complaints_alert(recipient_emails:, stale_complaints:, cutoff_time:, threshold_hours:)
    @stale_complaints = stale_complaints
    @cutoff_time = cutoff_time
    @threshold_hours = threshold_hours
    @admin_url = begin
      Rails.application.routes.url_helpers.admin_complaints_url(host: mailer_host)
    rescue StandardError
      nil
    end

    mail(
      to: recipient_emails,
      subject: "[ShopRails] 접수 상태 문의 #{@stale_complaints.size}건 알림",
      reply_to: ENV.fetch("MAIL_REPLY_TO")
    )
  end

  private

  def mailer_host
    ENV["APP_HOST"].presence || "localhost:3000"
  end
end
