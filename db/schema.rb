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

ActiveRecord::Schema[8.1].define(version: 2026_02_21_142548) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "accountable_id"
    t.string "accountable_type"
    t.text "cloudflare_api_token_ciphertext"
    t.string "cloudflare_zone_id"
    t.text "cohere_api_key_ciphertext"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "openrouter_api_key_ciphertext"
    t.text "postiz_api_key_ciphertext"
    t.text "postmark_account_api_token_ciphertext"
    t.text "postmark_server_api_token_ciphertext"
    t.integer "postmark_server_id"
    t.string "slug", null: false
    t.bigint "storage_used_bytes", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["accountable_type", "accountable_id"], name: "index_accounts_on_accountable_type_and_accountable_id"
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
  end

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agent_conversation_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_conversation_id", null: false
    t.uuid "archived_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_conversation_id"], name: "index_agent_conversation_archives_on_agent_conversation_id", unique: true
    t.index ["archived_by_id"], name: "index_agent_conversation_archives_on_archived_by_id"
  end

  create_table "agent_conversation_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_conversation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["agent_conversation_id"], name: "index_agent_conversation_favorites_on_agent_conversation_id"
    t.index ["user_id", "agent_conversation_id"], name: "idx_agent_conv_favorites_unique", unique: true
    t.index ["user_id"], name: "index_agent_conversation_favorites_on_user_id"
  end

  create_table "agent_conversation_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_agent_conv_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_agent_conversation_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_agent_conversation_folders_on_parent_folder_id"
  end

  create_table "agent_conversation_memories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_conversation_id", null: false
    t.uuid "agent_memory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_conversation_id"], name: "index_agent_conversation_memories_on_agent_conversation_id"
    t.index ["agent_memory_id", "agent_conversation_id"], name: "idx_conv_memories_unique", unique: true
    t.index ["agent_memory_id"], name: "index_agent_conversation_memories_on_agent_memory_id"
  end

  create_table "agent_conversation_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_conversation_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_agent_conv_trash_cleanup"
    t.index ["account_id"], name: "index_agent_conversation_trash_items_on_account_id"
    t.index ["agent_conversation_id"], name: "index_agent_conversation_trash_items_on_agent_conversation_id", unique: true
    t.index ["original_folder_id"], name: "index_agent_conversation_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_agent_conversation_trash_items_on_trashed_by_id"
  end

  create_table "agent_conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_conversation_folder_id"
    t.uuid "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_message_at"
    t.integer "messages_count", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id", "user_id"], name: "index_agent_conversations_on_account_id_and_user_id"
    t.index ["account_id"], name: "index_agent_conversations_on_account_id"
    t.index ["agent_conversation_folder_id"], name: "index_agent_conversations_on_agent_conversation_folder_id"
    t.index ["agent_id", "user_id"], name: "index_agent_conversations_on_agent_id_and_user_id"
    t.index ["agent_id"], name: "index_agent_conversations_on_agent_id"
    t.index ["user_id"], name: "index_agent_conversations_on_user_id"
  end

  create_table "agent_deactivations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_id", null: false
    t.datetime "created_at", null: false
    t.uuid "deactivated_by_id", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_agent_deactivations_on_agent_id", unique: true
    t.index ["deactivated_by_id"], name: "index_agent_deactivations_on_deactivated_by_id"
  end

  create_table "agent_feature_accesses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "feature", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "feature"], name: "index_agent_feature_accesses_on_agent_id_and_feature", unique: true
    t.index ["created_by_id"], name: "index_agent_feature_accesses_on_created_by_id"
  end

  create_table "agent_memories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_id", null: false
    t.uuid "agent_memory_folder_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "agent_id"], name: "index_agent_memories_on_account_id_and_agent_id"
    t.index ["account_id"], name: "index_agent_memories_on_account_id"
    t.index ["agent_id", "key"], name: "index_agent_memories_on_agent_id_and_key", unique: true
    t.index ["agent_id"], name: "index_agent_memories_on_agent_id"
    t.index ["agent_memory_folder_id"], name: "index_agent_memories_on_agent_memory_folder_id"
  end

  create_table "agent_memory_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_memory_id", null: false
    t.uuid "archived_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_memory_id"], name: "index_agent_memory_archives_on_agent_memory_id", unique: true
    t.index ["archived_by_id"], name: "index_agent_memory_archives_on_archived_by_id"
  end

  create_table "agent_memory_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_memory_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["agent_memory_id"], name: "index_agent_memory_favorites_on_agent_memory_id"
    t.index ["user_id", "agent_memory_id"], name: "idx_agent_memory_favorites_unique", unique: true
    t.index ["user_id"], name: "index_agent_memory_favorites_on_user_id"
  end

  create_table "agent_memory_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_agent_memory_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_agent_memory_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_agent_memory_folders_on_parent_folder_id"
  end

  create_table "agent_memory_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_memory_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_agent_memory_trash_cleanup"
    t.index ["account_id"], name: "index_agent_memory_trash_items_on_account_id"
    t.index ["agent_memory_id"], name: "index_agent_memory_trash_items_on_agent_memory_id", unique: true
    t.index ["original_folder_id"], name: "index_agent_memory_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_agent_memory_trash_items_on_trashed_by_id"
  end

  create_table "agent_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_conversation_id", null: false
    t.text "content"
    t.integer "cost_in_microcents", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.string "role", null: false
    t.string "tool_call_id"
    t.datetime "updated_at", null: false
    t.index ["agent_conversation_id", "created_at"], name: "index_agent_messages_on_agent_conversation_id_and_created_at"
    t.index ["agent_conversation_id"], name: "index_agent_messages_on_agent_conversation_id"
  end

  create_table "agent_skill_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_skill_id", null: false
    t.uuid "archived_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_skill_id"], name: "index_agent_skill_archives_on_agent_skill_id", unique: true
    t.index ["archived_by_id"], name: "index_agent_skill_archives_on_archived_by_id"
  end

  create_table "agent_skill_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["agent_skill_id"], name: "index_agent_skill_favorites_on_agent_skill_id"
    t.index ["user_id", "agent_skill_id"], name: "idx_agent_skill_favorites_unique", unique: true
    t.index ["user_id"], name: "index_agent_skill_favorites_on_user_id"
  end

  create_table "agent_skill_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_agent_skill_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_agent_skill_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_agent_skill_folders_on_parent_folder_id"
  end

  create_table "agent_skill_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_skill_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_agent_skill_trash_cleanup"
    t.index ["account_id"], name: "index_agent_skill_trash_items_on_account_id"
    t.index ["agent_skill_id"], name: "index_agent_skill_trash_items_on_agent_skill_id", unique: true
    t.index ["original_folder_id"], name: "index_agent_skill_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_agent_skill_trash_items_on_trashed_by_id"
  end

  create_table "agent_skills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_skill_folder_id"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "default_agent_id"
    t.text "description"
    t.text "instructions", null: false
    t.string "name", null: false
    t.jsonb "parameter_definitions", default: []
    t.integer "tasks_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_agent_skills_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_agent_skills_on_account_id"
    t.index ["agent_skill_folder_id"], name: "index_agent_skills_on_agent_skill_folder_id"
    t.index ["created_by_id"], name: "index_agent_skills_on_created_by_id"
    t.index ["default_agent_id"], name: "index_agent_skills_on_default_agent_id"
  end

  create_table "agent_task_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.uuid "archived_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_task_archives_on_agent_task_id", unique: true
    t.index ["archived_by_id"], name: "index_agent_task_archives_on_archived_by_id"
  end

  create_table "agent_task_cancellations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.uuid "cancelled_by_id", null: false
    t.datetime "created_at", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_task_cancellations_on_agent_task_id", unique: true
    t.index ["cancelled_by_id"], name: "index_agent_task_cancellations_on_cancelled_by_id"
  end

  create_table "agent_task_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.text "summary"
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_task_completions_on_agent_task_id", unique: true
  end

  create_table "agent_task_failures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_task_failures_on_agent_task_id", unique: true
  end

  create_table "agent_task_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["agent_task_id"], name: "index_agent_task_favorites_on_agent_task_id"
    t.index ["user_id", "agent_task_id"], name: "idx_agent_task_favorites_unique", unique: true
    t.index ["user_id"], name: "index_agent_task_favorites_on_user_id"
  end

  create_table "agent_task_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.integer "agent_tasks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.integer "subfolders_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_agent_task_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_agent_task_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_agent_task_folders_on_parent_folder_id"
  end

  create_table "agent_task_memories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_memory_id", null: false
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_memory_id", "agent_task_id"], name: "idx_task_memories_unique", unique: true
    t.index ["agent_memory_id"], name: "index_agent_task_memories_on_agent_memory_id"
    t.index ["agent_task_id"], name: "index_agent_task_memories_on_agent_task_id"
  end

  create_table "agent_task_pauses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.uuid "paused_by_id", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_task_pauses_on_agent_task_id", unique: true
    t.index ["paused_by_id"], name: "index_agent_task_pauses_on_paused_by_id"
  end

  create_table "agent_task_skill_usages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_skill_id", null: false
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_skill_id"], name: "index_agent_task_skill_usages_on_agent_skill_id"
    t.index ["agent_task_id", "agent_skill_id"], name: "idx_task_skill_usages_unique", unique: true
    t.index ["agent_task_id"], name: "index_agent_task_skill_usages_on_agent_task_id"
  end

  create_table "agent_task_starts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_task_id"], name: "index_agent_task_starts_on_agent_task_id", unique: true
  end

  create_table "agent_task_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_skill_id"
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.text "detail"
    t.integer "duration_ms"
    t.string "kind", null: false
    t.jsonb "metadata", default: {}
    t.integer "position", null: false
    t.string "status", default: "completed", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_skill_id"], name: "index_agent_task_steps_on_agent_skill_id"
    t.index ["agent_task_id", "position"], name: "index_agent_task_steps_on_agent_task_id_and_position"
    t.index ["agent_task_id"], name: "index_agent_task_steps_on_agent_task_id"
  end

  create_table "agent_task_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_task_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_agent_task_trash_cleanup"
    t.index ["account_id"], name: "index_agent_task_trash_items_on_account_id"
    t.index ["agent_task_id"], name: "index_agent_task_trash_items_on_agent_task_id", unique: true
    t.index ["original_folder_id"], name: "index_agent_task_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_agent_task_trash_items_on_trashed_by_id"
  end

  create_table "agent_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "agent_conversation_id", null: false
    t.uuid "agent_id", null: false
    t.uuid "agent_task_folder_id"
    t.datetime "created_at", null: false
    t.text "instructions", null: false
    t.jsonb "parameters", default: {}
    t.integer "steps_count", default: 0
    t.string "title", null: false
    t.integer "total_iterations", default: 0
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id", "created_at"], name: "index_agent_tasks_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_agent_tasks_on_account_id"
    t.index ["agent_conversation_id"], name: "index_agent_tasks_on_agent_conversation_id", unique: true
    t.index ["agent_id"], name: "index_agent_tasks_on_agent_id"
    t.index ["agent_task_folder_id"], name: "index_agent_tasks_on_agent_task_folder_id"
    t.index ["user_id"], name: "index_agent_tasks_on_user_id"
  end

  create_table "agent_tool_call_approvals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_tool_call_id", null: false
    t.uuid "approved_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_tool_call_id"], name: "index_agent_tool_call_approvals_on_agent_tool_call_id", unique: true
    t.index ["approved_by_id"], name: "index_agent_tool_call_approvals_on_approved_by_id"
  end

  create_table "agent_tool_call_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_tool_call_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "result"
    t.datetime "updated_at", null: false
    t.index ["agent_tool_call_id"], name: "index_agent_tool_call_executions_on_agent_tool_call_id", unique: true
  end

  create_table "agent_tool_call_failures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_tool_call_id", null: false
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "updated_at", null: false
    t.index ["agent_tool_call_id"], name: "index_agent_tool_call_failures_on_agent_tool_call_id", unique: true
  end

  create_table "agent_tool_call_rejections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_tool_call_id", null: false
    t.datetime "created_at", null: false
    t.text "reason"
    t.uuid "rejected_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_tool_call_id"], name: "index_agent_tool_call_rejections_on_agent_tool_call_id", unique: true
    t.index ["rejected_by_id"], name: "index_agent_tool_call_rejections_on_rejected_by_id"
  end

  create_table "agent_tool_calls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "agent_conversation_id", null: false
    t.uuid "agent_message_id", null: false
    t.uuid "agent_tool_id"
    t.datetime "created_at", null: false
    t.jsonb "tool_arguments", default: {}, null: false
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_conversation_id", "created_at"], name: "index_agent_tool_calls_on_agent_conversation_id_and_created_at"
    t.index ["agent_conversation_id"], name: "index_agent_tool_calls_on_agent_conversation_id"
    t.index ["agent_message_id"], name: "index_agent_tool_calls_on_agent_message_id"
    t.index ["agent_tool_id"], name: "index_agent_tool_calls_on_agent_tool_id"
  end

  create_table "agent_tools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description", null: false
    t.string "display_name", null: false
    t.string "feature", null: false
    t.string "implementation_class", null: false
    t.string "name", null: false
    t.jsonb "parameters_schema", default: {}, null: false
    t.text "source_code"
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_agent_tools_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_agent_tools_on_account_id"
    t.index ["created_by_id"], name: "index_agent_tools_on_created_by_id"
  end

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "model", default: "anthropic/claude-sonnet-4", null: false
    t.text "system_prompt"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id"], name: "index_agents_on_account_id"
    t.index ["created_by_id"], name: "index_agents_on_created_by_id"
    t.index ["user_id"], name: "index_agents_on_user_id", unique: true
  end

  create_table "approval_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "approvable_id", null: false
    t.string "approvable_type", null: false
    t.uuid "approver_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.uuid "submitted_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["approvable_type", "approvable_id", "created_at"], name: "idx_on_approvable_type_approvable_id_created_at_2726951451"
    t.index ["approvable_type", "approvable_id"], name: "idx_on_approvable_type_approvable_id_1de891e0db"
    t.index ["approver_id"], name: "index_approval_submissions_on_approver_id"
    t.index ["submitted_by_id"], name: "index_approval_submissions_on_submitted_by_id"
  end

  create_table "approvals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "approval_submission_id", null: false
    t.uuid "approved_by_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.datetime "updated_at", null: false
    t.index ["approval_submission_id"], name: "index_approvals_on_approval_submission_id", unique: true
    t.index ["approved_by_id"], name: "index_approvals_on_approved_by_id"
  end

  create_table "asset_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "asset_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["asset_id"], name: "index_asset_favorites_on_asset_id"
    t.index ["user_id", "asset_id"], name: "index_asset_favorites_on_user_id_and_asset_id", unique: true
    t.index ["user_id"], name: "index_asset_favorites_on_user_id"
  end

  create_table "asset_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "asset_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_813222d872"
    t.index ["account_id"], name: "index_asset_trash_items_on_account_id"
    t.index ["asset_id"], name: "index_asset_trash_items_on_asset_id", unique: true
    t.index ["original_folder_id"], name: "index_asset_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_asset_trash_items_on_trashed_by_id"
  end

  create_table "assets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "collection_id"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.uuid "uploaded_by_id", null: false
    t.index ["account_id", "created_at"], name: "index_assets_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_assets_on_account_id"
    t.index ["collection_id"], name: "index_assets_on_collection_id"
    t.index ["uploaded_by_id"], name: "index_assets_on_uploaded_by_id"
  end

  create_table "book_api_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "book_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_book_api_tokens_on_account_id"
    t.index ["book_id", "account_id"], name: "index_book_api_tokens_on_book_id_and_account_id"
    t.index ["book_id"], name: "index_book_api_tokens_on_book_id"
    t.index ["created_by_id"], name: "index_book_api_tokens_on_created_by_id"
    t.index ["token"], name: "index_book_api_tokens_on_token", unique: true
  end

  create_table "book_collaborators", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "added_by_id"
    t.uuid "book_id", null: false
    t.datetime "created_at", null: false
    t.string "role", default: "viewer", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["added_by_id"], name: "index_book_collaborators_on_added_by_id"
    t.index ["book_id", "user_id"], name: "idx_book_collaborators_unique", unique: true
    t.index ["book_id"], name: "index_book_collaborators_on_book_id"
    t.index ["user_id"], name: "index_book_collaborators_on_user_id"
  end

  create_table "book_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["book_id"], name: "index_book_favorites_on_book_id"
    t.index ["user_id", "book_id"], name: "index_book_favorites_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_book_favorites_on_user_id"
  end

  create_table "book_publications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "book_id", null: false
    t.datetime "created_at", null: false
    t.boolean "embed_enabled", default: false, null: false
    t.jsonb "embed_settings", default: {}, null: false
    t.uuid "published_by_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_publications_on_book_id", unique: true
    t.index ["published_by_id"], name: "index_book_publications_on_published_by_id"
    t.index ["token"], name: "index_book_publications_on_token", unique: true
  end

  create_table "book_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "book_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_book_trash_items_on_account_id"
    t.index ["book_id"], name: "index_book_trash_items_on_book_id", unique: true
    t.index ["original_folder_id"], name: "index_book_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_book_trash_items_on_trashed_by_id"
  end

  create_table "books", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.uuid "document_folder_id"
    t.integer "documents_count", default: 0, null: false
    t.string "icon"
    t.string "title", default: "Untitled", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count", default: 0, null: false
    t.index ["account_id", "updated_at"], name: "index_books_on_account_id_and_updated_at"
    t.index ["account_id"], name: "index_books_on_account_id"
    t.index ["created_by_id"], name: "index_books_on_created_by_id"
    t.index ["document_folder_id"], name: "index_books_on_document_folder_id"
  end

  create_table "business_role_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_by_id", null: false
    t.uuid "business_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["assigned_by_id"], name: "index_business_role_assignments_on_assigned_by_id"
    t.index ["business_role_id", "user_id"], name: "idx_on_business_role_id_user_id_7df9254c15", unique: true
    t.index ["business_role_id"], name: "index_business_role_assignments_on_business_role_id"
    t.index ["user_id"], name: "index_business_role_assignments_on_user_id"
  end

  create_table "business_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "users_count", default: 0, null: false
    t.index ["account_id", "name"], name: "index_business_roles_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_business_roles_on_account_id_and_position"
    t.index ["account_id"], name: "index_business_roles_on_account_id"
    t.index ["created_by_id"], name: "index_business_roles_on_created_by_id"
  end

  create_table "calendar_acceptances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "accepted_by_id", null: false
    t.uuid "calendar_invitation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_calendar_acceptances_on_accepted_by_id"
    t.index ["calendar_invitation_id"], name: "index_calendar_acceptances_on_calendar_invitation_id", unique: true
  end

  create_table "calendar_acknowledgments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "acknowledgable_id", null: false
    t.string "acknowledgable_type", null: false
    t.uuid "acknowledged_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acknowledgable_type", "acknowledgable_id", "acknowledged_by_id"], name: "idx_calendar_acknowledgments_uniqueness", unique: true
    t.index ["acknowledged_by_id"], name: "index_calendar_acknowledgments_on_acknowledged_by_id"
  end

  create_table "calendar_action_item_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "calendar_action_item_id", null: false
    t.uuid "completed_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_action_item_id"], name: "idx_on_calendar_action_item_id_5139a58828", unique: true
    t.index ["completed_by_id"], name: "index_calendar_action_item_completions_on_completed_by_id"
  end

  create_table "calendar_action_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assignee_id"
    t.uuid "calendar_meeting_note_id", null: false
    t.datetime "created_at", null: false
    t.date "due_date"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_calendar_action_items_on_assignee_id"
    t.index ["calendar_meeting_note_id"], name: "index_calendar_action_items_on_calendar_meeting_note_id"
  end

  create_table "calendar_agenda_item_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "calendar_agenda_item_id", null: false
    t.uuid "completed_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_agenda_item_id"], name: "idx_on_calendar_agenda_item_id_d8b32a7012", unique: true
    t.index ["completed_by_id"], name: "index_calendar_agenda_item_completions_on_completed_by_id"
  end

  create_table "calendar_agenda_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "calendar_meeting_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "position", default: 0
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_meeting_id"], name: "index_calendar_agenda_items_on_calendar_meeting_id"
  end

  create_table "calendar_alerts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "alert_before_minutes", default: 15
    t.uuid "alertable_id", null: false
    t.string "alertable_type", null: false
    t.datetime "created_at", null: false
    t.string "method", default: "email"
    t.datetime "updated_at", null: false
    t.index ["alertable_type", "alertable_id"], name: "index_calendar_alerts_on_alertable_type_and_alertable_id"
  end

  create_table "calendar_declines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "calendar_invitation_id", null: false
    t.datetime "created_at", null: false
    t.uuid "declined_by_id", null: false
    t.string "reason"
    t.datetime "updated_at", null: false
    t.index ["calendar_invitation_id"], name: "index_calendar_declines_on_calendar_invitation_id", unique: true
    t.index ["declined_by_id"], name: "index_calendar_declines_on_declined_by_id"
  end

  create_table "calendar_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "all_day", default: false
    t.uuid "calendar_folder_id"
    t.integer "calendar_invitations_count", default: 0, null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.datetime "ends_at", null: false
    t.string "location"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "ends_at"], name: "index_calendar_events_on_account_id_and_ends_at"
    t.index ["account_id", "starts_at"], name: "index_calendar_events_on_account_id_and_starts_at"
    t.index ["account_id"], name: "index_calendar_events_on_account_id"
    t.index ["calendar_folder_id"], name: "index_calendar_events_on_calendar_folder_id"
    t.index ["created_by_id"], name: "index_calendar_events_on_created_by_id"
  end

  create_table "calendar_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.integer "calendar_events_count", default: 0, null: false
    t.integer "calendar_folders_count", default: 0, null: false
    t.integer "calendar_meetings_count", default: 0, null: false
    t.integer "calendar_reminders_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_on_account_id_parent_folder_id_name_85383a39da", unique: true
    t.index ["account_id"], name: "index_calendar_folders_on_account_id"
    t.index ["created_by_id"], name: "index_calendar_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_calendar_folders_on_parent_folder_id"
  end

  create_table "calendar_invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invitable_id", null: false
    t.string "invitable_type", null: false
    t.uuid "invited_by_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["invitable_type", "invitable_id", "user_id"], name: "idx_calendar_invitations_uniqueness", unique: true
    t.index ["invited_by_id"], name: "index_calendar_invitations_on_invited_by_id"
    t.index ["user_id"], name: "index_calendar_invitations_on_user_id"
  end

  create_table "calendar_meeting_notes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "calendar_action_items_count", default: 0, null: false
    t.uuid "calendar_meeting_id", null: false
    t.jsonb "content", default: []
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_meeting_id"], name: "index_calendar_meeting_notes_on_calendar_meeting_id"
    t.index ["created_by_id"], name: "index_calendar_meeting_notes_on_created_by_id"
  end

  create_table "calendar_meetings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "all_day", default: false
    t.integer "calendar_agenda_items_count", default: 0, null: false
    t.uuid "calendar_folder_id"
    t.integer "calendar_invitations_count", default: 0, null: false
    t.integer "calendar_meeting_notes_count", default: 0, null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.datetime "ends_at", null: false
    t.string "location"
    t.string "meeting_url"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "ends_at"], name: "index_calendar_meetings_on_account_id_and_ends_at"
    t.index ["account_id", "starts_at"], name: "index_calendar_meetings_on_account_id_and_starts_at"
    t.index ["account_id"], name: "index_calendar_meetings_on_account_id"
    t.index ["calendar_folder_id"], name: "index_calendar_meetings_on_calendar_folder_id"
    t.index ["created_by_id"], name: "index_calendar_meetings_on_created_by_id"
  end

  create_table "calendar_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_calendar_acceptance", default: true, null: false
    t.boolean "email_calendar_decline", default: true, null: false
    t.boolean "email_calendar_invitation", default: true, null: false
    t.boolean "email_calendar_meeting_note", default: true, null: false
    t.boolean "email_calendar_reminder", default: true, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_calendar_notification_preferences_on_user_id", unique: true
  end

  create_table "calendar_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_calendar_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_calendar_notification_readings_on_user_id"
  end

  create_table "calendar_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_calendar_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_calendar_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_calendar_notification_recipients_on_user_id"
  end

  create_table "calendar_occurrences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "cancelled", default: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.uuid "occurable_id", null: false
    t.string "occurable_type", null: false
    t.datetime "original_starts_at", null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurable_type", "occurable_id", "original_starts_at"], name: "idx_calendar_occurrences_uniqueness", unique: true
    t.index ["starts_at", "ends_at"], name: "index_calendar_occurrences_on_starts_at_and_ends_at"
  end

  create_table "calendar_recurrences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "recurable_id", null: false
    t.string "recurable_type", null: false
    t.string "rrule", null: false
    t.datetime "updated_at", null: false
    t.index ["recurable_type", "recurable_id"], name: "index_calendar_recurrences_on_recurable_type_and_recurable_id", unique: true
  end

  create_table "calendar_reminder_shares", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "calendar_reminder_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["calendar_reminder_id", "user_id"], name: "idx_on_calendar_reminder_id_user_id_e45e3bc986", unique: true
    t.index ["calendar_reminder_id"], name: "index_calendar_reminder_shares_on_calendar_reminder_id"
    t.index ["user_id"], name: "index_calendar_reminder_shares_on_user_id"
  end

  create_table "calendar_reminders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "all_day", default: false
    t.uuid "calendar_folder_id"
    t.integer "calendar_reminder_shares_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.datetime "remind_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "remind_at"], name: "index_calendar_reminders_on_account_id_and_remind_at"
    t.index ["account_id"], name: "index_calendar_reminders_on_account_id"
    t.index ["calendar_folder_id"], name: "index_calendar_reminders_on_calendar_folder_id"
    t.index ["created_by_id"], name: "index_calendar_reminders_on_created_by_id"
  end

  create_table "calendar_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashable_id", null: false
    t.string "trashable_type", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_calendar_trash_items_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_calendar_trash_items_on_account_id"
    t.index ["permanently_delete_at"], name: "index_calendar_trash_items_on_permanently_delete_at"
    t.index ["trashable_type", "trashable_id"], name: "index_calendar_trash_items_on_trashable_type_and_trashable_id", unique: true
    t.index ["trashed_by_id"], name: "index_calendar_trash_items_on_trashed_by_id"
  end

  create_table "chat_bookmarks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["chat_message_id", "user_id"], name: "index_chat_bookmarks_on_chat_message_id_and_user_id", unique: true
    t.index ["chat_message_id"], name: "index_chat_bookmarks_on_chat_message_id"
    t.index ["user_id", "created_at"], name: "index_chat_bookmarks_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_chat_bookmarks_on_user_id"
  end

  create_table "chat_conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "conversation_type", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.datetime "last_message_at"
    t.integer "memberships_count", default: 0, null: false
    t.integer "messages_count", default: 0, null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["account_id", "conversation_type"], name: "index_chat_conversations_on_account_id_and_conversation_type"
    t.index ["account_id", "last_message_at"], name: "index_chat_conversations_on_account_id_and_last_message_at"
    t.index ["account_id"], name: "index_chat_conversations_on_account_id"
    t.index ["created_by_id"], name: "index_chat_conversations_on_created_by_id"
  end

  create_table "chat_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_conversation_id", null: false
    t.datetime "created_at", null: false
    t.uuid "last_read_message_id"
    t.datetime "last_seen_at"
    t.boolean "notifications_enabled", default: true, null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["chat_conversation_id", "user_id"], name: "index_chat_memberships_on_chat_conversation_id_and_user_id", unique: true
    t.index ["chat_conversation_id"], name: "index_chat_memberships_on_chat_conversation_id"
    t.index ["last_read_message_id"], name: "index_chat_memberships_on_last_read_message_id"
    t.index ["user_id"], name: "index_chat_memberships_on_user_id"
  end

  create_table "chat_mentions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_message_id", null: false
    t.datetime "created_at", null: false
    t.uuid "mentioned_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_message_id", "mentioned_user_id"], name: "idx_chat_mentions_unique", unique: true
    t.index ["chat_message_id"], name: "index_chat_mentions_on_chat_message_id"
    t.index ["mentioned_user_id", "created_at"], name: "index_chat_mentions_on_mentioned_user_id_and_created_at"
    t.index ["mentioned_user_id"], name: "index_chat_mentions_on_mentioned_user_id"
  end

  create_table "chat_message_edits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_message_id", null: false
    t.datetime "created_at", null: false
    t.uuid "edited_by_id", null: false
    t.text "previous_content", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_message_id", "created_at"], name: "index_chat_message_edits_on_chat_message_id_and_created_at"
    t.index ["chat_message_id"], name: "index_chat_message_edits_on_chat_message_id"
    t.index ["edited_by_id"], name: "index_chat_message_edits_on_edited_by_id"
  end

  create_table "chat_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_conversation_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.uuid "parent_message_id"
    t.integer "reactions_count", default: 0, null: false
    t.integer "replies_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["chat_conversation_id", "created_at"], name: "index_chat_messages_on_chat_conversation_id_and_created_at"
    t.index ["chat_conversation_id"], name: "index_chat_messages_on_chat_conversation_id"
    t.index ["parent_message_id", "created_at"], name: "index_chat_messages_on_parent_message_id_and_created_at"
    t.index ["parent_message_id"], name: "index_chat_messages_on_parent_message_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "chat_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_chat_mention", default: true
    t.boolean "email_chat_message", default: true
    t.boolean "email_chat_reaction", default: true
    t.boolean "email_chat_reply", default: true
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_chat_notification_preferences_on_user_id", unique: true
  end

  create_table "chat_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_chat_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_chat_notification_readings_on_user_id"
  end

  create_table "chat_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_chat_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_chat_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_chat_notification_recipients_on_user_id"
  end

  create_table "chat_pins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_conversation_id", null: false
    t.uuid "chat_message_id", null: false
    t.datetime "created_at", null: false
    t.uuid "pinned_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_conversation_id", "created_at"], name: "index_chat_pins_on_chat_conversation_id_and_created_at"
    t.index ["chat_conversation_id"], name: "index_chat_pins_on_chat_conversation_id"
    t.index ["chat_message_id"], name: "index_chat_pins_on_chat_message_id", unique: true
    t.index ["pinned_by_id"], name: "index_chat_pins_on_pinned_by_id"
  end

  create_table "chat_reactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "chat_message_id", null: false
    t.datetime "created_at", null: false
    t.string "emoji", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["chat_message_id", "emoji"], name: "index_chat_reactions_on_chat_message_id_and_emoji"
    t.index ["chat_message_id", "user_id", "emoji"], name: "idx_chat_reactions_unique", unique: true
    t.index ["chat_message_id"], name: "index_chat_reactions_on_chat_message_id"
    t.index ["user_id"], name: "index_chat_reactions_on_user_id"
  end

  create_table "collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_collection_id"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_collection_id", "name"], name: "index_collections_on_account_parent_name", unique: true
    t.index ["account_id"], name: "index_collections_on_account_id"
    t.index ["parent_collection_id"], name: "index_collections_on_parent_collection_id"
  end

  create_table "crm_api_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "crm_table_id", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_crm_api_tokens_on_account_id"
    t.index ["created_by_id"], name: "index_crm_api_tokens_on_created_by_id"
    t.index ["crm_table_id", "account_id"], name: "index_crm_api_tokens_on_crm_table_id_and_account_id"
    t.index ["crm_table_id"], name: "index_crm_api_tokens_on_crm_table_id"
    t.index ["token"], name: "index_crm_api_tokens_on_token", unique: true
  end

  create_table "crm_attachment_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_field_id", null: false
    t.uuid "crm_row_id", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_field_id"], name: "index_crm_attachments_on_crm_field_id"
    t.index ["crm_row_id"], name: "index_crm_attachments_on_crm_row_id"
  end

  create_table "crm_checkbox_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_currency_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency_code", default: "USD", null: false
    t.string "symbol", default: "$", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_date_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_email_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_enrichment_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_enrichment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_enrichment_id"], name: "index_crm_enrichment_completions_on_crm_enrichment_id", unique: true
  end

  create_table "crm_enrichment_failures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_enrichment_id", null: false
    t.string "error_message", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_enrichment_id"], name: "index_crm_enrichment_failures_on_crm_enrichment_id", unique: true
  end

  create_table "crm_enrichments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.bigint "cost_in_microcents", default: 0
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "crm_table_id", null: false
    t.string "model", null: false
    t.text "prompt", null: false
    t.integer "rows_enriched", default: 0
    t.integer "rows_requested", default: 0, null: false
    t.jsonb "target_field_ids", default: [], null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_crm_enrichments_on_account_id"
    t.index ["created_by_id"], name: "index_crm_enrichments_on_created_by_id"
    t.index ["crm_table_id", "created_at"], name: "index_crm_enrichments_on_crm_table_id_and_created_at"
    t.index ["crm_table_id"], name: "index_crm_enrichments_on_crm_table_id"
  end

  create_table "crm_field_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "crm_field_id", null: false
    t.string "label", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["crm_field_id", "label"], name: "index_crm_field_options_on_crm_field_id_and_label", unique: true
    t.index ["crm_field_id", "position"], name: "index_crm_field_options_on_crm_field_id_and_position"
    t.index ["crm_field_id"], name: "index_crm_field_options_on_crm_field_id"
  end

  create_table "crm_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_table_id", null: false
    t.uuid "fieldable_id", null: false
    t.string "fieldable_type", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["crm_table_id", "name"], name: "index_crm_fields_on_crm_table_id_and_name", unique: true
    t.index ["crm_table_id", "position"], name: "index_crm_fields_on_crm_table_id_and_position"
    t.index ["crm_table_id"], name: "index_crm_fields_on_crm_table_id"
    t.index ["fieldable_type", "fieldable_id"], name: "index_crm_fields_on_fieldable_type_and_fieldable_id"
  end

  create_table "crm_label_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_multi_select_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_number_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "max"
    t.decimal "min"
    t.integer "precision_digits", default: 0
    t.datetime "updated_at", null: false
  end

  create_table "crm_percent_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_phone_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_pipeline_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.uuid "crm_pipeline_stage_id", null: false
    t.uuid "crm_row_id", null: false
    t.datetime "next_update_at"
    t.text "note"
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_crm_pipeline_entries_on_created_by_id"
    t.index ["crm_pipeline_stage_id"], name: "index_crm_pipeline_entries_on_crm_pipeline_stage_id"
    t.index ["crm_row_id", "created_at"], name: "index_crm_pipeline_entries_on_crm_row_id_and_created_at"
    t.index ["crm_row_id"], name: "index_crm_pipeline_entries_on_crm_row_id"
  end

  create_table "crm_pipeline_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "crm_table_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["crm_table_id", "position"], name: "index_crm_pipeline_stages_on_crm_table_id_and_position"
    t.index ["crm_table_id"], name: "index_crm_pipeline_stages_on_crm_table_id"
  end

  create_table "crm_rating_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "max_rating", default: 5, null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_record_link_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "display_crm_field_id"
    t.uuid "target_crm_table_id", null: false
    t.datetime "updated_at", null: false
    t.index ["display_crm_field_id"], name: "index_crm_record_link_fields_on_display_crm_field_id"
    t.index ["target_crm_table_id"], name: "index_crm_record_link_fields_on_target_crm_table_id"
  end

  create_table "crm_research_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_research_id", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_research_id"], name: "index_crm_research_completions_on_crm_research_id", unique: true
  end

  create_table "crm_research_failures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_research_id", null: false
    t.string "error_message", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_research_id"], name: "index_crm_research_failures_on_crm_research_id", unique: true
  end

  create_table "crm_research_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_crm_enrichment_completed", default: true
    t.boolean "email_crm_enrichment_failed", default: true
    t.boolean "email_crm_research_completed", default: true
    t.boolean "email_crm_research_failed", default: true
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_crm_research_notification_preferences_on_user_id", unique: true
  end

  create_table "crm_research_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_crm_research_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_crm_research_notification_readings_on_user_id"
  end

  create_table "crm_research_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_crm_research_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_crm_research_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_crm_research_notification_recipients_on_user_id"
  end

  create_table "crm_researches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.bigint "cost_in_microcents", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "crm_table_id", null: false
    t.string "model", null: false
    t.text "prompt", null: false
    t.integer "rows_created", default: 0, null: false
    t.integer "rows_requested", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_crm_researches_on_account_id"
    t.index ["created_by_id"], name: "index_crm_researches_on_created_by_id"
    t.index ["crm_table_id", "created_at"], name: "index_crm_researches_on_crm_table_id_and_created_at"
    t.index ["crm_table_id"], name: "index_crm_researches_on_crm_table_id"
  end

  create_table "crm_rows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.uuid "crm_table_id", null: false
    t.integer "display_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.jsonb "values", default: {}, null: false
    t.index ["created_by_id"], name: "index_crm_rows_on_created_by_id"
    t.index ["crm_table_id", "created_at"], name: "index_crm_rows_on_crm_table_id_and_created_at"
    t.index ["crm_table_id", "display_id"], name: "index_crm_rows_on_crm_table_id_and_display_id", unique: true
    t.index ["crm_table_id", "position"], name: "index_crm_rows_on_crm_table_id_and_position"
    t.index ["crm_table_id"], name: "index_crm_rows_on_crm_table_id"
    t.index ["values"], name: "index_crm_rows_on_values", using: :gin
  end

  create_table "crm_select_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_table_column_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_table_id", null: false
    t.text "hidden_fields", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["crm_table_id"], name: "index_crm_table_column_preferences_on_crm_table_id"
    t.index ["user_id", "crm_table_id"], name: "idx_crm_col_prefs_user_table", unique: true
    t.index ["user_id"], name: "index_crm_table_column_preferences_on_user_id"
  end

  create_table "crm_table_duplications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "crm_table_id", null: false
    t.uuid "source_crm_table_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_crm_table_duplications_on_created_by_id"
    t.index ["crm_table_id"], name: "index_crm_table_duplications_on_crm_table_id", unique: true
    t.index ["source_crm_table_id"], name: "index_crm_table_duplications_on_source_crm_table_id"
  end

  create_table "crm_table_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_table_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["crm_table_id"], name: "index_crm_table_favorites_on_crm_table_id"
    t.index ["user_id", "crm_table_id"], name: "index_crm_table_favorites_on_user_id_and_crm_table_id", unique: true
    t.index ["user_id"], name: "index_crm_table_favorites_on_user_id"
  end

  create_table "crm_table_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_crm_table_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_crm_table_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_crm_table_folders_on_parent_folder_id"
  end

  create_table "crm_table_publications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "crm_table_id", null: false
    t.text "description"
    t.boolean "embed_enabled", default: false, null: false
    t.jsonb "embed_settings", default: {}, null: false
    t.jsonb "form_fields", default: [], null: false
    t.uuid "published_by_id", null: false
    t.text "success_message"
    t.string "title"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_table_id"], name: "index_crm_table_publications_on_crm_table_id", unique: true
    t.index ["published_by_id"], name: "index_crm_table_publications_on_published_by_id"
    t.index ["token"], name: "index_crm_table_publications_on_token", unique: true
  end

  create_table "crm_table_templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "crm_table_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_crm_table_templates_on_created_by_id"
    t.index ["crm_table_id"], name: "index_crm_table_templates_on_crm_table_id", unique: true
  end

  create_table "crm_table_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "crm_table_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_ba2a53767e"
    t.index ["account_id"], name: "index_crm_table_trash_items_on_account_id"
    t.index ["crm_table_id"], name: "index_crm_table_trash_items_on_crm_table_id", unique: true
    t.index ["original_folder_id"], name: "index_crm_table_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_crm_table_trash_items_on_trashed_by_id"
  end

  create_table "crm_tables", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "book_id"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "crm_fields_count", default: 0, null: false
    t.integer "crm_rows_count", default: 0, null: false
    t.uuid "crm_table_folder_id"
    t.text "description"
    t.uuid "document_folder_id"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_crm_tables_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_crm_tables_on_account_id"
    t.index ["book_id"], name: "index_crm_tables_on_book_id"
    t.index ["created_by_id"], name: "index_crm_tables_on_created_by_id"
    t.index ["crm_table_folder_id"], name: "index_crm_tables_on_crm_table_folder_id"
    t.index ["document_folder_id"], name: "index_crm_tables_on_document_folder_id"
  end

  create_table "crm_text_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_textarea_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_url_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crm_user_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "design_archive_exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "design_id", null: false
    t.uuid "exported_by_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["design_id", "created_at"], name: "idx_archive_exports_on_design_and_created"
    t.index ["design_id"], name: "index_design_archive_exports_on_design_id"
    t.index ["exported_by_id"], name: "index_design_archive_exports_on_exported_by_id"
  end

  create_table "design_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.integer "designs_count", default: 0, null: false
    t.string "name", null: false
    t.uuid "parent_collection_id"
    t.integer "position", default: 0
    t.integer "subcollections_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_collection_id", "name"], name: "idx_design_collections_unique_name", unique: true
    t.index ["account_id"], name: "index_design_collections_on_account_id"
    t.index ["parent_collection_id"], name: "index_design_collections_on_parent_collection_id"
  end

  create_table "design_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "design_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["design_id"], name: "index_design_favorites_on_design_id"
    t.index ["user_id", "design_id"], name: "index_design_favorites_on_user_id_and_design_id", unique: true
    t.index ["user_id"], name: "index_design_favorites_on_user_id"
  end

  create_table "design_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "design_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_bfe722bbf6"
    t.index ["account_id"], name: "index_design_trash_items_on_account_id"
    t.index ["design_id"], name: "index_design_trash_items_on_design_id", unique: true
    t.index ["original_folder_id"], name: "index_design_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_design_trash_items_on_trashed_by_id"
  end

  create_table "designs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "design_collection_id"
    t.integer "grid_cols", default: 4, null: false
    t.integer "grid_gap_percent", default: 2
    t.integer "grid_rows", default: 6, null: false
    t.integer "height", default: 1080, null: false
    t.boolean "is_template", default: false, null: false
    t.string "name", null: false
    t.uuid "source_design_id"
    t.jsonb "theme", default: {}, null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 1
    t.integer "width", default: 1080, null: false
    t.index ["account_id", "is_template"], name: "idx_designs_templates", where: "(is_template = true)"
    t.index ["account_id", "updated_at"], name: "index_designs_on_account_id_and_updated_at"
    t.index ["account_id"], name: "index_designs_on_account_id"
    t.index ["created_by_id"], name: "index_designs_on_created_by_id"
    t.index ["design_collection_id"], name: "index_designs_on_design_collection_id"
  end

  create_table "document_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.integer "books_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_document_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_document_folders_on_account_id"
    t.index ["created_by_id"], name: "index_document_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_document_folders_on_parent_folder_id"
  end

  create_table "document_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_book_collaborator", default: true
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_document_notification_preferences_on_user_id", unique: true
  end

  create_table "document_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_document_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_document_notification_readings_on_user_id"
  end

  create_table "document_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_document_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_document_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_document_notification_recipients_on_user_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "book_id", null: false
    t.jsonb "content", default: [], null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "documentable_id"
    t.string "documentable_type"
    t.string "icon"
    t.integer "position", default: 0, null: false
    t.string "slug"
    t.string "title", default: "Untitled", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count", default: 0, null: false
    t.binary "yjs_state"
    t.index ["account_id", "updated_at"], name: "idx_documents_account_updated"
    t.index ["account_id"], name: "index_documents_on_account_id"
    t.index ["book_id", "position"], name: "index_documents_on_book_id_and_position"
    t.index ["book_id", "slug"], name: "index_documents_on_book_id_and_slug", unique: true
    t.index ["book_id"], name: "index_documents_on_book_id"
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
  end

  create_table "elements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "asset_id"
    t.integer "col_span", default: 1
    t.jsonb "constraints", default: {}
    t.datetime "created_at", null: false
    t.string "editable_fields", default: [], array: true
    t.string "element_type", null: false
    t.integer "grid_col"
    t.integer "grid_row"
    t.integer "height"
    t.decimal "norm_height", precision: 5, scale: 4, default: "0.25"
    t.decimal "norm_width", precision: 5, scale: 4, default: "0.25"
    t.decimal "norm_x", precision: 5, scale: 4, default: "0.0"
    t.decimal "norm_y", precision: 5, scale: 4, default: "0.0"
    t.decimal "opacity", precision: 3, scale: 2, default: "1.0"
    t.uuid "page_id", null: false
    t.integer "position", default: 0
    t.jsonb "properties", default: {}
    t.decimal "rotation", precision: 6, scale: 2, default: "0.0"
    t.integer "row_span", default: 1
    t.string "template_key"
    t.datetime "updated_at", null: false
    t.integer "width"
    t.integer "x", default: 0
    t.integer "y", default: 0
    t.index ["asset_id"], name: "index_elements_on_asset_id"
    t.index ["element_type"], name: "index_elements_on_element_type"
    t.index ["page_id", "element_type"], name: "index_elements_on_page_id_and_element_type"
    t.index ["page_id", "position"], name: "index_elements_on_page_id_and_position"
    t.index ["page_id"], name: "index_elements_on_page_id"
  end

  create_table "email_account_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "email_account_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["assigned_by_id"], name: "index_email_account_assignments_on_assigned_by_id"
    t.index ["email_account_id", "user_id"], name: "idx_on_email_account_id_user_id_d1c7081db2", unique: true
    t.index ["email_account_id"], name: "index_email_account_assignments_on_email_account_id"
    t.index ["user_id"], name: "index_email_account_assignments_on_user_id"
  end

  create_table "email_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "account_type", default: "personal", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "display_name"
    t.uuid "email_domain_id", null: false
    t.integer "postmark_sender_id"
    t.datetime "updated_at", null: false
    t.index ["account_id", "account_type"], name: "index_email_accounts_on_account_id_and_account_type"
    t.index ["account_id"], name: "index_email_accounts_on_account_id"
    t.index ["created_by_id"], name: "index_email_accounts_on_created_by_id"
    t.index ["email_domain_id", "address"], name: "index_email_accounts_on_email_domain_id_and_address", unique: true
    t.index ["email_domain_id"], name: "index_email_accounts_on_email_domain_id"
  end

  create_table "email_domains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "added_by_id", null: false
    t.datetime "created_at", null: false
    t.string "dkim_host"
    t.string "dkim_value"
    t.boolean "dkim_verified", default: false
    t.string "name", null: false
    t.integer "postmark_domain_id"
    t.string "return_path_cname_value"
    t.string "return_path_domain"
    t.boolean "return_path_verified", default: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_email_domains_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_email_domains_on_account_id"
    t.index ["added_by_id"], name: "index_email_domains_on_added_by_id"
  end

  create_table "email_message_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_message_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["email_message_id", "user_id"], name: "index_email_message_archives_on_email_message_id_and_user_id", unique: true
    t.index ["email_message_id"], name: "index_email_message_archives_on_email_message_id"
    t.index ["user_id"], name: "index_email_message_archives_on_user_id"
  end

  create_table "email_message_reads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_message_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["email_message_id", "user_id"], name: "index_email_message_reads_on_email_message_id_and_user_id", unique: true
    t.index ["email_message_id"], name: "index_email_message_reads_on_email_message_id"
    t.index ["user_id"], name: "index_email_message_reads_on_user_id"
  end

  create_table "email_message_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.uuid "email_message_id", null: false
    t.string "field", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["email_message_id", "field"], name: "index_email_message_recipients_on_email_message_id_and_field"
    t.index ["email_message_id"], name: "index_email_message_recipients_on_email_message_id"
  end

  create_table "email_message_stars", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_message_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["email_message_id", "user_id"], name: "index_email_message_stars_on_email_message_id_and_user_id", unique: true
    t.index ["email_message_id"], name: "index_email_message_stars_on_email_message_id"
    t.index ["user_id"], name: "index_email_message_stars_on_user_id"
  end

  create_table "email_message_trashes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "email_message_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["email_message_id", "user_id"], name: "index_email_message_trashes_on_email_message_id_and_user_id", unique: true
    t.index ["email_message_id"], name: "index_email_message_trashes_on_email_message_id"
    t.index ["user_id"], name: "index_email_message_trashes_on_user_id"
  end

  create_table "email_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.text "body_html"
    t.text "body_text"
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.uuid "email_account_id", null: false
    t.string "from_address", null: false
    t.string "from_name"
    t.string "in_reply_to"
    t.string "message_id"
    t.uuid "parent_id"
    t.string "postmark_message_id"
    t.datetime "received_at"
    t.datetime "sent_at"
    t.string "status", default: "draft", null: false
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_email_messages_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_email_messages_on_account_id"
    t.index ["email_account_id", "direction"], name: "index_email_messages_on_email_account_id_and_direction"
    t.index ["email_account_id"], name: "index_email_messages_on_email_account_id"
    t.index ["parent_id"], name: "index_email_messages_on_parent_id"
    t.index ["postmark_message_id"], name: "index_email_messages_on_postmark_message_id", unique: true
  end

  create_table "export_presets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aspect_ratio"
    t.datetime "created_at", null: false
    t.integer "height", null: false
    t.string "name", null: false
    t.string "platform"
    t.integer "position", default: 0
    t.boolean "system_default", default: true
    t.datetime "updated_at", null: false
    t.integer "width", null: false
    t.index ["platform"], name: "index_export_presets_on_platform"
    t.index ["system_default"], name: "index_export_presets_on_system_default"
  end

  create_table "exports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "design_id", null: false
    t.uuid "export_preset_id"
    t.uuid "exported_by_id", null: false
    t.integer "format", default: 0, null: false
    t.jsonb "page_ids", default: []
    t.integer "status", default: 0, null: false
    t.integer "target_height"
    t.integer "target_width"
    t.datetime "updated_at", null: false
    t.index ["design_id", "created_at"], name: "index_exports_on_design_id_and_created_at"
    t.index ["design_id"], name: "index_exports_on_design_id"
    t.index ["export_preset_id"], name: "index_exports_on_export_preset_id"
    t.index ["exported_by_id"], name: "index_exports_on_exported_by_id"
  end

  create_table "finance_budgets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "finance_category_id", null: false
    t.uuid "finance_sheet_id"
    t.integer "month", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["account_id", "finance_category_id", "year", "month"], name: "idx_on_account_id_finance_category_id_year_month_5500288e08", unique: true
    t.index ["account_id", "year", "month"], name: "index_finance_budgets_on_account_id_and_year_and_month"
    t.index ["account_id"], name: "index_finance_budgets_on_account_id"
    t.index ["created_by_id"], name: "index_finance_budgets_on_created_by_id"
    t.index ["finance_category_id"], name: "index_finance_budgets_on_finance_category_id"
    t.index ["finance_sheet_id"], name: "index_finance_budgets_on_finance_sheet_id"
  end

  create_table "finance_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color", default: "#6b7280", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "finance_transactions_count", default: 0
    t.string "icon"
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_finance_categories_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_finance_categories_on_account_id_and_position"
    t.index ["account_id"], name: "index_finance_categories_on_account_id"
    t.index ["created_by_id"], name: "index_finance_categories_on_created_by_id"
  end

  create_table "finance_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_approval", default: true, null: false
    t.boolean "email_approval_submission", default: true, null: false
    t.boolean "email_rejection", default: true, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_finance_notification_preferences_on_user_id", unique: true
  end

  create_table "finance_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_finance_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_finance_notification_readings_on_user_id"
  end

  create_table "finance_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_finance_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_finance_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_finance_notification_recipients_on_user_id"
  end

  create_table "finance_payment_methods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color", default: "#6b7280", null: false
    t.datetime "created_at", null: false
    t.string "icon"
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_finance_payment_methods_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_finance_payment_methods_on_account_id_and_position"
    t.index ["account_id"], name: "index_finance_payment_methods_on_account_id"
  end

  create_table "finance_payment_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color", default: "#6b7280"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_finance_payment_statuses_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_finance_payment_statuses_on_account_id"
  end

  create_table "finance_recurrence_frequencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color", default: "#6b7280", null: false
    t.datetime "created_at", null: false
    t.integer "interval", default: 1, null: false
    t.string "name", null: false
    t.string "period", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_finance_recurrence_frequencies_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "idx_on_account_id_position_d5a5d1579c"
    t.index ["account_id"], name: "index_finance_recurrence_frequencies_on_account_id"
  end

  create_table "finance_recurring_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "active", default: true
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.uuid "approver_id"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "currency", default: "USD", null: false
    t.text "description"
    t.date "end_date"
    t.uuid "finance_category_id"
    t.uuid "finance_payment_method_id"
    t.uuid "finance_recurrence_frequency_id", null: false
    t.uuid "finance_sheet_id"
    t.uuid "finance_transaction_type_id", null: false
    t.integer "generated_count", default: 0
    t.date "next_occurrence_date", null: false
    t.date "start_date", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "active"], name: "index_finance_recurring_transactions_on_account_id_and_active"
    t.index ["account_id"], name: "index_finance_recurring_transactions_on_account_id"
    t.index ["approver_id"], name: "index_finance_recurring_transactions_on_approver_id"
    t.index ["created_by_id"], name: "index_finance_recurring_transactions_on_created_by_id"
    t.index ["finance_category_id"], name: "index_finance_recurring_transactions_on_finance_category_id"
    t.index ["finance_payment_method_id"], name: "idx_on_finance_payment_method_id_6bd15908d1"
    t.index ["finance_recurrence_frequency_id"], name: "idx_on_finance_recurrence_frequency_id_4fa4217881"
    t.index ["finance_sheet_id"], name: "index_finance_recurring_transactions_on_finance_sheet_id"
    t.index ["finance_transaction_type_id"], name: "idx_on_finance_transaction_type_id_06ba5403d1"
    t.index ["next_occurrence_date", "active"], name: "idx_on_next_occurrence_date_active_fc52b7d02f"
  end

  create_table "finance_sheet_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "finance_sheet_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["finance_sheet_id"], name: "index_finance_sheet_favorites_on_finance_sheet_id"
    t.index ["user_id", "finance_sheet_id"], name: "index_finance_sheet_favorites_on_user_id_and_finance_sheet_id", unique: true
    t.index ["user_id"], name: "index_finance_sheet_favorites_on_user_id"
  end

  create_table "finance_sheet_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_finance_sheet_folders_unique_name", unique: true
    t.index ["account_id", "parent_folder_id"], name: "index_finance_sheet_folders_on_account_id_and_parent_folder_id"
    t.index ["account_id"], name: "index_finance_sheet_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_finance_sheet_folders_on_parent_folder_id"
  end

  create_table "finance_sheet_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "finance_sheet_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_2af15bf556"
    t.index ["account_id"], name: "index_finance_sheet_trash_items_on_account_id"
    t.index ["finance_sheet_id"], name: "index_finance_sheet_trash_items_on_finance_sheet_id", unique: true
    t.index ["original_folder_id"], name: "index_finance_sheet_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_finance_sheet_trash_items_on_trashed_by_id"
  end

  create_table "finance_sheets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "currency", default: "USD", null: false
    t.text "description"
    t.uuid "finance_sheet_folder_id"
    t.integer "finance_transactions_count", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_finance_sheets_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_finance_sheets_on_account_id"
    t.index ["created_by_id"], name: "index_finance_sheets_on_created_by_id"
    t.index ["finance_sheet_folder_id"], name: "index_finance_sheets_on_finance_sheet_folder_id"
  end

  create_table "finance_transaction_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color", default: "#6b7280", null: false
    t.datetime "created_at", null: false
    t.string "direction", null: false
    t.integer "finance_transactions_count", default: 0
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_finance_transaction_types_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_finance_transaction_types_on_account_id_and_position"
    t.index ["account_id"], name: "index_finance_transaction_types_on_account_id"
  end

  create_table "finance_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "currency", default: "USD", null: false
    t.text "description"
    t.uuid "finance_category_id"
    t.uuid "finance_payment_method_id"
    t.uuid "finance_payment_status_id"
    t.uuid "finance_sheet_id"
    t.uuid "finance_transaction_type_id", null: false
    t.uuid "recurring_source_id"
    t.string "reference_number"
    t.string "title", null: false
    t.date "transaction_date", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_finance_transactions_on_account_id_and_created_at"
    t.index ["account_id", "transaction_date"], name: "index_finance_transactions_on_account_id_and_transaction_date"
    t.index ["account_id"], name: "index_finance_transactions_on_account_id"
    t.index ["created_by_id"], name: "index_finance_transactions_on_created_by_id"
    t.index ["finance_category_id"], name: "index_finance_transactions_on_finance_category_id"
    t.index ["finance_payment_method_id"], name: "index_finance_transactions_on_finance_payment_method_id"
    t.index ["finance_payment_status_id"], name: "index_finance_transactions_on_finance_payment_status_id"
    t.index ["finance_sheet_id", "transaction_date"], name: "idx_finance_transactions_sheet_date"
    t.index ["finance_sheet_id"], name: "index_finance_transactions_on_finance_sheet_id"
    t.index ["finance_transaction_type_id"], name: "index_finance_transactions_on_finance_transaction_type_id"
    t.index ["recurring_source_id"], name: "index_finance_transactions_on_recurring_source_id"
  end

  create_table "generation_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "generation_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["generation_id"], name: "index_generation_favorites_on_generation_id"
    t.index ["user_id", "generation_id"], name: "index_generation_favorites_on_user_id_and_generation_id", unique: true
    t.index ["user_id"], name: "index_generation_favorites_on_user_id"
  end

  create_table "generation_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "generations_count", default: 0, null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_generation_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_generation_folders_on_account_id"
    t.index ["created_by_id"], name: "index_generation_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_generation_folders_on_parent_folder_id"
  end

  create_table "generation_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_generation_completed", default: true
    t.boolean "email_generation_failed", default: true
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_generation_notification_preferences_on_user_id", unique: true
  end

  create_table "generation_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_generation_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_generation_notification_readings_on_user_id"
  end

  create_table "generation_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_generation_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_generation_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_generation_notification_recipients_on_user_id"
  end

  create_table "generation_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "generation_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_55a50bae16"
    t.index ["account_id"], name: "index_generation_trash_items_on_account_id"
    t.index ["generation_id"], name: "index_generation_trash_items_on_generation_id", unique: true
    t.index ["original_folder_id"], name: "index_generation_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_generation_trash_items_on_trashed_by_id"
  end

  create_table "generations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "asset_id"
    t.bigint "cost_in_microcents", default: 0
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "error_message"
    t.uuid "generation_folder_id"
    t.integer "height", default: 1024
    t.jsonb "metadata", default: {}
    t.string "model", null: false
    t.text "negative_prompt"
    t.uuid "parent_generation_id"
    t.text "prompt", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "width", default: 1024
    t.index ["account_id", "created_at"], name: "index_generations_on_account_id_and_created_at"
    t.index ["account_id", "parent_generation_id"], name: "index_generations_on_account_id_and_parent_generation_id"
    t.index ["account_id"], name: "index_generations_on_account_id"
    t.index ["asset_id"], name: "index_generations_on_asset_id"
    t.index ["created_by_id"], name: "index_generations_on_created_by_id"
    t.index ["generation_folder_id"], name: "index_generations_on_generation_folder_id"
    t.index ["parent_generation_id"], name: "index_generations_on_parent_generation_id"
    t.index ["status"], name: "index_generations_on_status"
  end

  create_table "hr_attachment_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "hr_field_id", null: false
    t.uuid "hr_record_id", null: false
    t.datetime "updated_at", null: false
    t.index ["hr_field_id"], name: "index_hr_attachments_on_hr_field_id"
    t.index ["hr_record_id"], name: "index_hr_attachments_on_hr_record_id"
  end

  create_table "hr_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.integer "hr_fields_count", default: 0, null: false
    t.integer "hr_records_count", default: 0, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_hr_categories_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_hr_categories_on_account_id_and_position"
    t.index ["account_id"], name: "index_hr_categories_on_account_id"
    t.index ["created_by_id"], name: "index_hr_categories_on_created_by_id"
  end

  create_table "hr_checkbox_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_date_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_email_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_field_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "hr_field_id", null: false
    t.string "label", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["hr_field_id", "label"], name: "index_hr_field_options_on_hr_field_id_and_label", unique: true
    t.index ["hr_field_id", "position"], name: "index_hr_field_options_on_hr_field_id_and_position"
    t.index ["hr_field_id"], name: "index_hr_field_options_on_hr_field_id"
  end

  create_table "hr_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "fieldable_id", null: false
    t.string "fieldable_type", null: false
    t.uuid "hr_category_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["fieldable_type", "fieldable_id"], name: "index_hr_fields_on_fieldable_type_and_fieldable_id"
    t.index ["hr_category_id", "name"], name: "index_hr_fields_on_hr_category_id_and_name", unique: true
    t.index ["hr_category_id", "position"], name: "index_hr_fields_on_hr_category_id_and_position"
    t.index ["hr_category_id"], name: "index_hr_fields_on_hr_category_id"
  end

  create_table "hr_multi_select_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_number_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_phone_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "filled_by_id", null: false
    t.uuid "hr_category_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.jsonb "values", default: {}, null: false
    t.index ["filled_by_id"], name: "index_hr_records_on_filled_by_id"
    t.index ["hr_category_id", "user_id"], name: "index_hr_records_on_hr_category_id_and_user_id", unique: true
    t.index ["hr_category_id"], name: "index_hr_records_on_hr_category_id"
    t.index ["user_id"], name: "index_hr_records_on_user_id"
    t.index ["values"], name: "index_hr_records_on_values", using: :gin
  end

  create_table "hr_select_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_text_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hr_textarea_fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "identities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.boolean "superuser", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_identities_on_email_address", unique: true
  end

  create_table "individual_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "insurance_policies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.integer "coverage_tier", null: false
    t.datetime "created_at", null: false
    t.string "departure_country", limit: 2, null: false
    t.jsonb "destination_countries", default: [], null: false
    t.date "end_date", null: false
    t.integer "locality_coverage", null: false
    t.decimal "price_amount", precision: 10, scale: 2, null: false
    t.string "price_currency", limit: 3, default: "USD", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_insurance_policies_on_account_id"
    t.check_constraint "coverage_tier >= 1 AND coverage_tier <= 3", name: "chk_coverage_tier"
  end

  create_table "invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accepted_at"
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", null: false
    t.uuid "inviter_id", null: false
    t.string "role", default: "member", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_invites_on_account_id_and_email", unique: true, where: "(accepted_at IS NULL)"
    t.index ["account_id"], name: "index_invites_on_account_id"
    t.index ["inviter_id"], name: "index_invites_on_inviter_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
  end

  create_table "invoice_cancellations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cancelled_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "invoice_id", null: false
    t.text "reason"
    t.datetime "updated_at", null: false
    t.index ["cancelled_by_id"], name: "index_invoice_cancellations_on_cancelled_by_id"
    t.index ["invoice_id"], name: "index_invoice_cancellations_on_invoice_id", unique: true
  end

  create_table "invoice_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invoice_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["invoice_id"], name: "index_invoice_favorites_on_invoice_id"
    t.index ["user_id", "invoice_id"], name: "index_invoice_favorites_on_user_id_and_invoice_id", unique: true
    t.index ["user_id"], name: "index_invoice_favorites_on_user_id"
  end

  create_table "invoice_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_invoice_folders_unique_name", unique: true
    t.index ["account_id", "parent_folder_id"], name: "index_invoice_folders_on_account_id_and_parent_folder_id"
    t.index ["account_id"], name: "index_invoice_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_invoice_folders_on_parent_folder_id"
  end

  create_table "invoice_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.uuid "invoice_id", null: false
    t.integer "position", default: 0, null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0", null: false
    t.decimal "unit_price", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "position"], name: "index_invoice_items_on_invoice_id_and_position"
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoice_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.uuid "invoice_id", null: false
    t.text "notes"
    t.date "payment_date", null: false
    t.string "payment_method"
    t.uuid "recorded_by_id", null: false
    t.string "reference"
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "payment_date"], name: "index_invoice_payments_on_invoice_id_and_payment_date"
    t.index ["invoice_id"], name: "index_invoice_payments_on_invoice_id"
    t.index ["recorded_by_id"], name: "index_invoice_payments_on_recorded_by_id"
  end

  create_table "invoice_sendings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invoice_id", null: false
    t.string "method", default: "email", null: false
    t.uuid "sent_by_id", null: false
    t.string "sent_to_email", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_sendings_on_invoice_id", unique: true
    t.index ["sent_by_id"], name: "index_invoice_sendings_on_sent_by_id"
  end

  create_table "invoice_taxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.uuid "invoice_id", null: false
    t.uuid "invoicing_tax_rate_id"
    t.string "name", null: false
    t.decimal "rate", precision: 6, scale: 3, null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_taxes_on_invoice_id"
    t.index ["invoicing_tax_rate_id"], name: "index_invoice_taxes_on_invoicing_tax_rate_id"
  end

  create_table "invoice_tranches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "amount_type", null: false
    t.decimal "amount_value", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.date "due_date"
    t.uuid "invoice_id", null: false
    t.integer "position", default: 0, null: false
    t.decimal "resolved_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "position"], name: "index_invoice_tranches_on_invoice_id_and_position"
    t.index ["invoice_id"], name: "index_invoice_tranches_on_invoice_id"
  end

  create_table "invoice_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "invoice_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_ab78374e11"
    t.index ["account_id"], name: "index_invoice_trash_items_on_account_id"
    t.index ["invoice_id"], name: "index_invoice_trash_items_on_invoice_id", unique: true
    t.index ["original_folder_id"], name: "index_invoice_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_invoice_trash_items_on_trashed_by_id"
  end

  create_table "invoices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.decimal "amount_paid", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "currency", default: "USD", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.date "due_date", null: false
    t.uuid "invoice_folder_id"
    t.integer "invoice_items_count", default: 0, null: false
    t.string "invoice_number", null: false
    t.integer "invoice_payments_count", default: 0, null: false
    t.integer "invoice_taxes_count", default: 0, null: false
    t.integer "invoice_tranches_count", default: 0, null: false
    t.uuid "invoicing_client_id", null: false
    t.uuid "invoicing_organization_id", null: false
    t.date "issue_date", null: false
    t.text "notes"
    t.string "reference"
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_total", precision: 12, scale: 2, default: "0.0", null: false
    t.text "terms"
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_invoices_on_account_id_and_created_at"
    t.index ["account_id", "due_date"], name: "index_invoices_on_account_id_and_due_date"
    t.index ["account_id", "invoice_number"], name: "index_invoices_on_account_id_and_invoice_number", unique: true
    t.index ["account_id", "issue_date"], name: "index_invoices_on_account_id_and_issue_date"
    t.index ["account_id"], name: "index_invoices_on_account_id"
    t.index ["created_by_id"], name: "index_invoices_on_created_by_id"
    t.index ["invoice_folder_id"], name: "index_invoices_on_invoice_folder_id"
    t.index ["invoicing_client_id"], name: "index_invoices_on_invoicing_client_id"
    t.index ["invoicing_organization_id"], name: "index_invoices_on_invoicing_organization_id"
  end

  create_table "invoicing_bank_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "account_holder_name"
    t.string "account_number"
    t.string "bank_name"
    t.datetime "created_at", null: false
    t.string "iban"
    t.uuid "invoicing_organization_id", null: false
    t.boolean "is_default", default: false, null: false
    t.string "label", null: false
    t.string "routing_number"
    t.string "swift_code"
    t.datetime "updated_at", null: false
    t.index ["invoicing_organization_id", "is_default"], name: "idx_bank_details_org_default"
    t.index ["invoicing_organization_id"], name: "index_invoicing_bank_details_on_invoicing_organization_id"
  end

  create_table "invoicing_client_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invoicing_client_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["invoicing_client_id"], name: "index_invoicing_client_favorites_on_invoicing_client_id"
    t.index ["user_id", "invoicing_client_id"], name: "idx_inv_client_favorites_unique", unique: true
    t.index ["user_id"], name: "index_invoicing_client_favorites_on_user_id"
  end

  create_table "invoicing_client_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_inv_client_folders_unique_name", unique: true
    t.index ["account_id", "parent_folder_id"], name: "idx_on_account_id_parent_folder_id_196003602a"
    t.index ["account_id"], name: "index_invoicing_client_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_invoicing_client_folders_on_parent_folder_id"
  end

  create_table "invoicing_client_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "invoicing_client_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_inv_client_trash_perm_delete"
    t.index ["account_id"], name: "index_invoicing_client_trash_items_on_account_id"
    t.index ["invoicing_client_id"], name: "idx_inv_client_trash_unique", unique: true
    t.index ["original_folder_id"], name: "index_invoicing_client_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_invoicing_client_trash_items_on_trashed_by_id"
  end

  create_table "invoicing_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "email"
    t.integer "invoices_count", default: 0, null: false
    t.uuid "invoicing_client_folder_id"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.string "postal_code"
    t.string "state"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["account_id", "name"], name: "index_invoicing_clients_on_account_id_and_name"
    t.index ["account_id"], name: "index_invoicing_clients_on_account_id"
    t.index ["created_by_id"], name: "index_invoicing_clients_on_created_by_id"
    t.index ["invoicing_client_folder_id"], name: "index_invoicing_clients_on_invoicing_client_folder_id"
  end

  create_table "invoicing_organization_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invoicing_organization_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["invoicing_organization_id"], name: "idx_on_invoicing_organization_id_e8f67d90b0"
    t.index ["user_id", "invoicing_organization_id"], name: "idx_inv_org_favorites_unique", unique: true
    t.index ["user_id"], name: "index_invoicing_organization_favorites_on_user_id"
  end

  create_table "invoicing_organization_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_inv_org_folders_unique_name", unique: true
    t.index ["account_id", "parent_folder_id"], name: "idx_on_account_id_parent_folder_id_78310363c2"
    t.index ["account_id"], name: "index_invoicing_organization_folders_on_account_id"
    t.index ["parent_folder_id"], name: "index_invoicing_organization_folders_on_parent_folder_id"
  end

  create_table "invoicing_organization_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "invoicing_organization_id", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_inv_org_trash_perm_delete"
    t.index ["account_id"], name: "index_invoicing_organization_trash_items_on_account_id"
    t.index ["invoicing_organization_id"], name: "idx_inv_org_trash_unique", unique: true
    t.index ["original_folder_id"], name: "index_invoicing_organization_trash_items_on_original_folder_id"
    t.index ["trashed_by_id"], name: "index_invoicing_organization_trash_items_on_trashed_by_id"
  end

  create_table "invoicing_organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "default_currency", default: "USD", null: false
    t.text "default_notes"
    t.integer "default_payment_terms_days", default: 30, null: false
    t.string "email"
    t.integer "invoices_count", default: 0, null: false
    t.uuid "invoicing_organization_folder_id"
    t.string "name", null: false
    t.string "phone"
    t.string "postal_code"
    t.string "preferred_color", default: "#3b82f6"
    t.string "state"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["account_id", "name"], name: "index_invoicing_organizations_on_account_id_and_name"
    t.index ["account_id"], name: "index_invoicing_organizations_on_account_id"
    t.index ["created_by_id"], name: "index_invoicing_organizations_on_created_by_id"
    t.index ["invoicing_organization_folder_id"], name: "idx_on_invoicing_organization_folder_id_eda43812ef"
  end

  create_table "invoicing_payment_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "invoicing_organization_id", null: false
    t.boolean "is_default", default: false, null: false
    t.string "label", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["invoicing_organization_id"], name: "index_invoicing_payment_links_on_invoicing_organization_id"
  end

  create_table "invoicing_tax_rates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "description"
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.decimal "rate", precision: 6, scale: 3, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_invoicing_tax_rates_on_account_id_and_name"
    t.index ["account_id"], name: "index_invoicing_tax_rates_on_account_id"
    t.index ["created_by_id"], name: "index_invoicing_tax_rates_on_created_by_id"
  end

  create_table "magic_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.uuid "identity_id", null: false
    t.string "purpose", default: "sign_in"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_magic_links_on_code", unique: true
    t.index ["expires_at"], name: "index_magic_links_on_expires_at"
    t.index ["identity_id"], name: "index_magic_links_on_identity_id"
  end

  create_table "management_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "manager_id", null: false
    t.uuid "report_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "manager_id"], name: "index_management_records_on_account_id_and_manager_id"
    t.index ["account_id", "report_id"], name: "index_management_records_on_account_id_and_report_id", unique: true
    t.index ["account_id"], name: "index_management_records_on_account_id"
    t.index ["created_by_id"], name: "index_management_records_on_created_by_id"
    t.index ["manager_id"], name: "index_management_records_on_manager_id"
    t.index ["report_id"], name: "index_management_records_on_report_id"
  end

  create_table "okr_boolean_key_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "okr_check_ins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "confidence", default: "on_track", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.jsonb "note", default: [], null: false
    t.uuid "okr_key_result_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 15, scale: 2, null: false
    t.index ["created_by_id"], name: "index_okr_check_ins_on_created_by_id"
    t.index ["okr_key_result_id", "created_at"], name: "index_okr_check_ins_on_okr_key_result_id_and_created_at"
    t.index ["okr_key_result_id"], name: "index_okr_check_ins_on_okr_key_result_id"
  end

  create_table "okr_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "commentable_id", null: false
    t.string "commentable_type", null: false
    t.jsonb "content", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["commentable_type", "commentable_id", "created_at"], name: "index_okr_comments_on_commentable_and_created_at"
    t.index ["commentable_type", "commentable_id"], name: "index_okr_comments_on_commentable"
    t.index ["user_id"], name: "index_okr_comments_on_user_id"
  end

  create_table "okr_currency_key_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency_code", default: "USD", null: false
    t.string "direction", default: "higher_is_better", null: false
    t.datetime "updated_at", null: false
  end

  create_table "okr_duration_key_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "lower_is_better", null: false
    t.string "unit_label", default: "hours", null: false
    t.datetime "updated_at", null: false
  end

  create_table "okr_key_result_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "completed_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "okr_key_result_id", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_by_id"], name: "index_okr_key_result_completions_on_completed_by_id"
    t.index ["okr_key_result_id"], name: "index_okr_key_result_completions_on_okr_key_result_id", unique: true
  end

  create_table "okr_key_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.jsonb "description", default: [], null: false
    t.uuid "measurable_id"
    t.string "measurable_type"
    t.string "measurement_type", default: "percentage", null: false
    t.integer "okr_check_ins_count", default: 0, null: false
    t.integer "okr_comments_count", default: 0, null: false
    t.uuid "okr_objective_id", null: false
    t.uuid "owner_id", null: false
    t.integer "position", default: 0, null: false
    t.decimal "start_value", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "target_value", precision: 15, scale: 2, default: "100.0", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_okr_key_results_on_created_by_id"
    t.index ["measurable_type", "measurable_id"], name: "index_okr_key_results_on_measurable_type_and_measurable_id"
    t.index ["okr_objective_id", "position"], name: "index_okr_key_results_on_okr_objective_id_and_position"
    t.index ["okr_objective_id"], name: "index_okr_key_results_on_okr_objective_id"
    t.index ["owner_id"], name: "index_okr_key_results_on_owner_id"
  end

  create_table "okr_manager_reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "assessment", default: "on_track", null: false
    t.jsonb "content", default: []
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "okr_comments_count", default: 0, null: false
    t.uuid "okr_objective_id", null: false
    t.uuid "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_okr_manager_reviews_on_created_by_id"
    t.index ["okr_objective_id"], name: "index_okr_manager_reviews_on_okr_objective_id", unique: true
    t.index ["reviewer_id"], name: "index_okr_manager_reviews_on_reviewer_id"
  end

  create_table "okr_mentions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "mentioned_user_id", null: false
    t.uuid "okr_check_in_id"
    t.uuid "okr_comment_id"
    t.uuid "okr_key_result_id"
    t.uuid "okr_objective_id"
    t.datetime "updated_at", null: false
    t.index ["mentioned_user_id", "created_at"], name: "index_okr_mentions_on_mentioned_user_id_and_created_at"
    t.index ["mentioned_user_id"], name: "index_okr_mentions_on_mentioned_user_id"
    t.index ["okr_check_in_id"], name: "index_okr_mentions_on_okr_check_in_id"
    t.index ["okr_comment_id"], name: "index_okr_mentions_on_okr_comment_id"
    t.index ["okr_key_result_id"], name: "index_okr_mentions_on_okr_key_result_id"
    t.index ["okr_objective_id"], name: "index_okr_mentions_on_okr_objective_id"
  end

  create_table "okr_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_okr_check_in", default: true, null: false
    t.boolean "email_okr_comment", default: true, null: false
    t.boolean "email_okr_key_result_completion", default: true, null: false
    t.boolean "email_okr_manager_review", default: true, null: false
    t.boolean "email_okr_mention", default: true, null: false
    t.boolean "email_okr_objective_completion", default: true, null: false
    t.boolean "email_okr_self_review", default: true, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_okr_notification_preferences_on_user_id", unique: true
  end

  create_table "okr_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_okr_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_okr_notification_readings_on_user_id"
  end

  create_table "okr_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_okr_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_okr_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_okr_notification_recipients_on_user_id"
  end

  create_table "okr_number_key_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "higher_is_better", null: false
    t.string "unit_label"
    t.datetime "updated_at", null: false
  end

  create_table "okr_objective_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "completed_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "okr_objective_id", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_by_id"], name: "index_okr_objective_completions_on_completed_by_id"
    t.index ["okr_objective_id"], name: "index_okr_objective_completions_on_okr_objective_id", unique: true
  end

  create_table "okr_objective_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "okr_objective_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["okr_objective_id", "user_id"], name: "index_okr_objective_favorites_on_okr_objective_id_and_user_id", unique: true
    t.index ["okr_objective_id"], name: "index_okr_objective_favorites_on_okr_objective_id"
    t.index ["user_id"], name: "index_okr_objective_favorites_on_user_id"
  end

  create_table "okr_objectives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.jsonb "description", default: [], null: false
    t.integer "okr_comments_count", default: 0, null: false
    t.integer "okr_key_results_count", default: 0, null: false
    t.uuid "okr_period_id", null: false
    t.uuid "owner_id", null: false
    t.uuid "parent_id"
    t.integer "position", default: 0, null: false
    t.string "scope", default: "individual", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "owner_id"], name: "index_okr_objectives_on_account_id_and_owner_id"
    t.index ["account_id"], name: "index_okr_objectives_on_account_id"
    t.index ["created_by_id"], name: "index_okr_objectives_on_created_by_id"
    t.index ["okr_period_id", "position"], name: "index_okr_objectives_on_okr_period_id_and_position"
    t.index ["okr_period_id"], name: "index_okr_objectives_on_okr_period_id"
    t.index ["owner_id"], name: "index_okr_objectives_on_owner_id"
    t.index ["parent_id"], name: "index_okr_objectives_on_parent_id"
  end

  create_table "okr_percentage_key_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "higher_is_better", null: false
    t.datetime "updated_at", null: false
  end

  create_table "okr_period_activations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "activated_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "okr_period_id", null: false
    t.datetime "updated_at", null: false
    t.index ["activated_by_id"], name: "index_okr_period_activations_on_activated_by_id"
    t.index ["okr_period_id"], name: "index_okr_period_activations_on_okr_period_id", unique: true
  end

  create_table "okr_period_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "archived_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "okr_period_id", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_by_id"], name: "index_okr_period_archives_on_archived_by_id"
    t.index ["okr_period_id"], name: "index_okr_period_archives_on_okr_period_id", unique: true
  end

  create_table "okr_period_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "okr_period_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["okr_period_id", "user_id"], name: "index_okr_period_favorites_on_okr_period_id_and_user_id", unique: true
    t.index ["okr_period_id"], name: "index_okr_period_favorites_on_okr_period_id"
    t.index ["user_id"], name: "index_okr_period_favorites_on_user_id"
  end

  create_table "okr_period_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "name", null: false
    t.integer "okr_period_folders_count", default: 0, null: false
    t.integer "okr_periods_count", default: 0, null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_on_account_id_parent_folder_id_name_cba3270093", unique: true
    t.index ["account_id", "parent_folder_id"], name: "index_okr_period_folders_on_account_id_and_parent_folder_id"
    t.index ["account_id"], name: "index_okr_period_folders_on_account_id"
    t.index ["created_by_id"], name: "index_okr_period_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_okr_period_folders_on_parent_folder_id"
  end

  create_table "okr_periods", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "cadence", default: "weekly", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.date "end_date", null: false
    t.string "name", null: false
    t.integer "okr_objectives_count", default: 0, null: false
    t.uuid "okr_period_folder_id"
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "start_date"], name: "index_okr_periods_on_account_id_and_start_date"
    t.index ["account_id"], name: "index_okr_periods_on_account_id"
    t.index ["created_by_id"], name: "index_okr_periods_on_created_by_id"
    t.index ["okr_period_folder_id"], name: "index_okr_periods_on_okr_period_folder_id"
  end

  create_table "okr_review_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "okr_review_question_id", null: false
    t.uuid "reviewable_id", null: false
    t.string "reviewable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_okr_review_answers_on_created_by_id"
    t.index ["okr_review_question_id", "reviewable_type", "reviewable_id"], name: "idx_okr_review_answers_uniqueness", unique: true
    t.index ["okr_review_question_id"], name: "index_okr_review_answers_on_okr_review_question_id"
    t.index ["reviewable_type", "reviewable_id"], name: "idx_okr_review_answers_on_reviewable"
  end

  create_table "okr_review_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "position", default: 0, null: false
    t.string "question_text", null: false
    t.string "review_type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "review_type", "position"], name: "idx_on_account_id_review_type_position_1c48471726"
    t.index ["account_id"], name: "index_okr_review_questions_on_account_id"
    t.index ["created_by_id"], name: "index_okr_review_questions_on_created_by_id"
  end

  create_table "okr_self_reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "assessment", default: "on_track", null: false
    t.jsonb "content", default: []
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "okr_comments_count", default: 0, null: false
    t.uuid "okr_objective_id", null: false
    t.uuid "reviewer_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_okr_self_reviews_on_created_by_id"
    t.index ["okr_objective_id"], name: "index_okr_self_reviews_on_okr_objective_id", unique: true
    t.index ["reviewer_id"], name: "index_okr_self_reviews_on_reviewer_id"
  end

  create_table "okr_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashable_id", null: false
    t.string "trashable_type", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_okr_trash_items_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_okr_trash_items_on_account_id"
    t.index ["original_folder_id"], name: "index_okr_trash_items_on_original_folder_id"
    t.index ["permanently_delete_at"], name: "index_okr_trash_items_on_permanently_delete_at"
    t.index ["trashable_type", "trashable_id"], name: "index_okr_trash_items_on_trashable_type_and_trashable_id"
    t.index ["trashed_by_id"], name: "index_okr_trash_items_on_trashed_by_id"
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "design_id", null: false
    t.string "name"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["design_id", "position"], name: "index_pages_on_design_id_and_position"
    t.index ["design_id"], name: "index_pages_on_design_id"
  end

  create_table "people_log_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.string "icon"
    t.string "name", null: false
    t.integer "people_logs_count", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.boolean "requires_approval", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_people_log_categories_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_people_log_categories_on_account_id_and_position"
    t.index ["account_id"], name: "index_people_log_categories_on_account_id"
    t.index ["created_by_id"], name: "index_people_log_categories_on_created_by_id"
  end

  create_table "people_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.uuid "logged_by_id", null: false
    t.text "notes"
    t.uuid "people_log_category_id", null: false
    t.datetime "reviewed_at"
    t.uuid "reviewed_by_id"
    t.date "start_date", null: false
    t.string "status", default: "approved", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id", "people_log_category_id"], name: "index_people_logs_on_account_id_and_people_log_category_id"
    t.index ["account_id", "start_date"], name: "index_people_logs_on_account_id_and_start_date"
    t.index ["account_id", "status"], name: "index_people_logs_on_account_id_and_status"
    t.index ["account_id", "user_id"], name: "index_people_logs_on_account_id_and_user_id"
    t.index ["account_id"], name: "index_people_logs_on_account_id"
    t.index ["logged_by_id"], name: "index_people_logs_on_logged_by_id"
    t.index ["people_log_category_id"], name: "index_people_logs_on_people_log_category_id"
    t.index ["reviewed_by_id"], name: "index_people_logs_on_reviewed_by_id"
    t.index ["user_id"], name: "index_people_logs_on_user_id"
  end

  create_table "policy_completeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "pdf_path", limit: 512, null: false
    t.uuid "policy_id", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_completeds_on_policy_id"
  end

  create_table "policy_contract_confirmeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "insurs_order_id", null: false
    t.uuid "policy_id", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_contract_confirmeds_on_policy_id"
  end

  create_table "policy_contract_createds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "insurs_order_id", null: false
    t.string "insurs_police_num", null: false
    t.uuid "policy_id", null: false
    t.string "total_amount", limit: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_contract_createds_on_policy_id"
  end

  create_table "policy_faileds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.text "error_message", null: false
    t.string "failed_step", limit: 100, null: false
    t.uuid "policy_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_policy_faileds_on_created_by_id"
    t.index ["policy_id"], name: "index_policy_faileds_on_policy_id"
  end

  create_table "policy_payment_receiveds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount_received", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, null: false
    t.uuid "policy_id", null: false
    t.string "stripe_checkout_session_id", null: false
    t.string "stripe_payment_intent_id", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_payment_receiveds_on_policy_id"
  end

  create_table "policy_pending_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "policy_id", null: false
    t.string "stripe_checkout_session_id", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_pending_payments_on_policy_id"
  end

  create_table "policy_refund_initiateds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "initiated_by_id", null: false
    t.uuid "policy_id", null: false
    t.text "reason", null: false
    t.string "stripe_payment_intent_id", null: false
    t.datetime "updated_at", null: false
    t.index ["initiated_by_id"], name: "index_policy_refund_initiateds_on_initiated_by_id"
    t.index ["policy_id"], name: "index_policy_refund_initiateds_on_policy_id"
  end

  create_table "policy_refundeds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount_refunded", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.uuid "policy_id", null: false
    t.string "stripe_refund_id", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_policy_refundeds_on_policy_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.boolean "published"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "project_archives", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "archived_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["archived_by_id"], name: "index_project_archives_on_archived_by_id"
    t.index ["project_id"], name: "index_project_archives_on_project_id", unique: true
  end

  create_table "project_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "project_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["project_id"], name: "index_project_favorites_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_favorites_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_favorites_on_user_id"
  end

  create_table "project_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.integer "projects_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_project_folders_unique_name", unique: true
    t.index ["account_id"], name: "index_project_folders_on_account_id"
    t.index ["created_by_id"], name: "index_project_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_project_folders_on_parent_folder_id"
  end

  create_table "project_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "project_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["project_id", "user_id"], name: "index_project_memberships_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_project_memberships_on_project_id"
    t.index ["user_id"], name: "index_project_memberships_on_user_id"
  end

  create_table "project_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_task_assigned", default: true, null: false
    t.boolean "email_task_cancelled", default: true, null: false
    t.boolean "email_task_commented", default: true, null: false
    t.boolean "email_task_completed", default: true, null: false
    t.boolean "email_task_mentioned", default: true, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_project_notification_preferences_on_user_id", unique: true
  end

  create_table "project_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_project_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_project_notification_readings_on_user_id"
  end

  create_table "project_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_project_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_project_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_project_notification_recipients_on_user_id"
  end

  create_table "project_statuses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.uuid "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "position"], name: "index_project_statuses_on_project_id_and_position"
    t.index ["project_id"], name: "index_project_statuses_on_project_id"
  end

  create_table "project_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "name"], name: "index_project_tags_on_project_id_and_name", unique: true
    t.index ["project_id"], name: "index_project_tags_on_project_id"
  end

  create_table "project_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "project_id", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_on_account_id_permanently_delete_at_1d454ad45c"
    t.index ["account_id"], name: "index_project_trash_items_on_account_id"
    t.index ["original_folder_id"], name: "index_project_trash_items_on_original_folder_id"
    t.index ["project_id"], name: "index_project_trash_items_on_project_id", unique: true
    t.index ["trashed_by_id"], name: "index_project_trash_items_on_trashed_by_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.uuid "project_folder_id"
    t.integer "tasks_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "updated_at"], name: "index_projects_on_account_id_and_updated_at"
    t.index ["account_id"], name: "index_projects_on_account_id"
    t.index ["created_by_id"], name: "index_projects_on_created_by_id"
    t.index ["project_folder_id"], name: "index_projects_on_project_folder_id"
  end

  create_table "publications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "design_id", null: false
    t.uuid "published_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id"], name: "index_publications_on_design_id", unique: true
    t.index ["published_by_id"], name: "index_publications_on_published_by_id"
  end

  create_table "rejections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "approval_submission_id", null: false
    t.datetime "created_at", null: false
    t.string "reason", null: false
    t.uuid "rejected_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_submission_id"], name: "index_rejections_on_approval_submission_id", unique: true
    t.index ["rejected_by_id"], name: "index_rejections_on_rejected_by_id"
  end

  create_table "scorecard_assignment_edits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.jsonb "changes_made", default: {}, null: false
    t.datetime "created_at", null: false
    t.uuid "edited_by_id", null: false
    t.uuid "scorecard_assignment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_scorecard_assignment_edits_on_account_id"
    t.index ["edited_by_id"], name: "index_scorecard_assignment_edits_on_edited_by_id"
    t.index ["scorecard_assignment_id"], name: "index_scorecard_assignment_edits_on_scorecard_assignment_id"
  end

  create_table "scorecard_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true
    t.uuid "assigned_by_id", null: false
    t.datetime "created_at", null: false
    t.decimal "custom_target", precision: 15, scale: 2
    t.integer "position", default: 0
    t.uuid "scorecard_id", null: false
    t.uuid "scorecard_metric_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_scorecard_assignments_on_assigned_by_id"
    t.index ["scorecard_id", "position"], name: "index_scorecard_assignments_on_scorecard_id_and_position"
    t.index ["scorecard_id", "scorecard_metric_id"], name: "idx_on_scorecard_id_scorecard_metric_id_e3d0447a3d", unique: true
    t.index ["scorecard_id"], name: "index_scorecard_assignments_on_scorecard_id"
    t.index ["scorecard_metric_id"], name: "index_scorecard_assignments_on_scorecard_metric_id"
  end

  create_table "scorecard_boolean_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scorecard_cadences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "interval", default: 1
    t.string "name", null: false
    t.string "period", null: false
    t.integer "position", default: 0
    t.integer "scorecard_metrics_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_scorecard_cadences_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_scorecard_cadences_on_account_id_and_position"
    t.index ["account_id"], name: "index_scorecard_cadences_on_account_id"
  end

  create_table "scorecard_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "commentable_id", null: false
    t.string "commentable_type", null: false
    t.jsonb "content", default: []
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["commentable_type", "commentable_id", "created_at"], name: "idx_on_commentable_type_commentable_id_created_at_056ce1d128"
    t.index ["user_id"], name: "index_scorecard_comments_on_user_id"
  end

  create_table "scorecard_currency_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "currency_code", default: "USD", null: false
    t.string "direction", default: "higher_is_better", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scorecard_cycles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.string "name", null: false
    t.uuid "scorecard_cadence_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "scorecard_cadence_id", "start_date"], name: "idx_on_account_id_scorecard_cadence_id_start_date_a64b0ff6b2", unique: true
    t.index ["account_id"], name: "index_scorecard_cycles_on_account_id"
    t.index ["scorecard_cadence_id"], name: "index_scorecard_cycles_on_scorecard_cadence_id"
  end

  create_table "scorecard_duration_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "lower_is_better", null: false
    t.string "unit_label", default: "hours", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scorecard_entries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "note"
    t.boolean "on_track"
    t.uuid "scorecard_assignment_id", null: false
    t.integer "scorecard_comments_count", default: 0, null: false
    t.uuid "scorecard_cycle_id", null: false
    t.decimal "target_snapshot", precision: 15, scale: 2
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 15, scale: 2, null: false
    t.index ["created_by_id"], name: "index_scorecard_entries_on_created_by_id"
    t.index ["scorecard_assignment_id", "scorecard_cycle_id"], name: "idx_on_scorecard_assignment_id_scorecard_cycle_id_5b964cf91c", unique: true
    t.index ["scorecard_assignment_id"], name: "index_scorecard_entries_on_scorecard_assignment_id"
    t.index ["scorecard_cycle_id"], name: "index_scorecard_entries_on_scorecard_cycle_id"
  end

  create_table "scorecard_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "scorecard_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["scorecard_id", "user_id"], name: "index_scorecard_favorites_on_scorecard_id_and_user_id", unique: true
    t.index ["scorecard_id"], name: "index_scorecard_favorites_on_scorecard_id"
    t.index ["user_id"], name: "index_scorecard_favorites_on_user_id"
  end

  create_table "scorecard_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0
    t.integer "scorecard_folders_count", default: 0, null: false
    t.integer "scorecards_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_on_account_id_parent_folder_id_name_5a94fd50b1", unique: true
    t.index ["account_id", "parent_folder_id"], name: "index_scorecard_folders_on_account_id_and_parent_folder_id"
    t.index ["account_id"], name: "index_scorecard_folders_on_account_id"
    t.index ["created_by_id"], name: "index_scorecard_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_scorecard_folders_on_parent_folder_id"
  end

  create_table "scorecard_manager_reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "assessment", default: "on_track", null: false
    t.jsonb "content", default: []
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "reviewer_id", null: false
    t.integer "scorecard_comments_count", default: 0, null: false
    t.uuid "scorecard_cycle_id", null: false
    t.uuid "scorecard_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_scorecard_manager_reviews_on_created_by_id"
    t.index ["reviewer_id"], name: "index_scorecard_manager_reviews_on_reviewer_id"
    t.index ["scorecard_cycle_id"], name: "index_scorecard_manager_reviews_on_scorecard_cycle_id"
    t.index ["scorecard_id", "scorecard_cycle_id"], name: "idx_on_scorecard_id_scorecard_cycle_id_8bb46df6c3", unique: true
    t.index ["scorecard_id"], name: "index_scorecard_manager_reviews_on_scorecard_id"
  end

  create_table "scorecard_mentions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "mentioned_user_id", null: false
    t.uuid "scorecard_comment_id"
    t.uuid "scorecard_entry_id"
    t.uuid "scorecard_manager_review_id"
    t.uuid "scorecard_self_review_id"
    t.datetime "updated_at", null: false
    t.index ["mentioned_user_id", "created_at"], name: "index_scorecard_mentions_on_mentioned_user_id_and_created_at"
    t.index ["mentioned_user_id"], name: "index_scorecard_mentions_on_mentioned_user_id"
    t.index ["scorecard_comment_id"], name: "index_scorecard_mentions_on_scorecard_comment_id"
    t.index ["scorecard_entry_id"], name: "index_scorecard_mentions_on_scorecard_entry_id"
    t.index ["scorecard_manager_review_id"], name: "index_scorecard_mentions_on_scorecard_manager_review_id"
    t.index ["scorecard_self_review_id"], name: "index_scorecard_mentions_on_scorecard_self_review_id"
  end

  create_table "scorecard_metric_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "icon"
    t.string "name", null: false
    t.integer "position", default: 0
    t.integer "scorecard_metrics_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_scorecard_metric_categories_on_account_id_and_name", unique: true
    t.index ["account_id", "position"], name: "index_scorecard_metric_categories_on_account_id_and_position"
    t.index ["account_id"], name: "index_scorecard_metric_categories_on_account_id"
    t.index ["created_by_id"], name: "index_scorecard_metric_categories_on_created_by_id"
  end

  create_table "scorecard_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.decimal "default_target", precision: 15, scale: 2
    t.text "description"
    t.uuid "measurable_id"
    t.string "measurable_type"
    t.string "name", null: false
    t.integer "position", default: 0
    t.integer "scorecard_assignments_count", default: 0, null: false
    t.uuid "scorecard_cadence_id", null: false
    t.uuid "scorecard_metric_category_id"
    t.datetime "updated_at", null: false
    t.index ["account_id", "archived_at"], name: "index_scorecard_metrics_on_account_id_and_archived_at"
    t.index ["account_id", "position"], name: "index_scorecard_metrics_on_account_id_and_position"
    t.index ["account_id"], name: "index_scorecard_metrics_on_account_id"
    t.index ["created_by_id"], name: "index_scorecard_metrics_on_created_by_id"
    t.index ["measurable_type", "measurable_id"], name: "index_scorecard_metrics_on_measurable_type_and_measurable_id"
    t.index ["scorecard_cadence_id"], name: "index_scorecard_metrics_on_scorecard_cadence_id"
    t.index ["scorecard_metric_category_id"], name: "index_scorecard_metrics_on_scorecard_metric_category_id"
  end

  create_table "scorecard_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_scorecard_assignment", default: true, null: false
    t.boolean "email_scorecard_comment", default: true, null: false
    t.boolean "email_scorecard_entry", default: true, null: false
    t.boolean "email_scorecard_manager_review", default: true, null: false
    t.boolean "email_scorecard_mention", default: true, null: false
    t.boolean "email_scorecard_self_review", default: true, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_scorecard_notification_preferences_on_user_id", unique: true
  end

  create_table "scorecard_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_scorecard_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_scorecard_notification_readings_on_user_id"
  end

  create_table "scorecard_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_scorecard_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_scorecard_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_scorecard_notification_recipients_on_user_id"
  end

  create_table "scorecard_number_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "higher_is_better", null: false
    t.string "unit_label"
    t.datetime "updated_at", null: false
  end

  create_table "scorecard_percentage_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "direction", default: "higher_is_better", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scorecard_review_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "reviewable_id", null: false
    t.string "reviewable_type", null: false
    t.uuid "scorecard_review_question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_scorecard_review_answers_on_created_by_id"
    t.index ["reviewable_type", "reviewable_id"], name: "idx_scorecard_review_answers_on_reviewable"
    t.index ["scorecard_review_question_id", "reviewable_type", "reviewable_id"], name: "idx_scorecard_review_answers_uniqueness", unique: true
    t.index ["scorecard_review_question_id"], name: "index_scorecard_review_answers_on_scorecard_review_question_id"
  end

  create_table "scorecard_review_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "position", default: 0, null: false
    t.string "question_text", null: false
    t.string "review_type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "review_type", "position"], name: "idx_on_account_id_review_type_position_7394b2f1d6"
    t.index ["account_id"], name: "index_scorecard_review_questions_on_account_id"
    t.index ["created_by_id"], name: "index_scorecard_review_questions_on_created_by_id"
  end

  create_table "scorecard_self_reviews", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "assessment", default: "on_track", null: false
    t.jsonb "content", default: []
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.uuid "reviewer_id", null: false
    t.integer "scorecard_comments_count", default: 0, null: false
    t.uuid "scorecard_cycle_id", null: false
    t.uuid "scorecard_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_scorecard_self_reviews_on_created_by_id"
    t.index ["reviewer_id"], name: "index_scorecard_self_reviews_on_reviewer_id"
    t.index ["scorecard_cycle_id"], name: "index_scorecard_self_reviews_on_scorecard_cycle_id"
    t.index ["scorecard_id", "scorecard_cycle_id"], name: "idx_on_scorecard_id_scorecard_cycle_id_53d5177d4e", unique: true
    t.index ["scorecard_id"], name: "index_scorecard_self_reviews_on_scorecard_id"
  end

  create_table "scorecard_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashable_id", null: false
    t.string "trashable_type", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_scorecard_trash_items_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_scorecard_trash_items_on_account_id"
    t.index ["original_folder_id"], name: "index_scorecard_trash_items_on_original_folder_id"
    t.index ["permanently_delete_at"], name: "index_scorecard_trash_items_on_permanently_delete_at"
    t.index ["trashable_type", "trashable_id"], name: "index_scorecard_trash_items_on_trashable_type_and_trashable_id"
    t.index ["trashed_by_id"], name: "index_scorecard_trash_items_on_trashed_by_id"
  end

  create_table "scorecards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.date "end_date", null: false
    t.string "name"
    t.integer "scorecard_assignments_count", default: 0, null: false
    t.uuid "scorecard_folder_id"
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id", "created_at"], name: "index_scorecards_on_account_id_and_created_at"
    t.index ["account_id", "user_id", "start_date"], name: "index_scorecards_on_account_id_and_user_id_and_start_date"
    t.index ["account_id"], name: "index_scorecards_on_account_id"
    t.index ["created_by_id"], name: "index_scorecards_on_created_by_id"
    t.index ["scorecard_folder_id"], name: "index_scorecards_on_scorecard_folder_id"
    t.index ["user_id"], name: "index_scorecards_on_user_id"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.uuid "identity_id", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["expires_at"], name: "index_sessions_on_expires_at"
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
  end

  create_table "social_media_platform_connection_disconnections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "disconnected_by_id"
    t.string "reason"
    t.uuid "social_media_platform_connection_id", null: false
    t.datetime "updated_at", null: false
    t.index ["disconnected_by_id"], name: "idx_on_disconnected_by_id_9c39527145"
    t.index ["social_media_platform_connection_id"], name: "idx_disconnections_on_connection"
  end

  create_table "social_media_platform_connections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "access_token_ciphertext"
    t.uuid "account_id", null: false
    t.uuid "connected_by_id"
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.string "platform_account_id"
    t.string "platform_avatar_url"
    t.string "platform_type", null: false
    t.string "platform_username"
    t.string "postiz_identifier"
    t.string "postiz_integration_id"
    t.text "refresh_token_ciphertext"
    t.datetime "token_expires_at"
    t.datetime "updated_at", null: false
    t.index ["account_id", "platform_type", "platform_account_id"], name: "idx_platform_connections_unique", unique: true
    t.index ["account_id"], name: "index_social_media_platform_connections_on_account_id"
    t.index ["connected_by_id"], name: "index_social_media_platform_connections_on_connected_by_id"
    t.index ["postiz_integration_id"], name: "idx_on_postiz_integration_id_6753cfb1a9"
  end

  create_table "social_media_post_platform_publication_failures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_code"
    t.string "error_message", null: false
    t.jsonb "metadata", default: {}
    t.uuid "social_media_platform_connection_id", null: false
    t.uuid "social_media_post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["social_media_platform_connection_id"], name: "idx_pub_failures_on_connection"
    t.index ["social_media_post_id", "social_media_platform_connection_id"], name: "idx_pub_failures_unique"
    t.index ["social_media_post_id"], name: "idx_on_social_media_post_id_c83f9eeb3a"
  end

  create_table "social_media_post_platform_publication_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "clicks_count", default: 0
    t.integer "comments_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "fetched_at", null: false
    t.integer "impressions_count", default: 0
    t.integer "likes_count", default: 0
    t.jsonb "raw_metrics", default: {}
    t.integer "reach_count", default: 0
    t.integer "shares_count", default: 0
    t.uuid "social_media_post_platform_publication_id", null: false
    t.datetime "updated_at", null: false
    t.index ["fetched_at"], name: "idx_metrics_on_fetched_at"
    t.index ["social_media_post_platform_publication_id", "fetched_at"], name: "idx_metrics_unique_per_publication_per_fetch", unique: true
    t.index ["social_media_post_platform_publication_id"], name: "idx_metrics_on_publication"
  end

  create_table "social_media_post_platform_publications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_post_id"
    t.string "external_post_url"
    t.jsonb "metadata", default: {}
    t.uuid "social_media_platform_connection_id", null: false
    t.uuid "social_media_post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "idx_publications_on_created_at"
    t.index ["social_media_platform_connection_id"], name: "idx_publications_on_connection"
    t.index ["social_media_post_id", "social_media_platform_connection_id"], name: "idx_post_publications_unique", unique: true
    t.index ["social_media_post_id"], name: "idx_on_social_media_post_id_aba0138243"
  end

  create_table "social_media_post_platform_targets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "social_media_platform_connection_id", null: false
    t.uuid "social_media_post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["social_media_platform_connection_id"], name: "idx_targets_on_connection"
    t.index ["social_media_post_id", "social_media_platform_connection_id"], name: "idx_post_platform_targets_unique", unique: true
    t.index ["social_media_post_id"], name: "idx_on_social_media_post_id_eb92115687"
  end

  create_table "social_media_post_schedules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "scheduled_by_id", null: false
    t.datetime "scheduled_for", null: false
    t.uuid "social_media_post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["scheduled_by_id"], name: "index_social_media_post_schedules_on_scheduled_by_id"
    t.index ["scheduled_for"], name: "idx_schedules_on_scheduled_for"
    t.index ["scheduled_for"], name: "index_social_media_post_schedules_on_scheduled_for"
    t.index ["social_media_post_id"], name: "index_social_media_post_schedules_on_social_media_post_id", unique: true
  end

  create_table "social_media_post_thread_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}
    t.integer "position", default: 0, null: false
    t.uuid "social_media_post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["social_media_post_id", "position"], name: "idx_thread_items_on_post_and_position"
    t.index ["social_media_post_id"], name: "index_social_media_post_thread_items_on_social_media_post_id"
  end

  create_table "social_media_posts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.boolean "is_thread", default: false, null: false
    t.jsonb "metadata", default: {}
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "idx_posts_on_account_and_created_at"
    t.index ["account_id", "created_at"], name: "index_social_media_posts_on_account_id_and_created_at"
    t.index ["account_id", "is_thread"], name: "index_social_media_posts_on_account_id_and_is_thread"
    t.index ["account_id"], name: "index_social_media_posts_on_account_id"
    t.index ["created_by_id"], name: "index_social_media_posts_on_created_by_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "updated_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id"
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id"
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id"
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.datetime "updated_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.datetime "updated_at", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id"
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id"
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id"
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "starter_designs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.uuid "design_id", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["created_by_id"], name: "index_starter_designs_on_created_by_id"
    t.index ["design_id"], name: "index_starter_designs_on_design_id", unique: true
  end

  create_table "storage_favorites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "storage_file_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["storage_file_id"], name: "index_storage_favorites_on_storage_file_id"
    t.index ["user_id", "storage_file_id"], name: "idx_storage_favorites_unique", unique: true
    t.index ["user_id"], name: "index_storage_favorites_on_user_id"
  end

  create_table "storage_file_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "storage_file_id", null: false
    t.uuid "storage_tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["storage_file_id", "storage_tag_id"], name: "idx_storage_file_tags_unique", unique: true
    t.index ["storage_file_id"], name: "index_storage_file_tags_on_storage_file_id"
    t.index ["storage_tag_id"], name: "index_storage_file_tags_on_storage_tag_id"
  end

  create_table "storage_files", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.bigint "byte_size", default: 0, null: false
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.uuid "storage_folder_id"
    t.datetime "updated_at", null: false
    t.uuid "uploaded_by_id", null: false
    t.index ["account_id", "content_type"], name: "idx_storage_files_account_content_type"
    t.index ["account_id", "created_at"], name: "idx_storage_files_account_created"
    t.index ["account_id"], name: "index_storage_files_on_account_id"
    t.index ["storage_folder_id", "position"], name: "idx_storage_files_folder_position"
    t.index ["storage_folder_id"], name: "index_storage_files_on_storage_folder_id"
    t.index ["uploaded_by_id"], name: "index_storage_files_on_uploaded_by_id"
  end

  create_table "storage_folders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.string "name", null: false
    t.uuid "parent_folder_id"
    t.integer "position", default: 0, null: false
    t.integer "storage_files_count", default: 0, null: false
    t.integer "storage_folders_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "parent_folder_id", "name"], name: "idx_storage_folders_unique_name", unique: true
    t.index ["account_id", "parent_folder_id", "position"], name: "idx_storage_folders_position"
    t.index ["account_id"], name: "index_storage_folders_on_account_id"
    t.index ["created_by_id"], name: "index_storage_folders_on_created_by_id"
    t.index ["parent_folder_id"], name: "index_storage_folders_on_parent_folder_id"
  end

  create_table "storage_notification_preferences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_storage_share", default: true
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_storage_notification_preferences_on_user_id", unique: true
  end

  create_table "storage_notification_readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "readable_id", null: false
    t.string "readable_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "readable_type", "readable_id"], name: "idx_storage_notif_readings_uniqueness", unique: true
    t.index ["user_id"], name: "index_storage_notification_readings_on_user_id"
  end

  create_table "storage_notification_recipients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "created_at"], name: "idx_storage_notif_recipients_user_timeline"
    t.index ["user_id", "event_type", "event_id"], name: "idx_storage_notif_recipients_uniqueness", unique: true
    t.index ["user_id"], name: "index_storage_notification_recipients_on_user_id"
  end

  create_table "storage_shares", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_level", default: "view", null: false
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.integer "download_count", default: 0, null: false
    t.datetime "expires_at"
    t.string "password_digest"
    t.uuid "shareable_id", null: false
    t.string "shareable_type", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["account_id", "created_at"], name: "idx_storage_shares_account_created"
    t.index ["account_id"], name: "index_storage_shares_on_account_id"
    t.index ["created_by_id"], name: "index_storage_shares_on_created_by_id"
    t.index ["shareable_type", "shareable_id"], name: "idx_storage_shares_shareable"
    t.index ["token"], name: "index_storage_shares_on_token", unique: true
  end

  create_table "storage_tags", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.string "color"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_storage_tags_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_storage_tags_on_account_id"
  end

  create_table "storage_trash_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "original_folder_id"
    t.datetime "permanently_delete_at", null: false
    t.uuid "trashable_id", null: false
    t.string "trashable_type", null: false
    t.uuid "trashed_by_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "permanently_delete_at"], name: "idx_storage_trash_items_cleanup"
    t.index ["account_id"], name: "index_storage_trash_items_on_account_id"
    t.index ["original_folder_id"], name: "index_storage_trash_items_on_original_folder_id"
    t.index ["trashable_type", "trashable_id"], name: "idx_storage_trash_items_trashable", unique: true
    t.index ["trashed_by_id"], name: "index_storage_trash_items_on_trashed_by_id"
  end

  create_table "support_conversation_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_by_id", null: false
    t.uuid "assigned_to_id", null: false
    t.datetime "created_at", null: false
    t.uuid "support_conversation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_by_id"], name: "index_support_conversation_assignments_on_assigned_by_id"
    t.index ["assigned_to_id"], name: "index_support_conversation_assignments_on_assigned_to_id"
    t.index ["support_conversation_id", "created_at"], name: "idx_support_assigns_timeline"
    t.index ["support_conversation_id"], name: "idx_on_support_conversation_id_08ff3e020a"
  end

  create_table "support_conversation_closures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "closed_by_id"
    t.datetime "created_at", null: false
    t.string "reason"
    t.uuid "support_conversation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_support_conversation_closures_on_closed_by_id"
    t.index ["support_conversation_id"], name: "idx_support_closures_uniq", unique: true
    t.index ["support_conversation_id"], name: "index_support_conversation_closures_on_support_conversation_id"
  end

  create_table "support_conversations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.uuid "assigned_to_id"
    t.datetime "created_at", null: false
    t.datetime "last_message_at"
    t.integer "messages_count", default: 0, null: false
    t.string "subject"
    t.uuid "support_inbox_id", null: false
    t.uuid "support_visitor_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_support_conversations_on_account_id"
    t.index ["assigned_to_id"], name: "index_support_conversations_on_assigned_to_id"
    t.index ["support_inbox_id", "last_message_at"], name: "idx_support_convos_inbox_time"
    t.index ["support_inbox_id"], name: "index_support_conversations_on_support_inbox_id"
    t.index ["support_visitor_id", "created_at"], name: "idx_support_convos_visitor_time"
    t.index ["support_visitor_id"], name: "index_support_conversations_on_support_visitor_id"
  end

  create_table "support_inbox_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "role", default: "agent", null: false
    t.uuid "support_inbox_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["support_inbox_id", "user_id"], name: "idx_support_inbox_memberships_uniq", unique: true
    t.index ["support_inbox_id"], name: "index_support_inbox_memberships_on_support_inbox_id"
    t.index ["user_id"], name: "index_support_inbox_memberships_on_user_id"
  end

  create_table "support_inboxes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.integer "conversations_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.text "description"
    t.boolean "embed_enabled", default: false, null: false
    t.jsonb "embed_settings", default: {}, null: false
    t.string "greeting_message"
    t.string "name", null: false
    t.integer "open_conversations_count", default: 0, null: false
    t.integer "support_inbox_memberships_count", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_support_inboxes_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_support_inboxes_on_account_id"
    t.index ["created_by_id"], name: "index_support_inboxes_on_created_by_id"
    t.index ["token"], name: "index_support_inboxes_on_token", unique: true
  end

  create_table "support_messages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.uuid "sender_id", null: false
    t.string "sender_type", null: false
    t.uuid "support_conversation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["support_conversation_id", "created_at"], name: "idx_support_msgs_timeline"
    t.index ["support_conversation_id"], name: "index_support_messages_on_support_conversation_id"
  end

  create_table "support_visitors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "last_seen_at"
    t.jsonb "metadata", default: {}, null: false
    t.string "name"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "idx_support_visitors_email", where: "(email IS NOT NULL)"
    t.index ["account_id"], name: "index_support_visitors_on_account_id"
    t.index ["token"], name: "index_support_visitors_on_token", unique: true
  end

  create_table "task_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["assigned_by_id"], name: "index_task_assignments_on_assigned_by_id"
    t.index ["task_id", "user_id"], name: "index_task_assignments_on_task_id_and_user_id", unique: true
    t.index ["task_id"], name: "index_task_assignments_on_task_id"
    t.index ["user_id"], name: "index_task_assignments_on_user_id"
  end

  create_table "task_cancellations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cancelled_by_id", null: false
    t.datetime "created_at", null: false
    t.text "reason"
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["cancelled_by_id"], name: "index_task_cancellations_on_cancelled_by_id"
    t.index ["task_id"], name: "index_task_cancellations_on_task_id", unique: true
  end

  create_table "task_checklist_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.datetime "completed_at"
    t.uuid "completed_by_id"
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.uuid "task_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_by_id"], name: "index_task_checklist_items_on_completed_by_id"
    t.index ["task_id", "position"], name: "index_task_checklist_items_on_task_id_and_position"
    t.index ["task_id"], name: "index_task_checklist_items_on_task_id"
  end

  create_table "task_comments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "content", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["task_id", "created_at"], name: "index_task_comments_on_task_id_and_created_at"
    t.index ["task_id"], name: "index_task_comments_on_task_id"
    t.index ["user_id"], name: "index_task_comments_on_user_id"
  end

  create_table "task_completions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "completed_by_id", null: false
    t.datetime "created_at", null: false
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["completed_by_id"], name: "index_task_completions_on_completed_by_id"
    t.index ["task_id"], name: "index_task_completions_on_task_id", unique: true
  end

  create_table "task_mentions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "mentioned_user_id", null: false
    t.uuid "task_comment_id"
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["mentioned_user_id", "created_at"], name: "index_task_mentions_on_mentioned_user_id_and_created_at"
    t.index ["mentioned_user_id"], name: "index_task_mentions_on_mentioned_user_id"
    t.index ["task_comment_id"], name: "index_task_mentions_on_task_comment_id"
    t.index ["task_id"], name: "index_task_mentions_on_task_id"
  end

  create_table "task_priority_changes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "changed_by_id", null: false
    t.datetime "created_at", null: false
    t.string "from_priority", null: false
    t.uuid "task_id", null: false
    t.string "to_priority", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_by_id"], name: "index_task_priority_changes_on_changed_by_id"
    t.index ["task_id", "created_at"], name: "index_task_priority_changes_on_task_id_and_created_at"
    t.index ["task_id"], name: "index_task_priority_changes_on_task_id"
  end

  create_table "task_starts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "started_by_id", null: false
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["started_by_id"], name: "index_task_starts_on_started_by_id"
    t.index ["task_id"], name: "index_task_starts_on_task_id", unique: true
  end

  create_table "task_taggings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "project_tag_id", null: false
    t.uuid "task_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_tag_id"], name: "index_task_taggings_on_project_tag_id"
    t.index ["task_id", "project_tag_id"], name: "index_task_taggings_on_task_id_and_project_tag_id", unique: true
    t.index ["task_id"], name: "index_task_taggings_on_task_id"
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "created_by_id", null: false
    t.jsonb "description", default: [], null: false
    t.date "due_date"
    t.integer "number", null: false
    t.integer "position", default: 0, null: false
    t.string "priority", default: "medium", null: false
    t.uuid "project_id", null: false
    t.uuid "project_status_id"
    t.date "start_date"
    t.integer "task_checklist_items_count", default: 0, null: false
    t.integer "task_comments_count", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_tasks_on_created_by_id"
    t.index ["project_id", "due_date"], name: "index_tasks_on_project_id_and_due_date"
    t.index ["project_id", "number"], name: "index_tasks_on_project_id_and_number", unique: true
    t.index ["project_id", "position"], name: "index_tasks_on_project_id_and_position"
    t.index ["project_id", "priority"], name: "index_tasks_on_project_id_and_priority"
    t.index ["project_id"], name: "index_tasks_on_project_id"
    t.index ["project_status_id"], name: "index_tasks_on_project_status_id"
  end

  create_table "team_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "travelers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "birth_date", null: false
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.uuid "insurance_policy_id", null: false
    t.string "last_name", null: false
    t.string "passport_country", limit: 2, null: false
    t.string "passport_number", limit: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["insurance_policy_id"], name: "index_travelers_on_insurance_policy_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id", null: false
    t.datetime "created_at", null: false
    t.uuid "identity_id", null: false
    t.string "kind", default: "human", null: false
    t.string "name", null: false
    t.string "role", default: "member"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["identity_id", "account_id"], name: "index_users_on_identity_id_and_account_id", unique: true
    t.index ["identity_id"], name: "index_users_on_identity_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agent_conversation_archives", "agent_conversations"
  add_foreign_key "agent_conversation_archives", "users", column: "archived_by_id"
  add_foreign_key "agent_conversation_favorites", "agent_conversations"
  add_foreign_key "agent_conversation_favorites", "users"
  add_foreign_key "agent_conversation_folders", "accounts"
  add_foreign_key "agent_conversation_folders", "agent_conversation_folders", column: "parent_folder_id"
  add_foreign_key "agent_conversation_memories", "agent_conversations"
  add_foreign_key "agent_conversation_memories", "agent_memories"
  add_foreign_key "agent_conversation_trash_items", "accounts"
  add_foreign_key "agent_conversation_trash_items", "agent_conversation_folders", column: "original_folder_id"
  add_foreign_key "agent_conversation_trash_items", "agent_conversations"
  add_foreign_key "agent_conversation_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "agent_conversations", "accounts"
  add_foreign_key "agent_conversations", "agent_conversation_folders"
  add_foreign_key "agent_conversations", "agents"
  add_foreign_key "agent_conversations", "users"
  add_foreign_key "agent_deactivations", "agents"
  add_foreign_key "agent_deactivations", "users", column: "deactivated_by_id"
  add_foreign_key "agent_feature_accesses", "agents"
  add_foreign_key "agent_feature_accesses", "users", column: "created_by_id"
  add_foreign_key "agent_memories", "accounts"
  add_foreign_key "agent_memories", "agents"
  add_foreign_key "agent_messages", "agent_conversations"
  add_foreign_key "agent_skills", "accounts"
  add_foreign_key "agent_skills", "agents", column: "default_agent_id"
  add_foreign_key "agent_skills", "users", column: "created_by_id"
  add_foreign_key "agent_task_cancellations", "agent_tasks"
  add_foreign_key "agent_task_cancellations", "users", column: "cancelled_by_id"
  add_foreign_key "agent_task_completions", "agent_tasks"
  add_foreign_key "agent_task_failures", "agent_tasks"
  add_foreign_key "agent_task_memories", "agent_memories"
  add_foreign_key "agent_task_memories", "agent_tasks"
  add_foreign_key "agent_task_pauses", "agent_tasks"
  add_foreign_key "agent_task_pauses", "users", column: "paused_by_id"
  add_foreign_key "agent_task_skill_usages", "agent_skills"
  add_foreign_key "agent_task_skill_usages", "agent_tasks"
  add_foreign_key "agent_task_starts", "agent_tasks"
  add_foreign_key "agent_task_steps", "agent_skills"
  add_foreign_key "agent_task_steps", "agent_tasks"
  add_foreign_key "agent_tasks", "accounts"
  add_foreign_key "agent_tasks", "agent_conversations"
  add_foreign_key "agent_tasks", "agents"
  add_foreign_key "agent_tasks", "users"
  add_foreign_key "agent_tool_call_approvals", "agent_tool_calls"
  add_foreign_key "agent_tool_call_approvals", "users", column: "approved_by_id"
  add_foreign_key "agent_tool_call_executions", "agent_tool_calls"
  add_foreign_key "agent_tool_call_failures", "agent_tool_calls"
  add_foreign_key "agent_tool_call_rejections", "agent_tool_calls"
  add_foreign_key "agent_tool_call_rejections", "users", column: "rejected_by_id"
  add_foreign_key "agent_tool_calls", "agent_conversations"
  add_foreign_key "agent_tool_calls", "agent_messages"
  add_foreign_key "agent_tool_calls", "agent_tools", on_delete: :nullify
  add_foreign_key "agent_tools", "accounts"
  add_foreign_key "agent_tools", "users", column: "created_by_id"
  add_foreign_key "agents", "accounts"
  add_foreign_key "agents", "users"
  add_foreign_key "agents", "users", column: "created_by_id"
  add_foreign_key "approval_submissions", "users", column: "approver_id"
  add_foreign_key "approval_submissions", "users", column: "submitted_by_id"
  add_foreign_key "approvals", "approval_submissions"
  add_foreign_key "approvals", "users", column: "approved_by_id"
  add_foreign_key "asset_favorites", "assets"
  add_foreign_key "asset_favorites", "users"
  add_foreign_key "asset_trash_items", "accounts"
  add_foreign_key "asset_trash_items", "assets"
  add_foreign_key "asset_trash_items", "collections", column: "original_folder_id"
  add_foreign_key "asset_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "assets", "accounts"
  add_foreign_key "assets", "collections"
  add_foreign_key "assets", "users", column: "uploaded_by_id"
  add_foreign_key "book_api_tokens", "accounts"
  add_foreign_key "book_api_tokens", "books"
  add_foreign_key "book_api_tokens", "users", column: "created_by_id"
  add_foreign_key "book_collaborators", "books"
  add_foreign_key "book_collaborators", "users"
  add_foreign_key "book_collaborators", "users", column: "added_by_id"
  add_foreign_key "book_favorites", "books"
  add_foreign_key "book_favorites", "users"
  add_foreign_key "book_publications", "books"
  add_foreign_key "book_publications", "users", column: "published_by_id"
  add_foreign_key "book_trash_items", "accounts"
  add_foreign_key "book_trash_items", "books"
  add_foreign_key "book_trash_items", "document_folders", column: "original_folder_id"
  add_foreign_key "book_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "books", "accounts"
  add_foreign_key "books", "document_folders"
  add_foreign_key "books", "users", column: "created_by_id"
  add_foreign_key "business_role_assignments", "business_roles"
  add_foreign_key "business_role_assignments", "users"
  add_foreign_key "business_role_assignments", "users", column: "assigned_by_id"
  add_foreign_key "business_roles", "accounts"
  add_foreign_key "business_roles", "users", column: "created_by_id"
  add_foreign_key "calendar_acceptances", "calendar_invitations"
  add_foreign_key "calendar_acceptances", "users", column: "accepted_by_id"
  add_foreign_key "calendar_acknowledgments", "users", column: "acknowledged_by_id"
  add_foreign_key "calendar_action_item_completions", "calendar_action_items"
  add_foreign_key "calendar_action_item_completions", "users", column: "completed_by_id"
  add_foreign_key "calendar_action_items", "calendar_meeting_notes"
  add_foreign_key "calendar_action_items", "users", column: "assignee_id"
  add_foreign_key "calendar_agenda_item_completions", "calendar_agenda_items"
  add_foreign_key "calendar_agenda_item_completions", "users", column: "completed_by_id"
  add_foreign_key "calendar_agenda_items", "calendar_meetings"
  add_foreign_key "calendar_declines", "calendar_invitations"
  add_foreign_key "calendar_declines", "users", column: "declined_by_id"
  add_foreign_key "calendar_events", "accounts"
  add_foreign_key "calendar_events", "calendar_folders"
  add_foreign_key "calendar_events", "users", column: "created_by_id"
  add_foreign_key "calendar_folders", "accounts"
  add_foreign_key "calendar_folders", "calendar_folders", column: "parent_folder_id"
  add_foreign_key "calendar_folders", "users", column: "created_by_id"
  add_foreign_key "calendar_invitations", "users"
  add_foreign_key "calendar_invitations", "users", column: "invited_by_id"
  add_foreign_key "calendar_meeting_notes", "calendar_meetings"
  add_foreign_key "calendar_meeting_notes", "users", column: "created_by_id"
  add_foreign_key "calendar_meetings", "accounts"
  add_foreign_key "calendar_meetings", "calendar_folders"
  add_foreign_key "calendar_meetings", "users", column: "created_by_id"
  add_foreign_key "calendar_notification_preferences", "users"
  add_foreign_key "calendar_notification_readings", "users"
  add_foreign_key "calendar_notification_recipients", "users"
  add_foreign_key "calendar_reminder_shares", "calendar_reminders"
  add_foreign_key "calendar_reminder_shares", "users"
  add_foreign_key "calendar_reminders", "accounts"
  add_foreign_key "calendar_reminders", "calendar_folders"
  add_foreign_key "calendar_reminders", "users", column: "created_by_id"
  add_foreign_key "calendar_trash_items", "accounts"
  add_foreign_key "calendar_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "chat_bookmarks", "chat_messages"
  add_foreign_key "chat_bookmarks", "users"
  add_foreign_key "chat_conversations", "accounts"
  add_foreign_key "chat_conversations", "users", column: "created_by_id"
  add_foreign_key "chat_memberships", "chat_conversations"
  add_foreign_key "chat_memberships", "chat_messages", column: "last_read_message_id"
  add_foreign_key "chat_memberships", "users"
  add_foreign_key "chat_mentions", "chat_messages"
  add_foreign_key "chat_mentions", "users", column: "mentioned_user_id"
  add_foreign_key "chat_message_edits", "chat_messages"
  add_foreign_key "chat_message_edits", "users", column: "edited_by_id"
  add_foreign_key "chat_messages", "chat_conversations"
  add_foreign_key "chat_messages", "chat_messages", column: "parent_message_id"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "chat_notification_preferences", "users"
  add_foreign_key "chat_notification_readings", "users"
  add_foreign_key "chat_notification_recipients", "users"
  add_foreign_key "chat_pins", "chat_conversations"
  add_foreign_key "chat_pins", "chat_messages"
  add_foreign_key "chat_pins", "users", column: "pinned_by_id"
  add_foreign_key "chat_reactions", "chat_messages"
  add_foreign_key "chat_reactions", "users"
  add_foreign_key "collections", "accounts"
  add_foreign_key "collections", "collections", column: "parent_collection_id"
  add_foreign_key "crm_api_tokens", "accounts"
  add_foreign_key "crm_api_tokens", "crm_tables"
  add_foreign_key "crm_api_tokens", "users", column: "created_by_id"
  add_foreign_key "crm_attachments", "crm_fields"
  add_foreign_key "crm_attachments", "crm_rows"
  add_foreign_key "crm_enrichment_completions", "crm_enrichments"
  add_foreign_key "crm_enrichment_failures", "crm_enrichments"
  add_foreign_key "crm_enrichments", "accounts"
  add_foreign_key "crm_enrichments", "crm_tables"
  add_foreign_key "crm_enrichments", "users", column: "created_by_id"
  add_foreign_key "crm_field_options", "crm_fields"
  add_foreign_key "crm_fields", "crm_tables"
  add_foreign_key "crm_pipeline_entries", "crm_pipeline_stages"
  add_foreign_key "crm_pipeline_entries", "crm_rows"
  add_foreign_key "crm_pipeline_entries", "users", column: "created_by_id"
  add_foreign_key "crm_pipeline_stages", "crm_tables"
  add_foreign_key "crm_record_link_fields", "crm_fields", column: "display_crm_field_id"
  add_foreign_key "crm_record_link_fields", "crm_tables", column: "target_crm_table_id"
  add_foreign_key "crm_research_completions", "crm_researches"
  add_foreign_key "crm_research_failures", "crm_researches"
  add_foreign_key "crm_researches", "accounts"
  add_foreign_key "crm_researches", "crm_tables"
  add_foreign_key "crm_researches", "users", column: "created_by_id"
  add_foreign_key "crm_rows", "crm_tables"
  add_foreign_key "crm_rows", "users", column: "created_by_id"
  add_foreign_key "crm_table_column_preferences", "crm_tables"
  add_foreign_key "crm_table_column_preferences", "users"
  add_foreign_key "crm_table_duplications", "crm_tables"
  add_foreign_key "crm_table_duplications", "crm_tables", column: "source_crm_table_id"
  add_foreign_key "crm_table_duplications", "users", column: "created_by_id"
  add_foreign_key "crm_table_favorites", "crm_tables"
  add_foreign_key "crm_table_favorites", "users"
  add_foreign_key "crm_table_folders", "accounts"
  add_foreign_key "crm_table_folders", "crm_table_folders", column: "parent_folder_id"
  add_foreign_key "crm_table_publications", "crm_tables"
  add_foreign_key "crm_table_publications", "users", column: "published_by_id"
  add_foreign_key "crm_table_templates", "crm_tables"
  add_foreign_key "crm_table_templates", "users", column: "created_by_id"
  add_foreign_key "crm_table_trash_items", "accounts"
  add_foreign_key "crm_table_trash_items", "crm_table_folders", column: "original_folder_id"
  add_foreign_key "crm_table_trash_items", "crm_tables"
  add_foreign_key "crm_table_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "crm_tables", "accounts"
  add_foreign_key "crm_tables", "books"
  add_foreign_key "crm_tables", "crm_table_folders"
  add_foreign_key "crm_tables", "document_folders"
  add_foreign_key "crm_tables", "users", column: "created_by_id"
  add_foreign_key "design_archive_exports", "designs"
  add_foreign_key "design_archive_exports", "users", column: "exported_by_id"
  add_foreign_key "design_collections", "accounts"
  add_foreign_key "design_collections", "design_collections", column: "parent_collection_id"
  add_foreign_key "design_favorites", "designs"
  add_foreign_key "design_favorites", "users"
  add_foreign_key "design_trash_items", "accounts"
  add_foreign_key "design_trash_items", "design_collections", column: "original_folder_id"
  add_foreign_key "design_trash_items", "designs"
  add_foreign_key "design_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "designs", "accounts"
  add_foreign_key "designs", "design_collections"
  add_foreign_key "designs", "designs", column: "source_design_id"
  add_foreign_key "designs", "users", column: "created_by_id"
  add_foreign_key "document_folders", "accounts"
  add_foreign_key "document_folders", "document_folders", column: "parent_folder_id"
  add_foreign_key "document_folders", "users", column: "created_by_id"
  add_foreign_key "document_notification_preferences", "users"
  add_foreign_key "document_notification_readings", "users"
  add_foreign_key "document_notification_recipients", "users"
  add_foreign_key "documents", "accounts"
  add_foreign_key "documents", "books"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "elements", "assets"
  add_foreign_key "elements", "pages"
  add_foreign_key "email_account_assignments", "email_accounts"
  add_foreign_key "email_account_assignments", "users"
  add_foreign_key "email_account_assignments", "users", column: "assigned_by_id"
  add_foreign_key "email_accounts", "accounts"
  add_foreign_key "email_accounts", "email_domains"
  add_foreign_key "email_accounts", "users", column: "created_by_id"
  add_foreign_key "email_domains", "accounts"
  add_foreign_key "email_domains", "users", column: "added_by_id"
  add_foreign_key "email_message_archives", "email_messages"
  add_foreign_key "email_message_archives", "users"
  add_foreign_key "email_message_reads", "email_messages"
  add_foreign_key "email_message_reads", "users"
  add_foreign_key "email_message_recipients", "email_messages"
  add_foreign_key "email_message_stars", "email_messages"
  add_foreign_key "email_message_stars", "users"
  add_foreign_key "email_message_trashes", "email_messages"
  add_foreign_key "email_message_trashes", "users"
  add_foreign_key "email_messages", "accounts"
  add_foreign_key "email_messages", "email_accounts"
  add_foreign_key "email_messages", "email_messages", column: "parent_id"
  add_foreign_key "exports", "designs"
  add_foreign_key "exports", "export_presets"
  add_foreign_key "exports", "users", column: "exported_by_id"
  add_foreign_key "finance_budgets", "accounts"
  add_foreign_key "finance_budgets", "finance_categories"
  add_foreign_key "finance_budgets", "finance_sheets"
  add_foreign_key "finance_budgets", "users", column: "created_by_id"
  add_foreign_key "finance_categories", "accounts"
  add_foreign_key "finance_categories", "users", column: "created_by_id"
  add_foreign_key "finance_notification_preferences", "users"
  add_foreign_key "finance_notification_readings", "users"
  add_foreign_key "finance_notification_recipients", "users"
  add_foreign_key "finance_payment_methods", "accounts"
  add_foreign_key "finance_payment_statuses", "accounts"
  add_foreign_key "finance_recurrence_frequencies", "accounts"
  add_foreign_key "finance_recurring_transactions", "accounts"
  add_foreign_key "finance_recurring_transactions", "finance_categories"
  add_foreign_key "finance_recurring_transactions", "finance_payment_methods"
  add_foreign_key "finance_recurring_transactions", "finance_recurrence_frequencies"
  add_foreign_key "finance_recurring_transactions", "finance_sheets"
  add_foreign_key "finance_recurring_transactions", "finance_transaction_types"
  add_foreign_key "finance_recurring_transactions", "users", column: "approver_id"
  add_foreign_key "finance_recurring_transactions", "users", column: "created_by_id"
  add_foreign_key "finance_sheet_favorites", "finance_sheets"
  add_foreign_key "finance_sheet_favorites", "users"
  add_foreign_key "finance_sheet_folders", "accounts"
  add_foreign_key "finance_sheet_folders", "finance_sheet_folders", column: "parent_folder_id"
  add_foreign_key "finance_sheet_trash_items", "accounts"
  add_foreign_key "finance_sheet_trash_items", "finance_sheet_folders", column: "original_folder_id"
  add_foreign_key "finance_sheet_trash_items", "finance_sheets"
  add_foreign_key "finance_sheet_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "finance_sheets", "accounts"
  add_foreign_key "finance_sheets", "finance_sheet_folders"
  add_foreign_key "finance_sheets", "users", column: "created_by_id"
  add_foreign_key "finance_transaction_types", "accounts"
  add_foreign_key "finance_transactions", "accounts"
  add_foreign_key "finance_transactions", "finance_categories"
  add_foreign_key "finance_transactions", "finance_payment_methods"
  add_foreign_key "finance_transactions", "finance_payment_statuses"
  add_foreign_key "finance_transactions", "finance_recurring_transactions", column: "recurring_source_id"
  add_foreign_key "finance_transactions", "finance_sheets"
  add_foreign_key "finance_transactions", "finance_transaction_types"
  add_foreign_key "finance_transactions", "users", column: "created_by_id"
  add_foreign_key "generation_favorites", "generations"
  add_foreign_key "generation_favorites", "users"
  add_foreign_key "generation_folders", "accounts"
  add_foreign_key "generation_folders", "generation_folders", column: "parent_folder_id"
  add_foreign_key "generation_folders", "users", column: "created_by_id"
  add_foreign_key "generation_notification_preferences", "users"
  add_foreign_key "generation_notification_readings", "users"
  add_foreign_key "generation_notification_recipients", "users"
  add_foreign_key "generation_trash_items", "accounts"
  add_foreign_key "generation_trash_items", "generation_folders", column: "original_folder_id"
  add_foreign_key "generation_trash_items", "generations"
  add_foreign_key "generation_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "generations", "accounts"
  add_foreign_key "generations", "assets"
  add_foreign_key "generations", "generation_folders"
  add_foreign_key "generations", "generations", column: "parent_generation_id"
  add_foreign_key "generations", "users", column: "created_by_id"
  add_foreign_key "hr_attachments", "hr_fields"
  add_foreign_key "hr_attachments", "hr_records"
  add_foreign_key "hr_categories", "accounts"
  add_foreign_key "hr_categories", "users", column: "created_by_id"
  add_foreign_key "hr_field_options", "hr_fields"
  add_foreign_key "hr_fields", "hr_categories"
  add_foreign_key "hr_records", "hr_categories"
  add_foreign_key "hr_records", "users"
  add_foreign_key "hr_records", "users", column: "filled_by_id"
  add_foreign_key "insurance_policies", "accounts"
  add_foreign_key "invites", "accounts"
  add_foreign_key "invites", "users", column: "inviter_id"
  add_foreign_key "invoice_cancellations", "invoices"
  add_foreign_key "invoice_cancellations", "users", column: "cancelled_by_id"
  add_foreign_key "invoice_favorites", "invoices"
  add_foreign_key "invoice_favorites", "users"
  add_foreign_key "invoice_folders", "accounts"
  add_foreign_key "invoice_folders", "invoice_folders", column: "parent_folder_id"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoice_payments", "invoices"
  add_foreign_key "invoice_payments", "users", column: "recorded_by_id"
  add_foreign_key "invoice_sendings", "invoices"
  add_foreign_key "invoice_sendings", "users", column: "sent_by_id"
  add_foreign_key "invoice_taxes", "invoices"
  add_foreign_key "invoice_taxes", "invoicing_tax_rates"
  add_foreign_key "invoice_tranches", "invoices"
  add_foreign_key "invoice_trash_items", "accounts"
  add_foreign_key "invoice_trash_items", "invoice_folders", column: "original_folder_id"
  add_foreign_key "invoice_trash_items", "invoices"
  add_foreign_key "invoice_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "invoices", "accounts"
  add_foreign_key "invoices", "invoice_folders"
  add_foreign_key "invoices", "invoicing_clients"
  add_foreign_key "invoices", "invoicing_organizations"
  add_foreign_key "invoices", "users", column: "created_by_id"
  add_foreign_key "invoicing_bank_details", "invoicing_organizations"
  add_foreign_key "invoicing_client_favorites", "invoicing_clients"
  add_foreign_key "invoicing_client_favorites", "users"
  add_foreign_key "invoicing_client_folders", "accounts"
  add_foreign_key "invoicing_client_folders", "invoicing_client_folders", column: "parent_folder_id"
  add_foreign_key "invoicing_client_trash_items", "accounts"
  add_foreign_key "invoicing_client_trash_items", "invoicing_client_folders", column: "original_folder_id"
  add_foreign_key "invoicing_client_trash_items", "invoicing_clients"
  add_foreign_key "invoicing_client_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "invoicing_clients", "accounts"
  add_foreign_key "invoicing_clients", "invoicing_client_folders"
  add_foreign_key "invoicing_clients", "users", column: "created_by_id"
  add_foreign_key "invoicing_organization_favorites", "invoicing_organizations"
  add_foreign_key "invoicing_organization_favorites", "users"
  add_foreign_key "invoicing_organization_folders", "accounts"
  add_foreign_key "invoicing_organization_folders", "invoicing_organization_folders", column: "parent_folder_id"
  add_foreign_key "invoicing_organization_trash_items", "accounts"
  add_foreign_key "invoicing_organization_trash_items", "invoicing_organization_folders", column: "original_folder_id"
  add_foreign_key "invoicing_organization_trash_items", "invoicing_organizations"
  add_foreign_key "invoicing_organization_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "invoicing_organizations", "accounts"
  add_foreign_key "invoicing_organizations", "invoicing_organization_folders"
  add_foreign_key "invoicing_organizations", "users", column: "created_by_id"
  add_foreign_key "invoicing_payment_links", "invoicing_organizations"
  add_foreign_key "invoicing_tax_rates", "accounts"
  add_foreign_key "invoicing_tax_rates", "users", column: "created_by_id"
  add_foreign_key "magic_links", "identities"
  add_foreign_key "management_records", "accounts"
  add_foreign_key "management_records", "users", column: "created_by_id"
  add_foreign_key "management_records", "users", column: "manager_id"
  add_foreign_key "management_records", "users", column: "report_id"
  add_foreign_key "okr_check_ins", "okr_key_results"
  add_foreign_key "okr_check_ins", "users", column: "created_by_id"
  add_foreign_key "okr_comments", "users"
  add_foreign_key "okr_key_result_completions", "okr_key_results"
  add_foreign_key "okr_key_result_completions", "users", column: "completed_by_id"
  add_foreign_key "okr_key_results", "okr_objectives"
  add_foreign_key "okr_key_results", "users", column: "created_by_id"
  add_foreign_key "okr_key_results", "users", column: "owner_id"
  add_foreign_key "okr_manager_reviews", "okr_objectives"
  add_foreign_key "okr_manager_reviews", "users", column: "created_by_id"
  add_foreign_key "okr_manager_reviews", "users", column: "reviewer_id"
  add_foreign_key "okr_mentions", "okr_check_ins"
  add_foreign_key "okr_mentions", "okr_comments"
  add_foreign_key "okr_mentions", "okr_key_results"
  add_foreign_key "okr_mentions", "okr_objectives"
  add_foreign_key "okr_mentions", "users", column: "mentioned_user_id"
  add_foreign_key "okr_notification_preferences", "users"
  add_foreign_key "okr_notification_readings", "users"
  add_foreign_key "okr_notification_recipients", "users"
  add_foreign_key "okr_objective_completions", "okr_objectives"
  add_foreign_key "okr_objective_completions", "users", column: "completed_by_id"
  add_foreign_key "okr_objective_favorites", "okr_objectives"
  add_foreign_key "okr_objective_favorites", "users"
  add_foreign_key "okr_objectives", "accounts"
  add_foreign_key "okr_objectives", "okr_objectives", column: "parent_id"
  add_foreign_key "okr_objectives", "okr_periods"
  add_foreign_key "okr_objectives", "users", column: "created_by_id"
  add_foreign_key "okr_objectives", "users", column: "owner_id"
  add_foreign_key "okr_period_activations", "okr_periods"
  add_foreign_key "okr_period_activations", "users", column: "activated_by_id"
  add_foreign_key "okr_period_archives", "okr_periods"
  add_foreign_key "okr_period_archives", "users", column: "archived_by_id"
  add_foreign_key "okr_period_favorites", "okr_periods"
  add_foreign_key "okr_period_favorites", "users"
  add_foreign_key "okr_period_folders", "accounts"
  add_foreign_key "okr_period_folders", "okr_period_folders", column: "parent_folder_id"
  add_foreign_key "okr_period_folders", "users", column: "created_by_id"
  add_foreign_key "okr_periods", "accounts"
  add_foreign_key "okr_periods", "okr_period_folders"
  add_foreign_key "okr_periods", "users", column: "created_by_id"
  add_foreign_key "okr_review_answers", "okr_review_questions"
  add_foreign_key "okr_review_answers", "users", column: "created_by_id"
  add_foreign_key "okr_review_questions", "accounts"
  add_foreign_key "okr_review_questions", "users", column: "created_by_id"
  add_foreign_key "okr_self_reviews", "okr_objectives"
  add_foreign_key "okr_self_reviews", "users", column: "created_by_id"
  add_foreign_key "okr_self_reviews", "users", column: "reviewer_id"
  add_foreign_key "okr_trash_items", "accounts"
  add_foreign_key "okr_trash_items", "okr_period_folders", column: "original_folder_id"
  add_foreign_key "okr_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "pages", "designs"
  add_foreign_key "people_log_categories", "accounts"
  add_foreign_key "people_log_categories", "users", column: "created_by_id"
  add_foreign_key "people_logs", "accounts"
  add_foreign_key "people_logs", "people_log_categories"
  add_foreign_key "people_logs", "users"
  add_foreign_key "people_logs", "users", column: "logged_by_id"
  add_foreign_key "people_logs", "users", column: "reviewed_by_id"
  add_foreign_key "policy_completeds", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_contract_confirmeds", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_contract_createds", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_faileds", "identities", column: "created_by_id"
  add_foreign_key "policy_faileds", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_payment_receiveds", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_pending_payments", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_refund_initiateds", "identities", column: "initiated_by_id"
  add_foreign_key "policy_refund_initiateds", "insurance_policies", column: "policy_id"
  add_foreign_key "policy_refundeds", "insurance_policies", column: "policy_id"
  add_foreign_key "project_archives", "projects"
  add_foreign_key "project_archives", "users", column: "archived_by_id"
  add_foreign_key "project_favorites", "projects"
  add_foreign_key "project_favorites", "users"
  add_foreign_key "project_folders", "accounts"
  add_foreign_key "project_folders", "project_folders", column: "parent_folder_id"
  add_foreign_key "project_folders", "users", column: "created_by_id"
  add_foreign_key "project_memberships", "projects"
  add_foreign_key "project_memberships", "users"
  add_foreign_key "project_notification_preferences", "users"
  add_foreign_key "project_notification_readings", "users"
  add_foreign_key "project_notification_recipients", "users"
  add_foreign_key "project_statuses", "projects"
  add_foreign_key "project_tags", "projects"
  add_foreign_key "project_trash_items", "accounts"
  add_foreign_key "project_trash_items", "project_folders", column: "original_folder_id"
  add_foreign_key "project_trash_items", "projects"
  add_foreign_key "project_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "projects", "accounts"
  add_foreign_key "projects", "project_folders"
  add_foreign_key "projects", "users", column: "created_by_id"
  add_foreign_key "publications", "designs"
  add_foreign_key "publications", "users", column: "published_by_id"
  add_foreign_key "rejections", "approval_submissions"
  add_foreign_key "rejections", "users", column: "rejected_by_id"
  add_foreign_key "scorecard_assignment_edits", "accounts"
  add_foreign_key "scorecard_assignment_edits", "scorecard_assignments"
  add_foreign_key "scorecard_assignment_edits", "users", column: "edited_by_id"
  add_foreign_key "scorecard_assignments", "scorecard_metrics"
  add_foreign_key "scorecard_assignments", "scorecards"
  add_foreign_key "scorecard_assignments", "users", column: "assigned_by_id"
  add_foreign_key "scorecard_cadences", "accounts"
  add_foreign_key "scorecard_comments", "users"
  add_foreign_key "scorecard_cycles", "accounts"
  add_foreign_key "scorecard_cycles", "scorecard_cadences"
  add_foreign_key "scorecard_entries", "scorecard_assignments"
  add_foreign_key "scorecard_entries", "scorecard_cycles"
  add_foreign_key "scorecard_entries", "users", column: "created_by_id"
  add_foreign_key "scorecard_favorites", "scorecards"
  add_foreign_key "scorecard_favorites", "users"
  add_foreign_key "scorecard_folders", "accounts"
  add_foreign_key "scorecard_folders", "scorecard_folders", column: "parent_folder_id"
  add_foreign_key "scorecard_folders", "users", column: "created_by_id"
  add_foreign_key "scorecard_manager_reviews", "scorecard_cycles"
  add_foreign_key "scorecard_manager_reviews", "scorecards"
  add_foreign_key "scorecard_manager_reviews", "users", column: "created_by_id"
  add_foreign_key "scorecard_manager_reviews", "users", column: "reviewer_id"
  add_foreign_key "scorecard_mentions", "scorecard_comments"
  add_foreign_key "scorecard_mentions", "scorecard_entries"
  add_foreign_key "scorecard_mentions", "scorecard_manager_reviews"
  add_foreign_key "scorecard_mentions", "scorecard_self_reviews"
  add_foreign_key "scorecard_mentions", "users", column: "mentioned_user_id"
  add_foreign_key "scorecard_metric_categories", "accounts"
  add_foreign_key "scorecard_metric_categories", "users", column: "created_by_id"
  add_foreign_key "scorecard_metrics", "accounts"
  add_foreign_key "scorecard_metrics", "scorecard_cadences"
  add_foreign_key "scorecard_metrics", "scorecard_metric_categories"
  add_foreign_key "scorecard_metrics", "users", column: "created_by_id"
  add_foreign_key "scorecard_notification_preferences", "users"
  add_foreign_key "scorecard_notification_readings", "users"
  add_foreign_key "scorecard_notification_recipients", "users"
  add_foreign_key "scorecard_review_answers", "scorecard_review_questions"
  add_foreign_key "scorecard_review_answers", "users", column: "created_by_id"
  add_foreign_key "scorecard_review_questions", "accounts"
  add_foreign_key "scorecard_review_questions", "users", column: "created_by_id"
  add_foreign_key "scorecard_self_reviews", "scorecard_cycles"
  add_foreign_key "scorecard_self_reviews", "scorecards"
  add_foreign_key "scorecard_self_reviews", "users", column: "created_by_id"
  add_foreign_key "scorecard_self_reviews", "users", column: "reviewer_id"
  add_foreign_key "scorecard_trash_items", "accounts"
  add_foreign_key "scorecard_trash_items", "scorecard_folders", column: "original_folder_id"
  add_foreign_key "scorecard_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "scorecards", "accounts"
  add_foreign_key "scorecards", "scorecard_folders"
  add_foreign_key "scorecards", "users"
  add_foreign_key "scorecards", "users", column: "created_by_id"
  add_foreign_key "sessions", "identities"
  add_foreign_key "social_media_platform_connection_disconnections", "social_media_platform_connections"
  add_foreign_key "social_media_platform_connection_disconnections", "users", column: "disconnected_by_id"
  add_foreign_key "social_media_platform_connections", "accounts"
  add_foreign_key "social_media_platform_connections", "users", column: "connected_by_id"
  add_foreign_key "social_media_post_platform_publication_failures", "social_media_platform_connections"
  add_foreign_key "social_media_post_platform_publication_failures", "social_media_posts"
  add_foreign_key "social_media_post_platform_publication_metrics", "social_media_post_platform_publications"
  add_foreign_key "social_media_post_platform_publications", "social_media_platform_connections"
  add_foreign_key "social_media_post_platform_publications", "social_media_posts"
  add_foreign_key "social_media_post_platform_targets", "social_media_platform_connections"
  add_foreign_key "social_media_post_platform_targets", "social_media_posts"
  add_foreign_key "social_media_post_schedules", "social_media_posts"
  add_foreign_key "social_media_post_schedules", "users", column: "scheduled_by_id"
  add_foreign_key "social_media_post_thread_items", "social_media_posts"
  add_foreign_key "social_media_posts", "accounts"
  add_foreign_key "social_media_posts", "users", column: "created_by_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "starter_designs", "designs"
  add_foreign_key "starter_designs", "users", column: "created_by_id"
  add_foreign_key "storage_favorites", "storage_files"
  add_foreign_key "storage_favorites", "users"
  add_foreign_key "storage_file_tags", "storage_files"
  add_foreign_key "storage_file_tags", "storage_tags"
  add_foreign_key "storage_files", "accounts"
  add_foreign_key "storage_files", "storage_folders"
  add_foreign_key "storage_files", "users", column: "uploaded_by_id"
  add_foreign_key "storage_folders", "accounts"
  add_foreign_key "storage_folders", "storage_folders", column: "parent_folder_id"
  add_foreign_key "storage_folders", "users", column: "created_by_id"
  add_foreign_key "storage_notification_preferences", "users"
  add_foreign_key "storage_notification_readings", "users"
  add_foreign_key "storage_notification_recipients", "users"
  add_foreign_key "storage_shares", "accounts"
  add_foreign_key "storage_shares", "users", column: "created_by_id"
  add_foreign_key "storage_tags", "accounts"
  add_foreign_key "storage_trash_items", "accounts"
  add_foreign_key "storage_trash_items", "storage_folders", column: "original_folder_id"
  add_foreign_key "storage_trash_items", "users", column: "trashed_by_id"
  add_foreign_key "support_conversation_assignments", "support_conversations"
  add_foreign_key "support_conversation_assignments", "users", column: "assigned_by_id"
  add_foreign_key "support_conversation_assignments", "users", column: "assigned_to_id"
  add_foreign_key "support_conversation_closures", "support_conversations"
  add_foreign_key "support_conversation_closures", "users", column: "closed_by_id"
  add_foreign_key "support_conversations", "accounts"
  add_foreign_key "support_conversations", "support_inboxes"
  add_foreign_key "support_conversations", "support_visitors"
  add_foreign_key "support_conversations", "users", column: "assigned_to_id"
  add_foreign_key "support_inbox_memberships", "support_inboxes"
  add_foreign_key "support_inbox_memberships", "users"
  add_foreign_key "support_inboxes", "accounts"
  add_foreign_key "support_inboxes", "users", column: "created_by_id"
  add_foreign_key "support_messages", "support_conversations"
  add_foreign_key "support_visitors", "accounts"
  add_foreign_key "task_assignments", "tasks"
  add_foreign_key "task_assignments", "users"
  add_foreign_key "task_assignments", "users", column: "assigned_by_id"
  add_foreign_key "task_cancellations", "tasks"
  add_foreign_key "task_cancellations", "users", column: "cancelled_by_id"
  add_foreign_key "task_checklist_items", "tasks"
  add_foreign_key "task_checklist_items", "users", column: "completed_by_id"
  add_foreign_key "task_comments", "tasks"
  add_foreign_key "task_comments", "users"
  add_foreign_key "task_completions", "tasks"
  add_foreign_key "task_completions", "users", column: "completed_by_id"
  add_foreign_key "task_mentions", "task_comments"
  add_foreign_key "task_mentions", "tasks"
  add_foreign_key "task_mentions", "users", column: "mentioned_user_id"
  add_foreign_key "task_priority_changes", "tasks"
  add_foreign_key "task_priority_changes", "users", column: "changed_by_id"
  add_foreign_key "task_starts", "tasks"
  add_foreign_key "task_starts", "users", column: "started_by_id"
  add_foreign_key "task_taggings", "project_tags"
  add_foreign_key "task_taggings", "tasks"
  add_foreign_key "tasks", "project_statuses"
  add_foreign_key "tasks", "projects"
  add_foreign_key "tasks", "users", column: "created_by_id"
  add_foreign_key "travelers", "insurance_policies", on_delete: :cascade
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "identities"
end
