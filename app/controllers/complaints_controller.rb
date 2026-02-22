class ComplaintsController < ApplicationController
  before_action :require_login
  before_action :set_complaint, only: :show

  def index
    @complaints = current_user.complaints.includes(:order).order(created_at: :desc)
  end

  def new
    @complaint = current_user.complaints.new
    @orders = current_user.orders.where(status: "paid").order(updated_at: :desc)
  end

  def create
    attrs = complaint_params.to_h
    order_id = attrs.delete("order_id")
    @complaint = current_user.complaints.new(attrs)
    @complaint.order = current_user.orders.where(status: "paid").find_by(id: order_id) if order_id.present?
    @orders = current_user.orders.where(status: "paid").order(updated_at: :desc)

    if @complaint.save
      notify_admins_for_new_complaint(@complaint)
      redirect_to complaint_path(@complaint), notice: "문의가 접수되었습니다."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
  end

  private

  def set_complaint
    @complaint = current_user.complaints.includes(:order).find(params.expect(:id))
  end

  def complaint_params
    params.expect(complaint: [:order_id, :title, :content, :attachment])
  end

  def notify_admins_for_new_complaint(complaint)
    User.where(admin: true).find_each do |admin_user|
      Notification.create!(
        user: admin_user,
        complaint: complaint,
        kind: "complaint_submitted",
        message: "새 문의가 접수되었습니다. ##{complaint.id} #{complaint.title}"
      )
    end
  end
end
