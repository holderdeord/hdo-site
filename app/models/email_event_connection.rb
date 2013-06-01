class EmailEventConnection < ActiveRecord::Base
  belongs_to :email_event
  belongs_to :email_event_associable, polymorphic: true
end
