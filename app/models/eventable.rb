# frozen_string_literal: true

# eventable module is included in classes. adds [object].log('event')

module Eventable
  def self.included(base)
    base.has_many :events, as: :eventable do
      def log(event_name, info = nil, info2 = nil)
        create(name: event_name, info: info, info2: info2)
      end

      # will only send event without save
      def log_volatile(event_name, info = nil, info2 = nil)
        l = new(name: event_name, info: info, info2: info2)
        l.send :fire_callbacks
      end

      def changed(attr_name, from = nil, to = nil)
        create(name: "#{attr_name}_changed", info: from, info2: to)
      end
    end
  end
end
