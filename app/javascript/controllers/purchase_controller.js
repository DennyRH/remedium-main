import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "formSearch", "productDescription", "minStock", "maxStock", "totalStock",
    "searchResults", "subtotal", "subtotalProduct", "productId", "itemId",
    "inputSearchProduct", "costUnit", "moneyReceivedPurchase", "providerId",
    "sumTotalItemTransactions", "totalPurchase", "socialReasonPurchaseProvider",
    "inputSearchProvider", "descriptionItemFormCreateProduct", "qtyUnitPurchase",
    "descriptionProductForm", "emailPurchaseProvider", "posSessionIdPurchase",
    "formSearchProvider", "qtyPerPackage", "costPackage", "qtyPackagePurchase",
    "unitTotalPurchase", "checkboxPurchases", "checkboxPurchasesCredit",
    "typeTransaktionPurchase", "dateOfPaymentPurchase", "moneyPaidPurchases",
    "statusPurchase", "formPurchaseItemTransaktionAdd", "subtotalSee",
    "moneyReceivedPurchaseSee", "customerReceivedCi", "customerReceivedName",
    "customerReceivedMoneyId", "unitPackage", "providerName"
  ]

  searchProvider() {
    if (this.inputSearchProviderTarget.value === '') {
      this.providerIdTarget.value = ''
      this.socialReasonPurchaseProviderTarget.value = ''
      this.emailPurchaseProviderTarget.value = ''
      this.providerNameTarget.value = ''
    }

    if (this.inputSearchProviderTarget.value.length < 5) return
      
    const url = '/providers/search'
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      fetch(url, {
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
              this.providerIdTarget.value = ''
              this.emailPurchaseProviderTarget.value = ''
              this.socialReasonPurchaseProviderTarget.value = ''
              this.providerNameTarget.value = ''
            } else {
              this.providerIdTarget.value = data.id
              this.socialReasonPurchaseProviderTarget.value = data.name
              this.inputSearchProviderTarget.value = data.document_number
              this.emailPurchaseProviderTarget.value = data.email
              this.providerNameTarget.innerHTML = data.name
            }
          })
    }, 400)
  }

  searchCollector() {
    if (this.customerReceivedCiTarget.value === '') {
      this.customerReceivedMoneyIdTarget.value = ''
      this.customerReceivedCiTarget.value = ''
      this.customerReceivedNameTarget.value = ''
    }
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      if(this.customerReceivedCiTarget.value.length < 6) return
      
      const url = `/pos_sessions/${this.posSessionIdPurchaseTarget.value}/transaktions/search_provider?search_provider=${this.customerReceivedCiTarget.value}&purchase_customer_collector=true`
      fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
        }
      })
        .then(response => response.json())
        .then(data => {
          if (data) {
            this.customerReceivedMoneyIdTarget.value = data.id
            this.customerReceivedCiTarget.value = data.document_number
            this.customerReceivedNameTarget.value = data.name
          } else {
            this.customerReceivedMoneyIdTarget.value = ''
            this.customerReceivedNameTarget.value = ''
          }
        })
    }, 400)
  }

  selectProvider(e) {
    const provider = JSON.parse(e.target.attributes.value.value).provider
    this.searchResultsTarget.innerHTML = ''
    this.providerIdTarget.value = provider.id

    if (provider && !provider.company_name && !provider.social_reason) {
      this.inputSearchProviderTarget.value = provider.nit
    } else {
      this.inputSearchProviderTarget.value = `${provider.company_name} ${provider.social_reason} ${provider.nit}`
    }
  }

  searchProduct() {
    if (this.inputSearchProductTarget.value == '') this.resetValuesInputPurchases()

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchTarget.requestSubmit()
    }, 300)
  }

  selectProduct(e) {
    const valueSelect = JSON.parse(e.target.attributes.value.value)
    this.searchResultsTarget.innerHTML = ''
    this.inputSearchProductTarget.value = valueSelect.product.description
    this.qtyPerPackageTarget.value = valueSelect.product.total_unit
    this.unitPackageTarget.innerHTML = valueSelect.product.total_unit

    if (valueSelect.item) {
      this.productDescriptionTarget.innerHTML = valueSelect.product.description
      this.costUnitTarget.innerHTML = valueSelect.item.purchase_cost_unit
      this.costPackageTarget.innerHTML = valueSelect.item.purchase_cost_package
      this.minStockTarget.innerHTML = valueSelect.item.min_stock
      this.maxStockTarget.innerHTML = valueSelect.item.max_stock
      this.totalStockTarget.innerHTML = valueSelect.item.total_stock
      this.subtotalProductTarget.value = valueSelect.item.purchase_cost_unit
      this.itemIdTarget.value = valueSelect.item.id
    }
    if (valueSelect.provider) {
      this.socialReasonPurchaseProviderTarget.value = valueSelect.provider.social_reason
      this.providerIdTarget.value = valueSelect.provider.id
      this.inputSearchProviderTarget.value = valueSelect.provider.nit
      this.emailPurchaseProviderTarget.value = valueSelect.provider.email
    }
  }

  sumSubtotalForUnits(e) {
    let qtyPackage = Math.trunc(e.target.value / this.qtyPerPackageTarget.value)
    let qtyUnit = e.target.value % this.qtyPerPackageTarget.value

    let costPriceUnit = (qtyUnit * Number(this.costUnitTarget.innerHTML)).toFixed(2)
    let purchasePricePackage = (qtyPackage * Number(this.costPackageTarget.innerHTML)).toFixed(2)
    this.subtotalTarget.value = (Number(costPriceUnit) + Number(purchasePricePackage)).toFixed(2)
    this.subtotalSeeTarget.innerHTML = this.subtotalTarget.value
    this.qtyPackagePurchaseTarget.value = qtyPackage
    this.qtyUnitPurchaseTarget.value = qtyUnit
  }

  sumSubtotalForPackage(e) {
    let qtyPackage = e.target.value
    let qtyUnit = (e.target.value * this.qtyPerPackageTarget.value) % this.qtyPerPackageTarget.value

    let costPriceUnit = (qtyUnit * Number(this.costUnitTarget.innerHTML)).toFixed(2)
    let purchasePricePackage = (qtyPackage * Number(this.costPackageTarget.innerHTML)).toFixed(2)
    this.subtotalTarget.value = (Number(costPriceUnit) + Number(purchasePricePackage)).toFixed(2)
    this.subtotalSeeTarget.innerHTML = this.subtotalTarget.value
    this.qtyPackagePurchaseTarget.value = qtyPackage
    this.qtyUnitPurchaseTarget.value = qtyUnit
    this.unitTotalPurchaseTarget.value = e.target.value * this.qtyPerPackageTarget.value
  }

  setMoneyReceived(e) {
    this.moneyReceivedPurchaseTarget.value = (Number(e.target.value) - Number(this.sumTotalItemTransactionsTarget.innerHTML)).toFixed(2)
    this.moneyReceivedPurchaseSeeTarget.innerHTML = this.moneyReceivedPurchaseTarget.value
    this.totalPurchaseTarget.value = this.sumTotalItemTransactionsTarget.innerHTML.replace(/[\n\r]+/g, '').trim()
  }

  setDescriptionToItemForm(e) {
    this.descriptionItemFormCreateProductTarget.value = `${this.descriptionProductFormTarget.value} ${e.target.value}`
  }

  setTypePurchasesSelected(e) {
    if (e.target.checked) {
      this.statusPurchaseTarget.value = 'active'
      this.moneyPaidPurchasesTarget.disabled = false
      this.dateOfPaymentPurchaseTarget.disabled = true
      this.moneyReceivedPurchaseTarget.disabled = false
      this.checkboxPurchasesCreditTarget.checked = false
      this.typeTransaktionPurchaseTarget.value = 'Purchases'
      document.getElementById("purchases-credit-date").classList.add("d-none")

      const divs = document.getElementsByClassName("purchases-selector-hidden-toggle")

      for (let i = 0; i < divs.length; i++) {
        divs[i].classList.remove("d-none")
      }
    }
  }

  setTypePurchasesCreditSelected(e) {
    if (e.target.checked) {
      this.typeTransaktionPurchaseTarget.value = 'Purchases Credit'
      this.statusPurchaseTarget.value = 'pending'
      this.checkboxPurchasesTarget.checked = false
      this.moneyPaidPurchasesTarget.disabled = true
      this.moneyReceivedPurchaseTarget.disabled = true
      this.dateOfPaymentPurchaseTarget.disabled = false
      this.totalPurchaseTarget.value = this.sumTotalItemTransactionsTarget.innerHTML.replace(/[\n\r]+/g, '').trim()

      document.getElementById("purchases-credit-date").classList.remove("d-none")
      const divs = document.getElementsByClassName("purchases-selector-hidden-toggle")

      for (let i = 0; i < divs.length; i++) {
        divs[i].classList.add("d-none")
      }
    }
  }

  resetValuesInputPurchases() {
    this.productDescriptionTarget.innerHTML = ''
    this.costUnitTarget.innerHTML = ''
    this.costPackageTarget.innerHTML = ''
    this.minStockTarget.innerHTML = ''
    this.maxStockTarget.innerHTML = ''
    this.totalStockTarget.innerHTML = ''
    this.subtotalProductTarget.value = ''
    this.unitPackageTarget.innerHTML = ''
    this.itemIdTarget.value = ''
    this.inputSearchProductTarget.value = ''
    this.subtotalTarget.value = ''
    this.subtotalSeeTarget.innerHTML = '0'
    this.qtyPackagePurchaseTarget.value = ''
    this.unitTotalPurchaseTarget.value = ''
  }

  addItemTransaktionAndReset() {
    this.formPurchaseItemTransaktionAddTarget.requestSubmit()
    this.resetValuesInputPurchases()
  }
}
