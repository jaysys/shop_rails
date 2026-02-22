class Category < ApplicationRecord
  has_many :categorizations, dependent: :destroy
  has_many :products, through: :categorizations

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
end
