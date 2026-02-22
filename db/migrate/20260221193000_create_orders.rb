class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.string :order_id, null: false
      t.string :cart_token, null: false
      t.string :order_name, null: false
      t.integer :amount, null: false
      t.string :status, null: false, default: "pending"
      t.string :payment_key
      t.json :payment_payload

      t.timestamps
    end

    add_index :orders, :order_id, unique: true
    add_index :orders, :cart_token
    add_index :orders, :status
  end
end
