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

ActiveRecord::Schema[7.0].define(version: 2023_01_31_144436) do
  create_table "access_alloweds", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "warehouse_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_access_alloweds_on_user_id"
    t.index ["warehouse_id"], name: "index_access_alloweds_on_warehouse_id"
  end

  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "nit"
    t.string "phone"
    t.string "email"
    t.text "digital_certificate"
    t.text "private_key"
    t.string "municipality"
    t.string "sector_type_document"
    t.string "address"
    t.string "invoice_type"
    t.string "bussiness_type"
    t.string "type_of_taxpayer"
    t.string "economic_activity"
    t.string "social_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "document_number"
    t.string "name"
    t.string "email"
    t.string "type"
    t.string "phone"
    t.bigint "account_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_customers_on_account_id"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "eventable_type", null: false
    t.bigint "eventable_id", null: false
    t.string "name"
    t.string "info"
    t.string "info2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "nit_emitter"
    t.string "name_or_social_reason_emitter"
    t.string "total"
    t.bigint "transaktion_id", null: false
    t.string "municipality"
    t.string "phone"
    t.string "cuf"
    t.string "cufd"
    t.integer "branch_code"
    t.string "direction"
    t.string "point_of_sale_code"
    t.string "date_of_issue"
    t.string "number_facture"
    t.string "name_or_social_reason"
    t.string "identity_document_type_code"
    t.string "document_number"
    t.string "complement"
    t.string "client_code"
    t.string "payment_method_code"
    t.string "card_number"
    t.string "total_amount"
    t.string "total_amount_subject_iva"
    t.string "currency_code"
    t.string "exchange_rate"
    t.string "total_amount_currency"
    t.string "legend"
    t.string "user"
    t.string "sector_document_code"
    t.string "economic_activity"
    t.string "product_code_sin"
    t.string "product_code"
    t.string "description"
    t.string "unit_of_measure"
    t.string "unit_price"
    t.string "discount_amount"
    t.string "sub_total"
    t.string "serial_number"
    t.string "imei_number"
    t.string "digest_value"
    t.string "signature_value"
    t.string "x_509_certificate"
    t.string "x_509_subject_name"
    t.string "x_509_issuer_name"
    t.string "x_509_serial_number"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaktion_id"], name: "index_invoices_on_transaktion_id"
  end

  create_table "item_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "qty"
    t.integer "stock_at"
    t.float "sub_total"
    t.bigint "item_id", null: false
    t.bigint "transaktion_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_transactions_on_item_id"
    t.index ["transaktion_id"], name: "index_item_transactions_on_transaktion_id"
  end

  create_table "items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "warehouse_id", null: false
    t.bigint "product_id", null: false
    t.string "code"
    t.integer "total_stock"
    t.integer "quantity"
    t.integer "min_stock"
    t.integer "max_stock"
    t.float "list_price"
    t.float "sale_price_unit"
    t.float "sale_price_package"
    t.float "purchase_cost_unit"
    t.float "purchase_cost_package"
    t.date "expiration_date"
    t.date "date_of_elaboration"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_items_on_product_id"
    t.index ["warehouse_id"], name: "index_items_on_warehouse_id"
  end

  create_table "pos_sessions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "warehouse_id", null: false
    t.float "petty_cash"
    t.string "observation"
    t.string "type_of_currency"
    t.integer "status", default: 0
    t.integer "user_id", null: false
    t.float "total_balance"
    t.float "initial_balance", default: 0.0
    t.float "missing_money"
    t.float "remaining_money"
    t.float "total_income"
    t.float "total_expenses"
    t.float "total_session"
    t.json "total_payment_methods"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["warehouse_id"], name: "index_pos_sessions_on_warehouse_id"
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "presentation"
    t.string "code"
    t.string "alternative_code"
    t.string "trademark"
    t.string "characteristics"
    t.string "model_rrss"
    t.string "generic_name"
    t.string "unit"
    t.string "package"
    t.string "category"
    t.string "sub_category"
    t.integer "total_unit", default: 1
    t.integer "customer_id"
    t.integer "account_id"
    t.string "import_id"
    t.string "industry"
    t.boolean "controled"
    t.boolean "taxes"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "permissions"
    t.integer "account_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transaktions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "pos_session_id", null: false
    t.string "type_transaktion"
    t.float "total"
    t.string "description"
    t.float "money_received"
    t.float "money_returned"
    t.string "payment_method"
    t.string "code"
    t.string "discount"
    t.float "money_paid"
    t.integer "destination_warehouse_id"
    t.integer "receiver_pos_session_id"
    t.date "date_of_payment"
    t.integer "invoice_number"
    t.integer "receipt_number"
    t.integer "customer_received_money_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_transaktions_on_customer_id"
    t.index ["pos_session_id"], name: "index_transaktions_on_pos_session_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "account_id"
    t.bigint "role_id"
    t.string "name"
    t.string "last_name"
    t.string "ci"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "warehouse_details", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "address"
    t.bigint "warehouse_id"
    t.string "municipality"
    t.integer "branch_code"
    t.string "nit"
    t.string "cuis"
    t.string "cufd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["warehouse_id"], name: "index_warehouse_details_on_warehouse_id"
  end

  create_table "warehouses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "account_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_warehouses_on_account_id"
  end

  add_foreign_key "access_alloweds", "users"
  add_foreign_key "access_alloweds", "warehouses"
  add_foreign_key "invoices", "transaktions"
  add_foreign_key "item_transactions", "items"
  add_foreign_key "item_transactions", "transaktions"
  add_foreign_key "items", "products"
  add_foreign_key "items", "warehouses"
  add_foreign_key "pos_sessions", "warehouses"
  add_foreign_key "transaktions", "customers"
  add_foreign_key "transaktions", "pos_sessions"
end
