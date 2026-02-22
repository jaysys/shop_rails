class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :complaint, null: true, foreign_key: true
      t.string :kind, null: false
      t.string :message, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :kind
    add_index :notifications, :read_at
    add_index :notifications, :created_at
  end
end
