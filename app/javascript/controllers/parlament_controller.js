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
        this.headingTarget.textContent = "Hlásím přítomnost"
        this.headingTarget.style.color = "var(--bs-success)"
        this.subtextTarget.textContent = "Těžká debata! 🍻"

    }
    presenceOut() {
        this.headingTarget.textContent = "Prázdno"
        this.headingTarget.style.color = "var(--bs-danger)"
        this.subtextTarget.textContent = "Právě teď tu nikdo není"
    }
}
