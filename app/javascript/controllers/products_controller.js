import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="products"
export default class extends Controller {
  static targets = [
    "inputSearchProducts", "formSearchProducts", "customerId",
    "inputSearchProvider", "socialReasonProvider", "emailProvider", "formFilterKardex"
  ]

  searchProducts() {
    if (this.inputSearchProductsTarget.value === '') location.href = location.href
    if (this.inputSearchProductsTarget.value.length < 3) return;

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchProductsTarget.requestSubmit()
    }, 300)
  }

  redirectShowProduct(e) {
    location.href = e.target.id
  }

  sendFilterKardex() {
    this.formFilterKardexTarget.requestSubmit()
  }

  searchProvider() {
    if (this.inputSearchProviderTarget.value == '') {
      this.customerIdTarget.value = ''
      this.socialReasonProviderTarget.value = ''
      this.emailProviderTarget.value = ''
    }
    if(this.inputSearchProviderTarget.value.length < 5) return

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      fetch('/providers/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        },
        body: JSON.stringify({
          filter: this.inputSearchProviderTarget.value
        })
      })
        .then(response => response.json())
        .then(data => {
          if (!data) {
            this.customerIdTarget.value = ''
            this.emailProviderTarget.value = ''
            this.socialReasonProviderTarget.value = ''
          } else {
            this.customerIdTarget.value = data.id
            this.socialReasonProviderTarget.value = data.name
            this.inputSearchProviderTarget.value = data.document_number
            this.emailProviderTarget.value = data.email
          }
        })
    }, 700)
  }
}
