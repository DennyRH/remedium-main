import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [
    "formSearchWarehouse", "searchResultsWarehouse", "inputSearchWarehouse",
    "warehouseId", "formSearchProduct", "searchResultsProduct", "productId",
    "inputSearchProduct", "totalUnitsProduct"
  ]

  searchWarehouse() {
    if (this.inputSearchWarehouseTarget.value === '') {
      this.searchResultsWarehouseTarget.innerHTML = ''
    }
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchWarehouseTarget.requestSubmit()
    }, 300)
  }

  selectWarehouse(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)
    this.searchResultsWarehouseTarget.innerHTML = ''
    this.warehouseIdTarget.value = valueSelect.warehouse.id
    this.inputSearchWarehouseTarget.value = `${valueSelect.warehouse.name} ${valueSelect.warehouse_detail.address}`
  }

  searchProduct() {
    if (this.inputSearchProductTarget.value === '') {
      this.searchResultsProductTarget.innerHTML = ''
      this.totalUnitsProductTarget.value = ''
    }
    if (this.inputSearchProductTarget.value.length < 3) return;
    
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchProductTarget.requestSubmit()
    }, 300)
  }

  selectProduct(e) {
    const product = JSON.parse(e.target.attributes.value.value).product
    this.searchResultsProductTarget.innerHTML = ''
    this.productIdTarget.value = product.id
    this.inputSearchProductTarget.value = product.description
    this.totalUnitsProductTarget.value = product.total_unit
  }
}
