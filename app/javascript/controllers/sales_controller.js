import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sales"
export default class extends Controller {
  static targets = [
    "formSearch", "productDescription", "totalStock", "searchResults",
    "subtotal", "subtotalProduct", "qtyPerPackage", "itemId", "inputSearchProduct",
    "priceUnit", "moneyReturnedSales", "sumTotalItemTransactions", "totalSales",
    "descriptionItemFormCreateProduct", "descriptionProductForm", "pricePackage", "unitPackage",
    "qtyUnitSale", "qtyPackageSale", "unitTotalSale", "formSearchCustomer",
    "inputSearchProduct", "searchResultsCustomerSales", "customerIdSales", "nitCustomerSales",
    "socialReasonCustomerSales", "inputSearchCustomer", "formSearchInOtherWarehouse",
    "inputSearchProductInOtherWarehouse", "emailCustomerSales", "posSessionId",
    "formAddItemTransaktionSales", "submitForm", "itemCode", "itemDescription",
    "sumTotalWithReceived", "subtotalSee", "moneyReturnedSalesSee"
  ]

  searchBuyer() {
    if (this.inputSearchCustomerTarget.value == '' ) {
      this.customerIdSalesTarget.value = ''
      this.socialReasonCustomerSalesTarget.value = ''
      this.emailCustomerSalesTarget.value = ''
    }

    if(this.inputSearchCustomerTarget.value.length < 5) return

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      fetch('/buyers/search', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        },
        body: JSON.stringify({
          filter: this.inputSearchCustomerTarget.value
        })
      })
        .then(response => response.json())
        .then(data => {
          this.toggleSubmitFormButton()
          if (!data) {
            this.customerIdSalesTarget.value = ''
            this.emailCustomerSalesTarget.value = ''
            this.socialReasonCustomerSalesTarget.value = ''
          } else {
            this.inputSearchCustomerTarget.value = Number(data.document_number)
            this.socialReasonCustomerSalesTarget.value = data.name
            this.emailCustomerSalesTarget.value = data.email
            this.customerIdSalesTarget.value = data.id
          }
        })
    }, 500)
  }

  selectCustomer(e) {
    const customer = JSON.parse(e.target.attributes.value.value).customer
    this.searchResultsCustomerSalesTarget.innerHTML = ''

    if (customer && !customer.company_name && !customer.social_reason) {
      this.socialReasonCustomerSalesTarget.value = `${customer.name}`
      this.inputSearchCustomerTarget.value = `${customer.name} ${customer.nit}`
    } else {
      this.socialReasonCustomerSalesTarget.value = `${customer.company_name ? customer.company_name : ''} ${customer.social_reason}`
      this.inputSearchCustomerTarget.value = `${customer.company_name ? customer.company_name : ''} ${customer.social_reason} ${customer.nit}`
    }
  }

  searchProduct() {
    if (this.inputSearchProductTarget.value === '') this.resetValuesInputSales()
    if (this.inputSearchProductTarget.value.length < 3) {
      this.searchResultsTarget.innerHTML = ""
      return
    }


    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchTarget.requestSubmit()
    }, 300)
  }

  searchProductInOtherWarehouse() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchInOtherWarehouseTarget.requestSubmit()
    }, 300)
  }

  selectProductInOtherWarehouse(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)

    this.searchResultsTarget.innerHTML = ''
    this.inputSearchProductInOtherWarehouseTarget.value = valueSelect.product.description

    if (valueSelect.available == "true") {
      this.itemIdTarget.value = valueSelect.item.id
    }

    this.qtyPerPackageTarget.value = valueSelect.product.total_unit
    this.productDescriptionTarget.innerHTML = valueSelect.product.description
    this.priceUnitTarget.innerHTML = valueSelect.item.sale_price_unit
    this.unitPackageTarget.innerHTML = valueSelect.product.total_unit
    this.pricePackageTarget.innerHTML = valueSelect.item.sale_price_package
    this.totalStockTarget.innerHTML = valueSelect.item.total_stock
    this.subtotalProductTarget.value = valueSelect.item.sale_price_unit
  }

  selectProduct(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)

    this.searchResultsTarget.innerHTML = ''
    this.inputSearchProductTarget.value = valueSelect.product.description

    if (valueSelect.available == "true") {
      this.itemIdTarget.value = valueSelect.item.id
    }

    this.qtyPerPackageTarget.value = valueSelect.product.total_unit
    this.productDescriptionTarget.innerHTML = valueSelect.product.description
    this.priceUnitTarget.innerHTML = valueSelect.item.sale_price_unit
    this.unitPackageTarget.innerHTML = valueSelect.product.total_unit
    this.pricePackageTarget.innerHTML = valueSelect.item.sale_price_package
    this.totalStockTarget.innerHTML = valueSelect.item.total_stock
    this.subtotalProductTarget.value = valueSelect.item.sale_price_unit
  }

  sumSubtotalForUnits(e) {
    let qtyPackage = Math.trunc(e.target.value / this.qtyPerPackageTarget.value)
    let qtyUnit = e.target.value % this.qtyPerPackageTarget.value
    let salePriceUnit = (qtyUnit * Number(this.priceUnitTarget.innerHTML)).toFixed(2)
    let salePricePackage = (qtyPackage * Number(this.pricePackageTarget.innerHTML)).toFixed(2)
    const subtotal = (Number(salePriceUnit) + Number(salePricePackage)).toFixed(2)
    this.subtotalTarget.value = subtotal
    this.subtotalSeeTarget.innerHTML = subtotal
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

  sumTotalWithReceived(e) {
    this.moneyReturnedSalesTarget.value = (Number(e.target.value) - Number(this.sumTotalItemTransactionsTarget.innerHTML)).toFixed(2)
    this.totalSalesTarget.value = this.sumTotalItemTransactionsTarget.innerHTML.replace(/[\n\r]+/g, '').trim()
    this.moneyReturnedSalesSeeTarget.innerHTML = this.moneyReturnedSalesTarget.value
    this.toggleSubmitFormButton()
  }

  setDescriptionToItemForm(e) {
    this.descriptionItemFormCreateProductTarget.value = `${this.descriptionProductFormTarget.value} ${e.target.value}`
  }

  resetValuesInputSales() {
    this.itemIdTarget.value = 0
    this.qtyPerPackageTarget.value = ''
    this.productDescriptionTarget.innerHTML = ''
    this.priceUnitTarget.innerHTML = ''
    this.pricePackageTarget.innerHTML = ''
    this.totalStockTarget.innerHTML = ''
    this.subtotalProductTarget.value = ''
    this.subtotalTarget.value = ''
    this.unitPackageTarget.innerHTML = ''
    this.subtotalSeeTarget.innerHTML = '0'
    this.qtyPackageSaleTarget.value = ''
    this.qtyUnitSaleTarget.value = ''
    this.unitTotalSaleTarget.value = ''
    this.inputSearchProductTarget.value = ''
  }

  addItemTransaktionAndReset() {
    this.formAddItemTransaktionSalesTarget.requestSubmit()
    this.resetValuesInputSales()
  }

  toggleSubmitFormButton(){
    const total = Number(this.sumTotalItemTransactionsTarget.innerHTML.replace(/[\n\r]+/g, '').trim())
    if ((this.itemCodeTargets.length > 0 || this.itemDescriptionTargets.length > 0) && this.sumTotalWithReceivedTarget.value >= total){
      this.submitFormTarget.classList.remove('disabled')
    } else {
      this.submitFormTarget.classList.add('disabled')
    }
  }
}
