class CartItem < ApplicationRecord
  belongs_to :product

  validates :cart_token, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  def subtotal
    product.price * quantity
  end
end
