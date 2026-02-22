class CreateComplaints < ActiveRecord::Migration[8.1]
  def change
    create_table :complaints do |t|
      t.references :user, null: false, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :status, null: false, default: "submitted"
      t.text :admin_reply
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :complaints, :status
    add_index :complaints, :created_at
  end
end
