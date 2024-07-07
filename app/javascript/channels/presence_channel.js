import consumer from "channels/consumer"

consumer.subscriptions.create("PresenceChannel", {
  // Called once when the subscription is created.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Called when the subscription is ready for use on the server.
  connected() {
    this.install()
    this.update()
  },

  // Called when the WebSocket connection is closed.
  disconnected() {
    this.uninstall()
  },

  // Called when the subscription is rejected by the server.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Calls `AppearanceChannel#appear(data)` on the server.
    this.perform("appear", { appeared_at: new Date()})
  },

  away() {
    // Calls `AppearanceChannel#away` on the server. = Not implemented
    // this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbo:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbo:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState === "visible" && document.hasFocus()
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
