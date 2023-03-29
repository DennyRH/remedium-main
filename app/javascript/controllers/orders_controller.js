import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="orders"
export default class extends Controller {
  static targets = [
    "formSearchProvider", "inputSearchProvider", "providerId", "searchResultProviders",
    "formFilterSuggestions"
  ]

  searchProviders() {
    if (this.inputSearchProviderTarget.value.length < 3) {
      this.searchResultProvidersTarget.innerHTML = ''
      this.providerIdTarget.value = ''
      return;
    }

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchProviderTarget.requestSubmit()
    }, 300)
  }

  selectProvider(e) {
    const provider = JSON.parse(e.target.attributes.value.value).customer
    this.inputSearchProviderTarget.value = provider.name
    this.searchResultProvidersTarget.innerHTML = ''
    this.providerIdTarget.value = provider.id
    this.formFilterSuggestionsTarget.requestSubmit()
  }

  sendFormFilter() {
    this.formFilterSuggestionsTarget.requestSubmit()
  }
}
