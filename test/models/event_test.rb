require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "valid event" do
    event = Event.new(name: "event_name", info: "infooo")
    assert event.valid?
  end

  test "invalid event" do
    event = Event.new(info: "infooo")
    assert_not event.valid?
  end
end
