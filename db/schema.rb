# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_22_075010) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.string "cart_token", null: false
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["cart_token", "product_id"], name: "index_cart_items_on_cart_token_and_product_id", unique: true
    t.index ["product_id"], name: "index_cart_items_on_product_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorizations_on_category_id"
    t.index ["product_id", "category_id"], name: "index_categorizations_on_product_id_and_category_id", unique: true
    t.index ["product_id"], name: "index_categorizations_on_product_id"
  end

  create_table "complaints", force: :cascade do |t|
    t.text "admin_reply"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "order_id"
    t.datetime "resolved_at"
    t.string "status", default: "submitted", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_complaints_on_created_at"
    t.index ["order_id"], name: "index_complaints_on_order_id"
    t.index ["status"], name: "index_complaints_on_status"
    t.index ["user_id"], name: "index_complaints_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "complaint_id"
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.string "message", null: false
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["complaint_id"], name: "index_notifications_on_complaint_id"
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["kind"], name: "index_notifications_on_kind"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.bigint "product_id"
    t.string "product_name", null: false
    t.integer "quantity", null: false
    t.decimal "subtotal", precision: 10, scale: 2, null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "amount", null: false
    t.string "cart_token", null: false
    t.datetime "created_at", null: false
    t.string "order_id", null: false
    t.string "order_name", null: false
    t.string "payment_key"
    t.json "payment_payload"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["cart_token"], name: "index_orders_on_cart_token"
    t.index ["order_id"], name: "index_orders_on_order_id", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id", "status"], name: "index_orders_on_user_id_and_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_product_likes_on_created_at"
    t.index ["product_id"], name: "index_product_likes_on_product_id"
    t.index ["user_id", "product_id"], name: "index_product_likes_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_likes_on_user_id"
  end

  create_table "product_reviews", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["created_at"], name: "index_product_reviews_on_created_at"
    t.index ["product_id"], name: "index_product_reviews_on_product_id"
    t.index ["user_id", "product_id"], name: "index_product_reviews_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_reviews_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "products"
  add_foreign_key "categorizations", "categories"
  add_foreign_key "categorizations", "products"
  add_foreign_key "complaints", "orders"
  add_foreign_key "complaints", "users"
  add_foreign_key "notifications", "complaints"
  add_foreign_key "notifications", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "users"
  add_foreign_key "product_likes", "products"
  add_foreign_key "product_likes", "users"
  add_foreign_key "product_reviews", "products"
  add_foreign_key "product_reviews", "users"
end
