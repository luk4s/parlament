import consumer from "channels/consumer"

consumer.subscriptions.create("PresenceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const controller = document.querySelector('div[data-controller="parlament"]')
    if (data && controller) {
      controller.dataset.parlamentPresenceValue = data["presence"]
    }
  }
});
