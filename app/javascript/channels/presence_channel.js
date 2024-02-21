import consumer from "channels/consumer"

consumer.subscriptions.create("PresenceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  /*
    @param {Object} data - The data received from the server
    @param {Boolean} data.presence - The presence value
    @param {String} data.line1 - The first line of the message
    @param {String} data.line2 - The second line of the message
   */
  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const controller = document.querySelector('div[data-controller="parlament"]')
    if (data && controller) {
      controller.dataset.parlamentPresenceValue = data["presence"].toString()
      controller.dataset.parlamentLine1Value = data["line1_text"]
      controller.dataset.parlamentLine2Value = data["line2_text"]
    }
  }
});
