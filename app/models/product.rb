class Product < ApplicationRecord
  has_many :cart_items, dependent: :restrict_with_error
  has_many :categorizations, dependent: :destroy
  has_many :categories, through: :categorizations
  has_many :product_reviews, dependent: :destroy
  has_many :product_likes, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, length: { maximum: 120 }
  validates :description, presence: true
  validates :price, numericality: { greater_than: 0 }
end
