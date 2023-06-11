import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    static values = {
        presence: Boolean
    }
    static targets = [ "heading", "subtext" ]

    connect() {
        this.presenceValueChanged()
    }
    presenceValueChanged() {
        if (this.presenceValue) {
            this.presenceIn()
        } else {
            this.presenceOut()
        }
    }

    presenceIn() {
        this.headingTarget.textContent = "Parlament je otevřený"
        this.headingTarget.style.color = "var(--bs-success)"
        this.subtextTarget.textContent = "Jsme na parlamentu! 🍻"

    }
    presenceOut() {
        this.headingTarget.textContent = "Parlament je zavřený"
        this.headingTarget.style.color = "var(--bs-danger)"
        this.subtextTarget.textContent = "Právě teď tu nikdo není"
    }
}
