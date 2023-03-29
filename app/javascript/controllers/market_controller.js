import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="market"
export default class extends Controller {
  static targets = [
    "formSearch", "productDescription", "totalStock", "searchResults",
    "subtotal", "subtotalProduct", "qtyPerPackage", "itemId", "inputSearchProduct",
    "priceUnit", "moneyReturnedMarketRates", "sumTotalItemTransactions", "totalSales",
    "descriptionItemFormCreateProduct", "descriptionProductForm", "pricePackage",
    "qtyUnitSale", "qtyPackageSale", "unitTotalSale", "formSearchCustomer",
    "inputSearchProduct", "searchResultsCustomerSales", "customerIdSales", "nitCustomerSales",
    "socialReasonCustomerSales", "inputSearchCustomer", "marketRatesId", "formSearchMarketRates",
    "inputSearchMarketRates", "totalMarketRates", "descriptionConfirmMarketRates",
    "formUpdateConfirmMarketRates", "emailCustomerSales", "posSessionId",
    "formAddItemTransaktionMarketRates", "typeOfCurrency", "totalMarketRatesSee",
    "subtotalSee", "moneyReturnedMarketRatesSee", "unitPackage"
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
          filter: this.inputSearchCustomerTarget.value,
          unique: "true"
        })
      })
        .then(response => response.json())
        .then(data => {
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
    this.customerIdSalesTarget.value = customer.id
    this.nitCustomerSalesTarget.value = customer.nit

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
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchTarget.requestSubmit()
    }, 300)
  }

  searchMarketRates() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchMarketRatesTarget.requestSubmit()
    }, 300)
  }

  selectMarketRates(e) {
    const marketRate = JSON.parse(e.target.attributes.value.value)
    const customer = marketRate.customer
    const transaktion = marketRate.transaktion
    const actionFormMarketRates = this.formUpdateConfirmMarketRatesTarget.action.split('/')
    actionFormMarketRates[6] = transaktion.id
    this.totalMarketRatesTarget.value = transaktion.total
    this.totalMarketRatesSeeTarget.innerHTML = `${transaktion.total} ${marketRate.pos_session.type_of_currency}`
    this.marketRatesIdTarget.value = transaktion.id
    this.descriptionConfirmMarketRatesTarget.value = transaktion.description
    this.formUpdateConfirmMarketRatesTarget.action = actionFormMarketRates.join('/')

    if (customer && !customer.company_name && !customer.social_reason) {
      this.inputSearchMarketRatesTarget.value = `${customer.name} ${transaktion.id}`
    } else {
      this.inputSearchMarketRatesTarget.value = `${customer.company_name ? customer.company_name : ''} ${customer.social_reason} ${transaktion.id}`
    }
  }

  selectProduct(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)

    this.searchResultsTarget.innerHTML = ''
    this.inputSearchProductTarget.value = valueSelect.product.description
    this.unitPackageTarget.innerHTML = valueSelect.product.total_unit

    if (valueSelect.available == "true") {
      this.itemIdTarget.value = valueSelect.item.id
    }

    this.qtyPerPackageTarget.value = valueSelect.product.total_unit
    this.productDescriptionTarget.innerHTML = valueSelect.product.description
    this.priceUnitTarget.innerHTML = valueSelect.item.sale_price_unit
    this.pricePackageTarget.innerHTML = valueSelect.item.sale_price_package
    this.totalStockTarget.innerHTML = valueSelect.item.total_stock
    this.subtotalProductTarget.value = valueSelect.item.sale_price_unit
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

  resetValuesInputSales() {
    this.qtyPerPackageTarget.value = ''
    this.productDescriptionTarget.innerHTML = ''
    this.priceUnitTarget.innerHTML = ''
    this.pricePackageTarget.innerHTML = ''
    this.totalStockTarget.innerHTML = ''
    this.subtotalProductTarget.value = ''
    this.subtotalTarget.value = ''
    this.subtotalSeeTarget.innerHTML = '0'
    this.unitPackageTarget.innerHTML = ''
    this.qtyPackageSaleTarget.value = ''
    this.qtyUnitSaleTarget.value = ''
    this.unitTotalSaleTarget.value = ''
    this.inputSearchProductTarget.value = ''
  }

  addItemTransaktionAndReset() {
    this.formAddItemTransaktionMarketRatesTarget.requestSubmit()
    this.resetValuesInputSales()
  }

  setTotalSum() {
    this.totalSalesTarget.value = this.sumTotalItemTransactionsTarget.innerHTML.replace(/[\n\r]+/g, '').trim()
  }

  sumTotalConfirmMarketRates(e) {
    this.moneyReturnedMarketRatesTarget.value = (Number(e.target.value) - Number(this.totalMarketRatesTarget.value)).toFixed(2)
    this.moneyReturnedMarketRatesSeeTarget.innerHTML = this.moneyReturnedMarketRatesTarget.value
  }

  setDescriptionToItemForm(e) {
    this.descriptionItemFormCreateProductTarget.value = `${this.descriptionProductFormTarget.value} ${e.target.value}`
  }
}
