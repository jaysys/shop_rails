class Complaint < ApplicationRecord
  STATUSES = %w[submitted in_progress resolved rejected].freeze
  STATUS_LABELS = {
    "submitted" => "접수됨",
    "in_progress" => "처리중",
    "resolved" => "해결",
    "rejected" => "반려"
  }.freeze

  belongs_to :user
  belongs_to :order, optional: true
  has_one_attached :attachment

  validates :title, presence: true, length: { maximum: 180 }
  validates :content, presence: true, length: { maximum: 5000 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  def status_label
    STATUS_LABELS.fetch(status, status)
  end
end
