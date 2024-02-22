import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static values = {
    presence: Boolean,
    line1: String,
    line2: String
  }
  static targets = ["heading", "subtext"]

  connect() {
    this.presenceValueChanged()
  }

  presenceValueChanged() {
    this.headingTarget.textContent = this.line1Value
    this.subtextTarget.textContent = this.line2Value

    if (this.presenceValue) {
      this.presenceIn()
    } else {
      this.presenceOut()
    }
  }

  presenceIn() {
    this.headingTarget.style.color = "var(--bs-success)"
  }

  presenceOut() {
    this.headingTarget.style.color = "var(--bs-danger)"
  }
}
