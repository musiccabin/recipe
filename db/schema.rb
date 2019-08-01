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

ActiveRecord::Schema.define(version: 2019_08_01_200344) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "completions", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "my_recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_recipe_id"], name: "index_completions_on_my_recipe_id"
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
    t.bigint "my_recipe_id"
    t.bigint "dietary_restriction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dietary_restriction_id"], name: "index_dietaryrestrictionlinks_on_dietary_restriction_id"
    t.index ["my_recipe_id"], name: "index_dietaryrestrictionlinks_on_my_recipe_id"
  end

  create_table "dietaryrestrictions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["name"], name: "index_dietaryrestrictions_on_name"
    t.index ["user_id"], name: "index_dietaryrestrictions_on_user_id", unique: true
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "my_recipe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_recipe_id"], name: "index_favourites_on_my_recipe_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "groceries", force: :cascade do |t|
    t.string "name"
    t.float "quantity"
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
    t.bigint "my_recipe_ingredient_link_id"
    t.index ["my_recipe_ingredient_link_id"], name: "index_ingredients_on_my_recipe_ingredient_link_id", unique: true
    t.index ["name"], name: "index_ingredients_on_name", unique: true
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
    t.bigint "myrecipe_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["myrecipe_id"], name: "index_mealplans_on_myrecipe_id", unique: true
    t.index ["user_id"], name: "index_mealplans_on_user_id", unique: true
  end

  create_table "myrecipeingredientlinks", force: :cascade do |t|
    t.bigint "my_recipe_id"
    t.bigint "ingredient_id"
    t.float "quantity"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_myrecipeingredientlinks_on_ingredient_id", unique: true
    t.index ["my_recipe_id"], name: "index_myrecipeingredientlinks_on_my_recipe_id", unique: true
    t.index ["quantity"], name: "index_myrecipeingredientlinks_on_quantity", unique: true
    t.index ["unit"], name: "index_myrecipeingredientlinks_on_unit", unique: true
  end

  create_table "myrecipes", force: :cascade do |t|
    t.string "title"
    t.integer "cooking_time_in_min"
    t.string "videoURL"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "my_recipe_ingredient_link_id"
    t.boolean "is_hidden", default: false
    t.string "cooking_time_in_string"
    t.index ["my_recipe_ingredient_link_id"], name: "index_myrecipes_on_my_recipe_ingredient_link_id", unique: true
    t.index ["title"], name: "index_myrecipes_on_title"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.bigint "my_recipe_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_recipe_id"], name: "index_reviews_on_my_recipe_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "my_recipe_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["my_recipe_id"], name: "index_taggings_on_my_recipe_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
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
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "completions", "myrecipes", column: "my_recipe_id"
  add_foreign_key "completions", "users"
  add_foreign_key "dietaryrestrictionlinks", "dietaryrestrictions", column: "dietary_restriction_id"
  add_foreign_key "dietaryrestrictionlinks", "myrecipes", column: "my_recipe_id"
  add_foreign_key "dietaryrestrictions", "users"
  add_foreign_key "favourites", "myrecipes", column: "my_recipe_id"
  add_foreign_key "favourites", "users"
  add_foreign_key "groceries", "users"
  add_foreign_key "ingredients", "myrecipeingredientlinks", column: "my_recipe_ingredient_link_id"
  add_foreign_key "likes", "reviews"
  add_foreign_key "likes", "users"
  add_foreign_key "mealplans", "myrecipes"
  add_foreign_key "mealplans", "users"
  add_foreign_key "myrecipeingredientlinks", "ingredients"
  add_foreign_key "myrecipeingredientlinks", "myrecipes", column: "my_recipe_id"
  add_foreign_key "myrecipes", "myrecipeingredientlinks", column: "my_recipe_ingredient_link_id"
  add_foreign_key "reviews", "myrecipes", column: "my_recipe_id"
  add_foreign_key "reviews", "users"
  add_foreign_key "taggings", "myrecipes", column: "my_recipe_id"
  add_foreign_key "taggings", "tags"
end
