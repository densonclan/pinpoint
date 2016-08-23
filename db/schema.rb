# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201505061010440) do

  create_table "addresses", :force => true do |t|
    t.string   "title",         :limit => 4, :default => "",  :null => false
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number",               :default => "0"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "business_name"
    t.string   "mobile"
  end

  create_table "addressesbackup", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title",         :limit => 4
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_name"
  end

  create_table "business_managers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "additional_info"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "client_id"
    t.string   "phone_number"
  end

  add_index "business_managers", ["client_id"], :name => "index_business_managers_on_client_id"

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "code"
    t.string   "reference"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "comments", :force => true do |t|
    t.text     "full_text"
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "deliverytemp", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title",         :limit => 4
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_name"
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.string   "short_code"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "distribution_postcodes", :force => true do |t|
    t.integer "distribution_id"
    t.integer "postcode_sector_id"
  end

  create_table "distributions", :force => true do |t|
    t.integer  "total_quantity"
    t.string   "notes"
    t.string   "contract_number"
    t.string   "reference_number"
    t.integer  "order_id"
    t.integer  "distributor_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "updated_by_id"
    t.integer  "distribution_week", :null => false
    t.string   "ship_via"
    t.integer  "address_id"
    t.integer  "publisher_id"
  end

  add_index "distributions", ["distributor_id"], :name => "index_distributions_on_distributor_id"
  add_index "distributions", ["order_id"], :name => "index_distributions_on_order_id"

  create_table "distributors", :force => true do |t|
    t.string   "name"
    t.string   "distributor_type"
    t.text     "description"
    t.string   "reference_number"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "documents", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "store_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "document_type"
  end

  add_index "documents", ["store_id"], :name => "index_documents_on_order_id"
  add_index "documents", ["user_id"], :name => "index_documents_on_user_id"

  create_table "export_templates", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "folders", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "parent_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "folders", ["parent_id"], :name => "index_folders_on_parent_id"
  add_index "folders", ["user_id"], :name => "index_folders_on_user_id"

  create_table "logotypes", :force => true do |t|
    t.string   "title"
    t.string   "reference_number"
    t.string   "file_path"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "updated_by_id"
  end

  create_table "messages", :force => true do |t|
    t.string   "full_text"
    t.string   "subject"
    t.integer  "user_id"
    t.integer  "receiver_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "read",        :default => false, :null => false
    t.datetime "read_at"
    t.boolean  "archived",    :default => false, :null => false
  end

  create_table "newspapertemp", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title",         :limit => 4
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_name"
  end

  create_table "oerders_backup", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "total_quantity"
    t.integer  "total_price"
    t.integer  "distribution_week"
    t.integer  "status"
    t.integer  "user_id"
    t.integer  "store_id"
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "option_id"
    t.integer  "updated_by_id"
    t.integer  "total_boxes"
  end

  create_table "option_values", :force => true do |t|
    t.integer "period_id"
    t.integer "option_id"
    t.integer "page_id"
  end

  create_table "options", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "price_zone"
    t.boolean  "multibuy"
    t.boolean  "licenced"
    t.integer  "total_ambient",    :default => 0
    t.integer  "total_licenced",   :default => 0
    t.integer  "total_temp",       :default => 0
    t.integer  "total_quantity",   :default => 0
    t.string   "reference_number"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "client_id"
  end

  create_table "options_backup_120614", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "name"
    t.string   "description"
    t.string   "price_zone"
    t.boolean  "multibuy"
    t.boolean  "licenced"
    t.integer  "total_ambient"
    t.integer  "total_licenced"
    t.integer  "total_temp"
    t.integer  "total_quantity"
    t.string   "reference_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_id"
  end

  create_table "order_exceptions", :force => true do |t|
    t.integer "period_id"
    t.integer "order_id"
  end

  create_table "orders", :force => true do |t|
    t.integer  "total_quantity",    :default => 0
    t.integer  "total_price",       :default => 0
    t.integer  "distribution_week", :default => 0
    t.integer  "status",            :default => 0, :null => false
    t.integer  "user_id"
    t.integer  "store_id"
    t.integer  "period_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "option_id"
    t.integer  "updated_by_id"
  end

  add_index "orders", ["option_id"], :name => "index_orders_on_option_id"
  add_index "orders", ["period_id"], :name => "index_orders_on_period_id"
  add_index "orders", ["store_id"], :name => "index_orders_on_store_id"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"

  create_table "orders_backup_150514", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "total_quantity"
    t.integer  "total_price"
    t.integer  "distribution_week"
    t.integer  "status"
    t.integer  "user_id"
    t.integer  "store_id"
    t.integer  "period_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "option_id"
    t.integer  "updated_by_id"
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "reference_number"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "box_quantity"
  end

  create_table "periods", :id => false, :force => true do |t|
    t.integer  "id",                              :null => false
    t.string   "period_number",  :default => "0"
    t.integer  "week_number"
    t.date     "date_promo"
    t.date     "date_samples"
    t.date     "date_approval"
    t.date     "date_print"
    t.date     "date_dispatch"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "current"
    t.boolean  "completed"
    t.date     "date_promo_end"
    t.integer  "client_id"
    t.integer  "year"
    t.boolean  "locked"
  end

  add_index "periods", ["client_id"], :name => "index_periods_on_clientid"

  create_table "periods_backup_1206", :force => true do |t|
    t.integer  "period_number",  :default => 0
    t.integer  "week_number",    :default => 0
    t.date     "date_promo"
    t.date     "date_samples"
    t.date     "date_approval"
    t.date     "date_print"
    t.date     "date_dispatch"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.boolean  "current",        :default => false
    t.boolean  "completed",      :default => false, :null => false
    t.date     "date_promo_end"
    t.integer  "client_id"
    t.integer  "year"
    t.boolean  "locked"
  end

  add_index "periods_backup_1206", ["client_id"], :name => "index_periods_on_client_id"

  create_table "pods", :force => true do |t|
    t.string   "tracking_number"
    t.datetime "collection_date"
    t.string   "reference"
    t.integer  "num_parcels_collected"
    t.string   "service_level"
    t.string   "business_name"
    t.string   "postcode"
    t.datetime "delivery_date"
    t.string   "delivery_depot"
    t.integer  "num_parcels_delivered"
    t.string   "signature"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "status"
  end

  add_index "pods", ["business_name", "postcode"], :name => "index_pods_on_business_name_and_postcode"
  add_index "pods", ["tracking_number"], :name => "tracking"

  create_table "postcode_sectors", :force => true do |t|
    t.string   "area",        :limit => 2
    t.integer  "district"
    t.integer  "sector"
    t.integer  "residential"
    t.integer  "business"
    t.string   "zone",        :limit => 2
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "products", :id => false, :force => true do |t|
    t.integer  "id",                             :null => false
    t.integer  "client_id"
    t.string   "name",                           :null => false
    t.string   "description"
    t.boolean  "bottles",     :default => false, :null => false
    t.boolean  "fridge",      :default => false, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "products", ["client_id"], :name => "index_products_on_client_id"

  create_table "record_locks", :force => true do |t|
    t.string   "record_type"
    t.integer  "record_id"
    t.integer  "user_id"
    t.datetime "created_at"
  end

  add_index "record_locks", ["record_type", "record_id"], :name => "index_record_locks_on_record_type_and_record_id"

  create_table "royalmailtemp", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title",         :limit => 4
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_name"
  end

  create_table "shared_folders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "folder_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "solustemp", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title",         :limit => 4
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_name"
  end

  create_table "stores", :force => true do |t|
    t.string   "account_number"
    t.string   "reference_number"
    t.string   "owner_name"
    t.text     "description"
    t.string   "postcode"
    t.string   "preferred_distribution",     :default => "", :null => false
    t.integer  "client_id"
    t.integer  "logotype_id"
    t.integer  "business_manager_id"
    t.integer  "user_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.integer  "updated_by_id"
    t.string   "logo"
    t.boolean  "store_urgent"
    t.boolean  "participation_only"
    t.integer  "preferred_option_id"
    t.integer  "address_id"
    t.boolean  "personalised_address_panel"
    t.boolean  "personalised_panel_1"
    t.boolean  "personalised_panel_2"
    t.boolean  "personalised_panel_3"
  end

  add_index "stores", ["business_manager_id"], :name => "index_stores_on_business_manager_id"
  add_index "stores", ["client_id"], :name => "index_stores_on_client_id"
  add_index "stores", ["logotype_id"], :name => "index_stores_on_logotype_id"
  add_index "stores", ["user_id"], :name => "index_stores_on_user_id"

  create_table "storetemp", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "title",         :limit => 4
    t.string   "full_name"
    t.string   "first_line"
    t.string   "second_line"
    t.string   "third_line"
    t.string   "city"
    t.string   "postcode"
    t.string   "county"
    t.string   "phone_number"
    t.string   "email"
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_name"
  end

  create_table "tasks", :force => true do |t|
    t.string   "full_text"
    t.boolean  "completed"
    t.integer  "completion",     :default => 0
    t.integer  "priority",       :default => 0
    t.integer  "agent_id"
    t.integer  "department_id"
    t.integer  "user_id"
    t.integer  "store_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.date     "due_date"
    t.boolean  "archived",       :default => false
    t.datetime "archived_at"
    t.boolean  "for_department", :default => false, :null => false
  end

  add_index "tasks", ["department_id"], :name => "index_tasks_on_department_id"
  add_index "tasks", ["store_id"], :name => "index_tasks_on_order_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "template_backup", :id => false, :force => true do |t|
    t.integer  "id"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transports", :force => true do |t|
    t.string   "transport_type"
    t.string   "spreadsheet_file_name"
    t.integer  "user_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.integer  "status"
  end

  add_index "transports", ["user_id"], :name => "index_transports_on_user_id"

  create_table "uploaded_files", :force => true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "folder_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "name"
    t.string   "phone"
    t.integer  "department_id"
    t.boolean  "approved",               :default => false, :null => false
    t.datetime "last_request_at"
    t.string   "last_request"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "user_type"
    t.integer  "client_id"
  end

  add_index "users", ["approved"], :name => "index_users_on_approved"
  add_index "users", ["department_id"], :name => "index_users_on_department_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

end
