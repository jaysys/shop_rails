class Order < ApplicationRecord
  STATUSES = %w[pending paid failed expired].freeze

  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :complaints, dependent: :nullify

  validates :order_id, presence: true, uniqueness: true
  validates :cart_token, presence: true
  validates :order_name, presence: true
  validates :amount, numericality: { greater_than: 0, only_integer: true }
  validates :status, inclusion: { in: STATUSES }

  def paid?
    status == "paid"
  end
end
