import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="customers"
export default class extends Controller {
  static targets = ["formSearchCustomers", "inputSearchCustomer", "urlShowCustomer"]

  searchCustomers() {
    if (this.inputSearchCustomerTarget.value === '') location.href = location.href

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchCustomersTarget.requestSubmit()
    }, 300)
  }

  redirectShowCustomer(e) {
    location.href = e.target.id
  }
}
