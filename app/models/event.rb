class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true

  #validates :eventable, presence: true
  validates :name, presence: true
end

# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  eventable_type :string(255)      not null
#  info           :string(255)
#  info2          :string(255)
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eventable_id   :bigint           not null
#
# Indexes
#
#  index_events_on_eventable  (eventable_type,eventable_id)
#
