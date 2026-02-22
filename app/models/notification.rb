class Notification < ApplicationRecord
  KINDS = %w[complaint_submitted complaint_updated].freeze

  belongs_to :user
  belongs_to :complaint, optional: true

  validates :kind, presence: true, inclusion: { in: KINDS }
  validates :message, presence: true, length: { maximum: 255 }

  scope :recent_first, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end
end
