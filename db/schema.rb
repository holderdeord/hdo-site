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

ActiveRecord::Schema.define(:version => 20120502204334) do

  create_table "committees", :force => true do |t|
    t.string   "external_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

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
  end

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
  end

  add_index "issues", ["committee_id"], :name => "index_issues_on_committee_id"

  create_table "issues_topics", :id => false, :force => true do |t|
    t.integer "issue_id"
    t.integer "topic_id"
  end

  add_index "issues_topics", ["issue_id", "topic_id"], :name => "index_issues_topics_on_issue_id_and_topic_id"

  create_table "parties", :force => true do |t|
    t.string   "external_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "parties", ["name"], :name => "index_parties_on_name"

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
    t.string   "body"
    t.string   "on_behalf_of"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
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
  end

  add_index "representatives", ["district_id"], :name => "index_representatives_on_district_id"
  add_index "representatives", ["last_name"], :name => "index_representatives_on_last_name"
  add_index "representatives", ["party_id"], :name => "index_representatives_on_party_id"

  create_table "topics", :force => true do |t|
    t.string   "external_id"
    t.integer  "parent_id"
    t.string   "name"
    t.boolean  "main"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

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
    t.integer  "issue_id"
    t.integer  "for_count"
    t.integer  "against_count"
    t.integer  "absent_count"
    t.boolean  "enacted"
    t.string   "subject"
    t.datetime "time"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "votes", ["issue_id"], :name => "index_votes_on_issue_id"

end
