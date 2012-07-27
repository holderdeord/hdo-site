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

ActiveRecord::Schema.define(:version => 20120717160943) do

  create_table "categories", :force => true do |t|
    t.string   "external_id"
    t.integer  "parent_id"
    t.string   "name"
    t.boolean  "main"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "slug"
  end

  add_index "categories", ["slug"], :name => "index_categories_on_slug", :unique => true

  create_table "categories_issues", :id => false, :force => true do |t|
    t.integer "issue_id"
    t.integer "category_id"
  end

  add_index "categories_issues", ["issue_id", "category_id"], :name => "index_categories_issues_on_issue_id_and_category_id"

  create_table "categories_promises", :id => false, :force => true do |t|
    t.integer "promise_id"
    t.integer "category_id"
  end

  add_index "categories_promises", ["promise_id", "category_id"], :name => "index_categories_promises_on_issue_id_and_category_id"

  create_table "categories_topics", :id => false, :force => true do |t|
    t.integer "category_id"
    t.integer "topic_id"
  end

  add_index "categories_topics", ["category_id", "topic_id"], :name => "index_categories_topics_on_category_id_and_topic_id"

  create_table "committees", :force => true do |t|
    t.string   "external_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "slug"
  end

  add_index "committees", ["slug"], :name => "index_committees_on_slug", :unique => true

  create_table "committees_representatives", :id => false, :force => true do |t|
    t.integer "committee_id"
    t.integer "representative_id"
  end

  add_index "committees_representatives", ["committee_id", "representative_id"], :name => "index_com_reps"

  create_table "districts", :force => true do |t|
    t.string   "external_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "slug"
  end

  add_index "districts", ["slug"], :name => "index_districts_on_slug", :unique => true

  create_table "fields", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
    t.string   "image_uid"
    t.string   "image_name"
  end

  add_index "fields", ["slug"], :name => "index_fields_on_slug", :unique => true

  create_table "fields_topics", :id => false, :force => true do |t|
    t.integer "field_id"
    t.integer "topic_id"
  end

  add_index "fields_topics", ["field_id", "topic_id"], :name => "index_fields_topics_on_field_id_and_topic_id"

  create_table "issues", :force => true do |t|
    t.string   "external_id"
    t.string   "summary"
    t.string   "description"
    t.string   "issue_type"
    t.string   "status"
    t.datetime "last_update"
    t.string   "document_group"
    t.string   "reference"
    t.integer  "committee_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "slug"
  end

  add_index "issues", ["committee_id"], :name => "index_issues_on_committee_id"
  add_index "issues", ["slug"], :name => "index_issues_on_slug", :unique => true

  create_table "issues_votes", :id => false, :force => true do |t|
    t.integer "issue_id"
    t.integer "vote_id"
  end

  add_index "issues_votes", ["vote_id", "issue_id"], :name => "index_issues_votes_on_vote_id_and_issue_id"

  create_table "parties", :force => true do |t|
    t.string   "external_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "slug"
  end

  add_index "parties", ["name"], :name => "index_parties_on_name"
  add_index "parties", ["slug"], :name => "index_parties_on_slug", :unique => true

  create_table "promises", :force => true do |t|
    t.integer  "party_id"
    t.string   "body"
    t.boolean  "general"
    t.string   "source"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "promises", ["party_id"], :name => "index_promises_on_party_id"

  create_table "promises_topics", :id => false, :force => true do |t|
    t.integer "promise_id"
    t.integer "topic_id"
  end

  add_index "promises_topics", ["promise_id", "topic_id"], :name => "index_promises_topics_on_promise_id_and_topic_id"

  create_table "propositions", :force => true do |t|
    t.string   "external_id"
    t.string   "representative_id"
    t.integer  "vote_id"
    t.string   "description"
    t.text     "body",              :limit => 300000
    t.string   "on_behalf_of"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "propositions", ["representative_id", "vote_id"], :name => "index_propositions_on_representative_id_and_vote_id"

  create_table "representatives", :force => true do |t|
    t.string   "external_id"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "party_id"
    t.integer  "district_id"
    t.datetime "date_of_birth"
    t.datetime "date_of_death"
    t.string   "slug"
    t.string   "image_uid"
    t.string   "image_name"
  end

  add_index "representatives", ["district_id"], :name => "index_representatives_on_district_id"
  add_index "representatives", ["last_name"], :name => "index_representatives_on_last_name"
  add_index "representatives", ["party_id"], :name => "index_representatives_on_party_id"
  add_index "representatives", ["slug"], :name => "index_representatives_on_slug", :unique => true

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "slug"
  end

  add_index "topics", ["slug"], :name => "index_topics_on_slug", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vote_directions", :force => true do |t|
    t.boolean  "matches"
    t.integer  "vote_id"
    t.integer  "topic_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "vote_directions", ["vote_id", "topic_id"], :name => "index_vote_directions_on_vote_id_and_topic_id"

  create_table "vote_results", :force => true do |t|
    t.integer  "representative_id"
    t.integer  "vote_id"
    t.integer  "result"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "vote_results", ["representative_id", "vote_id"], :name => "index_vote_results_on_representative_id_and_vote_id"

  create_table "votes", :force => true do |t|
    t.string   "external_id"
    t.integer  "for_count"
    t.integer  "against_count"
    t.integer  "absent_count"
    t.boolean  "enacted"
    t.string   "subject"
    t.datetime "time"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "slug"
  end

  add_index "votes", ["slug"], :name => "index_votes_on_slug", :unique => true

end
