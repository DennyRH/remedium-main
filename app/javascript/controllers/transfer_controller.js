import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transfer"
export default class extends Controller {
  static targets = [
    "formSearch", "productDescription", "totalStock", "searchResults",
    "subtotal", "subtotalProduct", "qtyPerPackage", "itemId", "inputSearchProduct",
    "priceUnit", "moneyReturnedSales", "sumTotalItemTransactions", "totalTransfer",
    "descriptionItemFormCreateProduct", "descriptionProductForm", "pricePackage",
    "qtyUnitSale", "qtyPackageSale", "unitTotalSale", "formSearchWarehouse",
    "searchResultsWarehouseTransfer", "warehouseIdTransfer", "inputSearchWarehouse",
    "formUpdateConfirmTransfer", "formAddItemTransaktionTransfer", "subtotalSee",
    "unitPackage"
  ]

  searchWarehouse() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchWarehouseTarget.requestSubmit()
    }, 300)
  }

  selectWarehouse(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)
    this.searchResultsWarehouseTransferTarget.innerHTML = ''
    this.warehouseIdTransferTarget.value = valueSelect.warehouse.id
    this.inputSearchWarehouseTarget.value = `${valueSelect.warehouse.name} ${valueSelect.warehouse_detail.address}`
    this.totalTransferTarget.value = this.sumTotalItemTransactionsTarget.innerHTML.replace(/[\n\r]+/g, '').trim()
  }

  searchProduct() {
    if (this.inputSearchProductTarget.value == '') this.resetValuesInputSales()

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchTarget.requestSubmit()
    }, 300)
  }

  selectProduct(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)

    this.searchResultsTarget.innerHTML = ''
    this.inputSearchProductTarget.value = valueSelect.product.description
    this.unitPackageTarget.innerHTML = valueSelect.product.total_unit

    if (valueSelect.available == "true") this.itemIdTarget.value = valueSelect.item.id

    this.qtyPerPackageTarget.value = valueSelect.product.total_unit
    this.productDescriptionTarget.innerHTML = valueSelect.product.description
    this.priceUnitTarget.innerHTML = valueSelect.item.purchase_cost_unit
    this.pricePackageTarget.innerHTML = valueSelect.item.purchase_cost_package
    this.totalStockTarget.innerHTML = valueSelect.item.total_stock
    this.subtotalProductTarget.value = valueSelect.item.purchase_price_unit
  }

  sumSubtotalForUnits(e) {
    let qtyPackage = Math.trunc(e.target.value / this.qtyPerPackageTarget.value)
    let qtyUnit = e.target.value % this.qtyPerPackageTarget.value

    let salePriceUnit = (qtyUnit * Number(this.priceUnitTarget.innerHTML)).toFixed(2)
    let salePricePackage = (qtyPackage * Number(this.pricePackageTarget.innerHTML)).toFixed(2)
    this.subtotalTarget.value = (Number(salePriceUnit) + Number(salePricePackage)).toFixed(2)
    this.subtotalSeeTarget.innerHTML = this.subtotalTarget.value
    this.qtyPackageSaleTarget.value = qtyPackage
    this.qtyUnitSaleTarget.value = qtyUnit
  }

  sumSubtotalForPackage(e) {
    let qtyPackage = e.target.value
    let qtyUnit = (e.target.value * this.qtyPerPackageTarget.value) % this.qtyPerPackageTarget.value

    let salePriceUnit = (qtyUnit * Number(this.priceUnitTarget.innerHTML)).toFixed(2)
    let salePricePackage = (qtyPackage * Number(this.pricePackageTarget.innerHTML)).toFixed(2)
    this.subtotalTarget.value = (Number(salePriceUnit) + Number(salePricePackage)).toFixed(2)
    this.subtotalSeeTarget.innerHTML = this.subtotalTarget.value
    this.qtyPackageSaleTarget.value = qtyPackage
    this.qtyUnitSaleTarget.value = qtyUnit
    this.unitTotalSaleTarget.value = e.target.value * this.qtyPerPackageTarget.value
  }

  setDescriptionToItemForm(e) {
    this.descriptionItemFormCreateProductTarget.value = `${this.descriptionProductFormTarget.value} ${e.target.value}`
  }

  resetValuesInputSales() {
    this.qtyPerPackageTarget.value = ''
    this.productDescriptionTarget.innerHTML = ''
    this.priceUnitTarget.innerHTML = ''
    this.pricePackageTarget.innerHTML = ''
    this.totalStockTarget.innerHTML = ''
    this.subtotalProductTarget.value = ''
    this.subtotalTarget.value = ''
    this.subtotalSeeTarget.innerHTML = '0'
    this.qtyPackageSaleTarget.value = ''
    this.unitPackageTarget.innerHTML = ''
    this.qtyUnitSaleTarget.value = ''
    this.unitTotalSaleTarget.value = ''
    this.inputSearchProductTarget.value = ''
  }

  addItemTransaktionAndReset() {
    this.formAddItemTransaktionTransferTarget.requestSubmit()
    this.resetValuesInputSales()
  }

  setTransferId(e) {
    const actionFormMarketRates = this.formUpdateConfirmTransferTarget.action.split('/')
    actionFormMarketRates[6] = e.target.value
    this.formUpdateConfirmTransferTarget.action = actionFormMarketRates.join('/')
  }
}
