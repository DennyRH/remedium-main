import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pending"
export default class extends Controller {
  static targets = [
    "totalPendingPayment", "moneyReceivedPending", "moneyReceivedPendingSee"
  ]

  redirectShowPending(e) {
    location.href = e.target.id
  }

  setMoneyReceived(e) {
    const total = this.totalPendingPaymentTarget.value
    this.moneyReceivedPendingTarget.value = (Number(e.target.value) - Number(total)).toFixed(2)
    this.moneyReceivedPendingSeeTarget.innerHTML = this.moneyReceivedPendingTarget.value
  }
}
