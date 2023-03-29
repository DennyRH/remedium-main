import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="item"
export default class extends Controller {
  static targets = [
    "listPriceItem", "listPriceDiscountItem", "purchaseCostUnitItem",
    "purchaseCostPackageItem", "salePriceUnitItem", "salePriceUnitPercentItem",
    "salePricePackageItem", "salePricePackagePercentItem", "quantityPackageItemForm",
    "totalStockItemForm", "checkboxitemEditOne", "checkboxitemEditAll", "warehouseEditContextItem",
    "formSearchItems", "inputSearchItems", "urlShowItems", "formFilterKardex"
  ]

  searchItems() {
    if (this.inputSearchItemsTarget.value === '') location.href = location.href

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchItemsTarget.requestSubmit()
    }, 300)
  }

  sendFilterKardex() {
    this.formFilterKardexTarget.requestSubmit()
  }

  setPriceListItem(e) {
    const value = e.target.value
    const totalUnits = document.getElementById("totalUnitsProductInItem").value

    this.purchaseCostUnitItemTarget.value = (value / totalUnits).toFixed(2)
    this.purchaseCostPackageItemTarget.value = value
    this.salePriceUnitItemTarget.value = this.purchaseCostUnitItemTarget.value
    this.salePricePackageItemTarget.value = this.purchaseCostPackageItemTarget.value
  }

  calculateDiscountListPrice() {
    const totalUnits = document.getElementById("totalUnitsProductInItem").value
    const priceListDiscount = this.listPriceDiscountItemTarget.value.length == 1 ? `0${this.listPriceDiscountItemTarget.value}` : this.listPriceDiscountItemTarget.value
    const discount = this.listPriceItemTarget.value * Number(`0.${priceListDiscount}`)
    const result = this.listPriceItemTarget.value - discount

    this.listPriceItemTarget.value = result.toFixed(2)
    this.purchaseCostUnitItemTarget.value = (result / totalUnits).toFixed(2)
    this.purchaseCostPackageItemTarget.value = this.listPriceItemTarget.value
    this.salePriceUnitItemTarget.value = this.purchaseCostUnitItemTarget.value
    this.salePricePackageItemTarget.value = this.purchaseCostPackageItemTarget.value
    this.listPriceDiscountItemTarget.value = ''
  }

  calculatePriceUnit() {
    const priceUnit = Number(this.salePriceUnitItemTarget.value)
    const percent = this.salePriceUnitPercentItemTarget.value
    const increase = priceUnit * (percent / 100)
    this.salePriceUnitItemTarget.value = (priceUnit + increase).toFixed(2)
    this.salePriceUnitPercentItemTarget.value = ''
  }

  calculatePricePackage() {
    const totalUnits = document.getElementById("totalUnitsProductInItem").value
    const pricePackage = Number(this.salePricePackageItemTarget.value)
    const percent = this.salePricePackagePercentItemTarget.value
    const increase = pricePackage * (percent / 100)
    this.salePricePackageItemTarget.value = (pricePackage + increase).toFixed(2)
    this.salePriceUnitItemTarget.value = (this.salePricePackageItemTarget.value / totalUnits).toFixed(2)
    this.salePricePackagePercentItemTarget.value = ''
  }

  setTotalStockItem(e) {
    const value = Number(e.target.value)
    const totalUnits = Number(document.getElementById("totalUnitsProductInItem").value)
    this.quantityPackageItemFormTarget.value = Math.trunc(value / totalUnits)
  }

  setQtyPackageItem(e) {
    const value = e.target.value
    const totalUnits = Number(document.getElementById("totalUnitsProductInItem").value)
    this.totalStockItemFormTarget.value = value * totalUnits
  }

  currentWarehouseSelect(e) {
    if (e.target.checked) {
      this.warehouseEditContextItemTarget.value = 'Current Warehouse'
      this.checkboxitemEditAllTarget.checked = false
    }
  }

  allWarehouseSelect(e) {
    if (e.target.checked) {
      this.warehouseEditContextItemTarget.value = 'All Warehouses'
      this.checkboxitemEditOneTarget.checked = false
    }
  }

  redirectItemShow(e) {
    location.href = e.target.id
  }
}
