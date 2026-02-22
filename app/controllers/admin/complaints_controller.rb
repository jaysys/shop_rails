module Admin
  class ComplaintsController < BaseController
    before_action :set_complaint, only: %i[show update]

    def index
      @status = params[:status].to_s
      @complaints = Complaint.includes(:user, :order).order(created_at: :desc)
      @complaints = @complaints.where(status: @status) if Complaint::STATUSES.include?(@status)
    end

    def show
    end

    def update
      prev_status = @complaint.status
      prev_reply = @complaint.admin_reply.to_s
      attrs = admin_complaint_params
      attrs[:resolved_at] = Time.current if attrs[:status] == "resolved"
      attrs[:resolved_at] = nil if attrs[:status].present? && attrs[:status] != "resolved"

      if @complaint.update(attrs)
        notify_user_if_changed(@complaint, prev_status:, prev_reply:)
        redirect_to admin_complaint_path(@complaint), notice: "문의 처리 상태를 업데이트했습니다.", status: :see_other
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_complaint
      @complaint = Complaint.includes(:user, :order).find(params.expect(:id))
    end

    def admin_complaint_params
      params.expect(complaint: [:status, :admin_reply])
    end

    def notify_user_if_changed(complaint, prev_status:, prev_reply:)
      changed = complaint.status != prev_status || complaint.admin_reply.to_s != prev_reply
      return unless changed

      Notification.create!(
        user: complaint.user,
        complaint: complaint,
        kind: "complaint_updated",
        message: "문의 ##{complaint.id} 처리 상태가 '#{complaint.status_label}'로 변경되었습니다."
      )
    end
  end
end
