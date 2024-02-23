import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {

  static values = {
    presence: Boolean,
    line1: String,
    line2: String
  }
  static targets = ["heading", "subtext"]

  connect() {
    this.presenceValueChanged()
    setTimeout(() => {
      this.fetchAndShowDialog();
    }, 4000);
  }

  presenceValueChanged() {
    this.headingTarget.textContent = this.line1Value
    this.subtextTarget.textContent = this.line2Value

    if (this.presenceValue) {
      this.#presenceIn()
    } else {
      this.#presenceOut()
    }
  }

  showDialog({title, body, updatedAt}) {
    let modalHTML = `
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">${title}</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          ${body}
        </div>
        <div class="modal-footer">
          <div class="col">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="doNotShowAgain">
              <label class="form-check-label" for="doNotShowAgain">
                Tuto zprávu již nezobrazovat
              </label>
            </div>
          </div>
          <div class="col text-end">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Zavřít</button>
          </div>
        </div>
      </div>
    </div>
  `;

    let modalElement = document.createElement("div");
    modalElement.id = "announcementModal"
    modalElement.className = "modal fade";
    modalElement.innerHTML = modalHTML;
    document.body.appendChild(modalElement);

    let modal = new Modal(modalElement);
    modal.show();
    modalElement.addEventListener("hidden.bs.modal", event => {
      let checkbox = document.getElementById("doNotShowAgain");
      if (checkbox.checked) {
        let adDialog = JSON.parse(localStorage.getItem("ad-dialog")) || [];
        adDialog.push(updatedAt);
        localStorage.setItem("ad-dialog", JSON.stringify(adDialog));
      }
    });
  }

  async fetchAndShowDialog() {
    try {
      let response = await fetch("/parlament/announcement");
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      let page = await response.json();
      let adDialog = JSON.parse(localStorage.getItem("ad-dialog")) || [];
      if (page.body && !adDialog.includes(page.updated_at)) {
        this.showDialog({
          title: page.title,
          body: page.body,
          updatedAt: page.updated_at
        });
      }
    } catch (error) {
      console.log("Fetch Error: ", error);
    }
  }

  #presenceIn() {
    this.headingTarget.style.color = "var(--bs-success)"
  }

  #presenceOut() {
    this.headingTarget.style.color = "var(--bs-danger)"
  }
}