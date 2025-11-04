require "redis"

# Store current presence in Parlament
class ParlamentState
  include Singleton

  VALID_PERIOD = 30.minutes.freeze

  attr_reader :redis

  def initialize
    redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
    @redis = Redis.new url: redis_url
  end

  def broadcast!
    ActionCable.server.broadcast("parlament_presence_channel", as_json)
  end

  # rubocop:disable Naming/PredicateMethod
  # @return [Boolean] true if presence is set to true and updated within VALID_PERIOD
  def presence
    timestamp, value = redis.mget("presence_updated_at", "parlament_presence")
    return false unless timestamp && value

    presence_at = Time.zone.at(timestamp.to_i)
    value == "true" && presence_at >= VALID_PERIOD.ago
  end

  alias presence? presence

  # rubocop:enable Naming/PredicateMethod

  def presence=(value)
    # Converts input value to a boolean
    boolean_value = !!value
    redis.set("parlament_presence", boolean_value.to_s)
    redis.set("presence_updated_at", Time.current.to_i.to_s)
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
