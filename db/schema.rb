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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150211063356) do

  create_table "cards", force: true do |t|
    t.string   "word"
    t.string   "word_type",  default: ""
    t.string   "definition", default: ""
    t.string   "synonyms",   default: ""
    t.string   "antonyms",   default: ""
    t.string   "sentence",   default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating",     default: 0
  end

  add_index "cards", ["rating"], name: "index_cards_on_rating"
  add_index "cards", ["word"], name: "index_cards_on_word"

  create_table "cards_decks", id: false, force: true do |t|
    t.integer "card_id"
    t.integer "deck_id"
  end

  add_index "cards_decks", ["card_id", "deck_id"], name: "index_cards_decks_on_card_id_and_deck_id"
  add_index "cards_decks", ["deck_id", "card_id"], name: "index_cards_decks_on_deck_id_and_card_id"

  create_table "decks", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "decks", ["title"], name: "index_decks_on_title", unique: true

  create_table "reviews", force: true do |t|
    t.integer  "card_id",    null: false
    t.integer  "status",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["card_id", "status"], name: "index_reviews_on_card_id_and_status"

  create_table "todos", force: true do |t|
    t.string   "word"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "todos", ["word"], name: "index_todos_on_word"

end
