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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_26_210850) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "completions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "myrecipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["myrecipe_id"], name: "index_completions_on_myrecipe_id"
    t.index ["user_id"], name: "index_completions_on_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "dietaryrestrictionlinks", force: :cascade do |t|
    t.bigint "myrecipe_id"
    t.bigint "dietaryrestriction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dietaryrestriction_id"], name: "index_dietaryrestrictionlinks_on_dietaryrestriction_id"
    t.index ["myrecipe_id"], name: "index_dietaryrestrictionlinks_on_myrecipe_id"
  end

  create_table "dietaryrestrictions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_dietaryrestrictions_on_name"
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "myrecipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["myrecipe_id"], name: "index_favourites_on_myrecipe_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "groceries", force: :cascade do |t|
    t.string "name"
    t.string "quantity"
    t.string "unit"
    t.boolean "is_completed", default: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_completed"], name: "index_groceries_on_is_completed"
    t.index ["user_id"], name: "index_groceries_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "myrecipeingredientlink_id"
    t.index ["myrecipeingredientlink_id"], name: "index_ingredients_on_myrecipeingredientlink_id", unique: true
    t.index ["name"], name: "index_ingredients_on_name", unique: true
  end

  create_table "leftovers", force: :cascade do |t|
    t.bigint "ingredient_id"
    t.bigint "user_id"
    t.string "quantity"
    t.string "unit"
    t.string "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_leftovers_on_ingredient_id"
    t.index ["user_id"], name: "index_leftovers_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "review_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_likes_on_review_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "mealplans", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_mealplans_on_user_id", unique: true
  end

  create_table "myrecipeingredientlinks", force: :cascade do |t|
    t.bigint "myrecipe_id"
    t.bigint "ingredient_id"
    t.string "quantity"
    t.string "unit", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "expiry_date"
    t.index ["ingredient_id"], name: "index_myrecipeingredientlinks_on_ingredient_id"
    t.index ["myrecipe_id"], name: "index_myrecipeingredientlinks_on_myrecipe_id"
    t.index ["quantity"], name: "index_myrecipeingredientlinks_on_quantity"
    t.index ["unit"], name: "index_myrecipeingredientlinks_on_unit"
  end

  create_table "myrecipemealplanlinks", force: :cascade do |t|
    t.bigint "mealplan_id"
    t.bigint "myrecipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mealplan_id"], name: "index_myrecipemealplanlinks_on_mealplan_id"
    t.index ["myrecipe_id"], name: "index_myrecipemealplanlinks_on_myrecipe_id"
  end

  create_table "myrecipes", force: :cascade do |t|
    t.string "title"
    t.integer "cooking_time_in_min"
    t.string "videoURL"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "myrecipeingredientlink_id"
    t.boolean "is_hidden", default: true
    t.string "cooking_time"
    t.bigint "user_id"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["myrecipeingredientlink_id"], name: "index_myrecipes_on_myrecipeingredientlink_id", unique: true
    t.index ["title"], name: "index_myrecipes_on_title"
    t.index ["user_id"], name: "index_myrecipes_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.bigint "myrecipe_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["myrecipe_id"], name: "index_reviews_on_myrecipe_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "myrecipe_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["myrecipe_id"], name: "index_taggings_on_myrecipe_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
  end

  create_table "userdietaryrestrictionlinks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "dietaryrestriction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dietaryrestriction_id"], name: "index_userdietaryrestrictionlinks_on_dietaryrestriction_id"
    t.index ["user_id"], name: "index_userdietaryrestrictionlinks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean "is_admin", default: false
    t.integer "tags", default: [], array: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "usertaggings", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_usertaggings_on_tag_id"
    t.index ["user_id"], name: "index_usertaggings_on_user_id"
  end

  add_foreign_key "completions", "myrecipes"
  add_foreign_key "completions", "users"
  add_foreign_key "dietaryrestrictionlinks", "dietaryrestrictions"
  add_foreign_key "dietaryrestrictionlinks", "myrecipes"
  add_foreign_key "favourites", "myrecipes"
  add_foreign_key "favourites", "users"
  add_foreign_key "groceries", "users"
  add_foreign_key "ingredients", "myrecipeingredientlinks"
  add_foreign_key "leftovers", "ingredients"
  add_foreign_key "leftovers", "users"
  add_foreign_key "likes", "reviews"
  add_foreign_key "likes", "users"
  add_foreign_key "mealplans", "users"
  add_foreign_key "myrecipeingredientlinks", "ingredients"
  add_foreign_key "myrecipeingredientlinks", "myrecipes"
  add_foreign_key "myrecipemealplanlinks", "mealplans"
  add_foreign_key "myrecipemealplanlinks", "myrecipes"
  add_foreign_key "myrecipes", "myrecipeingredientlinks"
  add_foreign_key "myrecipes", "users"
  add_foreign_key "reviews", "myrecipes"
  add_foreign_key "reviews", "users"
  add_foreign_key "taggings", "myrecipes"
  add_foreign_key "taggings", "tags"
  add_foreign_key "userdietaryrestrictionlinks", "dietaryrestrictions"
  add_foreign_key "userdietaryrestrictionlinks", "users"
  add_foreign_key "usertaggings", "tags"
  add_foreign_key "usertaggings", "users"
end
