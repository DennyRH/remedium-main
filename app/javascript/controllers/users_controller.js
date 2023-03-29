import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="users"
export default class extends Controller {
  static targets = ["formSearchUsers", "inputSearchUsers", "formSearchUsersFilter"]

  searchUsers() {
    if (this.inputSearchUsersTarget.value === '') location.href = location.href

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchUsersTarget.requestSubmit()
    }, 300)
  }

  sendRequestUserFilter(e) {
    e.preventDefault()
    this.formSearchUsersFilterTarget.requestSubmit()
  }
}
