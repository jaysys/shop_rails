class OrderItem < ApplicationRecord
  belongs_to :order

  validates :product_name, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :subtotal, numericality: { greater_than_or_equal_to: 0 }
end
