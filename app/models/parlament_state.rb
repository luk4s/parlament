require "redis"

# Store current presence in Parlament
class ParlamentState
  include Singleton

  attr_reader :redis

  def initialize
    redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
    @redis = Redis.new url: redis_url
  end

  def broadcast!
    ActionCable.server.broadcast("parlament_presence_channel", as_json)
  end

  def presence
    # Assuming the Redis key for 'presence' is 'parlament_presence'
    redis.get("parlament_presence") == "true"
  end

  alias presence? presence

  def presence=(value)
    # Converts input value to a boolean
    boolean_value = !!value
    redis.set("parlament_presence", boolean_value.to_s)
    broadcast!
  end

  # @return [String] From Spina
  def line1_text
    page = Spina::Page.find_by! name: "state_#{presence_state}"
    page.title
  end

  def line2_text
    page = Spina::Page.find_by! name: "state_#{presence_state}"
    page.content(:line2)
  end

  def as_json(*_)
    {
      presence:,
      line1_text:,
      line2_text:,
    }
  end

  private

  def presence_state
    presence? ? "on" : "off"
  end

end
