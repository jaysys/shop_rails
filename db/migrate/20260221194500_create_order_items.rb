class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.bigint :product_id
      t.string :product_name, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :order_items, :product_id
  end
end
