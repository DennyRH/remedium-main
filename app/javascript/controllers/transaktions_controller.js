import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transaktions"
export default class extends Controller {
  static targets = [
    "formSearchTransaktions", "inputSearchTransaktions", "formSearchTransaktionsFilter",
    "idReceiverPosSessionIdAnnulled"
  ]

  searchTransaktions() {
    if (this.inputSearchTransaktionsTarget.value === '') location.href = location.href

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchTransaktionsTarget.requestSubmit()
    }, 300)
  }

  sendRequestTransaktionFilter(e) {
    e.preventDefault()
    this.formSearchTransaktionsFilterTarget.requestSubmit()
  }

  redirectShowTransaktion(e) {
    location.href = e.target.id
  }

  setIdPosSessionReceivarAnnulled(e) {
    this.idReceiverPosSessionIdAnnulledTarget.value = e.target.value
  }
}
