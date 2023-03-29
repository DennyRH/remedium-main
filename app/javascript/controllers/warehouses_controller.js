import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="warehouses"
export default class extends Controller {
  static targets = ["formSearchWarehouses", "inputSearchWarehouses"]

  searchWarehouses() {
    if (this.inputSearchWarehousesTarget.value === '') location.href = location.href

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchWarehousesTarget.requestSubmit()
    }, 300)
  }

  searchFilterSelectWarehouse(e) {
    this.inputSearchWarehousesTarget.value = e.target.value
    this.formSearchWarehousesTarget.requestSubmit()
    this.inputSearchWarehousesTarget.value = ''
  }
}
