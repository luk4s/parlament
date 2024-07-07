class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "parlament_presence_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def appear(_data)
    transmit ParlamentState.instance.as_json
  end
end
