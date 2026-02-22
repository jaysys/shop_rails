class CreateProductLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :product_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :product_likes, [:user_id, :product_id], unique: true
    add_index :product_likes, :created_at
  end
end
