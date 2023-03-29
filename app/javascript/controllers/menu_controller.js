import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon", "options"]

  change() {
    let icon = this.iconTarget.classList[1]

    if (icon === "fa-bars") {
      this.iconTarget.classList.replace("fa-bars", "fa-xmark")
    } else {
      this.iconTarget.classList.replace("fa-xmark", "fa-bars")
    }

    this.optionsTarget.classList.toggle("hidden")
  }
}
