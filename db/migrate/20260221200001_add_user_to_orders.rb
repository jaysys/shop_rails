class AddUserToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :user, foreign_key: true
    add_index :orders, [:user_id, :status]
  end
end
