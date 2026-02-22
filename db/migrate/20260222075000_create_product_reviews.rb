class CreateProductReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :product_reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end

    add_index :product_reviews, [:user_id, :product_id], unique: true
    add_index :product_reviews, :created_at
  end
end
