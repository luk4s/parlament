# lib/parlament_state.rb

require 'redis'

class ParlamentState
  attr_reader :redis

  def initialize
    redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" }
    @redis = Redis.new url: redis_url
  end

  def self.instance
    new
  end

  def presence
    # Assuming the Redis key for 'presence' is 'parlament_presence'
    redis.get('parlament_presence') == 'true'
  end
  alias presence? presence

  def presence=(value)
    # Converts input value to a boolean
    boolean_value = !!value
    redis.set('parlament_presence', boolean_value.to_s)
    ActionCable.server.broadcast("parlament_presence_channel", { presence: boolean_value })
    boolean_value
  end
end
