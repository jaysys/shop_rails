class ProductReview < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :content, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :product_id }
end
