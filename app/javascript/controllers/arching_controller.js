import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "value200", "doscientos", "value100", "cien", "value50", "cincuenta",
    "value20", "veinte", "value10", "diez", "value5", "cinco", "value2", "dos",
    "value1", "uno", "value050", "cerocincuenta", "value020", "ceroveinte",
    "value010", "cerodiez", "totalInput", "totalShowed", "remaining", "missing",
    "registeredtotal", "archingForcedValue", "formConfirmArchingValidating",
    "formSearchPosSessions", "inputSearchPosSessions", "formSearchPosSessionsFilter",
    "urlShowPosSession", "totalArchingMoney"
  ]

  searchPosSessions() {
    if (this.inputSearchPosSessionsTarget.value === '') location.href = location.href

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formSearchPosSessionsTarget.requestSubmit()
    }, 300)
  }

  sendRequestPosSessionFilter(e) {
    e.preventDefault()
    this.formSearchPosSessionsFilterTarget.requestSubmit()
  }

  redirectShowPosSession(e) {
    location.href = e.target.id
  }

  onchange(e) {
    if (e.target.value < 1) {
      e.target.value = ''
    }

    const twoHundredResult = Number(200 * this.value200Target.value)
    const oneHundredResult = Number(100 * this.value100Target.value)
    const fivetyResult     = Number(50 * this.value50Target.value)
    const twentyResult     = Number(20 * this.value20Target.value)
    const tenResult        = Number(10 * this.value10Target.value)
    const fiveResult       = Number(5 * this.value5Target.value)
    const twoResult        = Number(2 * this.value2Target.value)
    const oneResult        = Number(1 * this.value1Target.value)
    const fivetyCentsResult = Number(0.50 * this.value050Target.value)
    const twentyCentsResult = Number(0.20 * this.value020Target.value)
    const tenCentsResult    = Number(0.10 * this.value010Target.value)

    this.doscientosTarget.innerHTML = `Bs ${twoHundredResult}`
    this.cienTarget.innerHTML = `Bs ${oneHundredResult}`
    this.cincuentaTarget.innerHTML = `Bs ${fivetyResult}`
    this.veinteTarget.innerHTML = `Bs ${twentyResult}`
    this.diezTarget.innerHTML = `Bs ${tenResult}`
    this.cincoTarget.innerHTML = `Bs ${fiveResult}`
    this.dosTarget.innerHTML = `Bs ${twoResult}`
    this.unoTarget.innerHTML = `Bs ${oneResult}`
    this.cerocincuentaTarget.innerHTML = `Bs ${fivetyCentsResult.toFixed(2) }`
    this.ceroveinteTarget.innerHTML = `Bs ${twentyCentsResult.toFixed(2) }`
    this.cerodiezTarget.innerHTML = `Bs ${tenCentsResult.toFixed(2) }`

    const totalResult = Number(
      twoHundredResult +
      oneHundredResult +
      fivetyResult +
      twentyResult +
      tenResult +
      fiveResult +
      twoResult +
      oneResult +
      fivetyCentsResult +
      twentyCentsResult +
      tenCentsResult
    ).toFixed(2)

    const totalMoneyCash = {
      two_hundred: {
        title: "Billetes de 200bs",
        cash_qty: this.value200Target.value,
        total: `${twoHundredResult} BS.`
      },
      one_hundred: {
        title: "Billetes de 100bs",
        cash_qty: this.value100Target.value,
        total: `${oneHundredResult} BS.`
      },
      fivety: {
        title: "Billetes de 50bs",
        cash_qty: this.value50Target.value,
        total: `${fivetyResult} BS.`
      },
      twenty: {
        title: "Billetes de 20bs",
        cash_qty: this.value20Target.value,
        total: `${twentyResult} BS.`
      },
      ten: {
        title: "Billetes de 10bs",
        cash_qty: this.value10Target.value,
        total: `${tenResult} BS.`
      },
      five: {
        title: "Monedas de 5bs",
        cash_qty: this.value5Target.value,
        total: `${fiveResult} BS.`
      },
      two: {
        title: "Monedas de 2bs",
        cash_qty: this.value2Target.value,
        total: `${twoResult} BS.`
      },
      one: {
        title: "Monedas de 1bs",
        cash_qty: this.value1Target.value,
        total: `${oneResult} BS.`
      },
      fivety_cents: {
        title: "Monedas de 0.50ctvs",
        cash_qty: this.value050Target.value,
        total: `${fivetyCentsResult} BS.`
      },
      twenty_cents: {
        title: "Monedas de 0.20ctvs",
        cash_qty: this.value020Target.value,
        total: `${twentyCentsResult} BS.`
      },
      ten_cents: {
        title: "Monedas de 0.10ctvs",
        cash_qty: this.value010Target.value,
        total: `${tenCentsResult} BS.`
      }
    }

    this.totalInputTarget.value = totalResult
    this.totalShowedTarget.innerHTML = `Bs ${totalResult}`
    this.totalArchingMoneyTarget.value = JSON.stringify(totalMoneyCash)
  }

  setForceClosedSession() {
    this.archingForcedValueTarget.value = 'true'
    this.formConfirmArchingValidatingTarget.requestSubmit()
  }

  toggleShowArchingDetails(e) {
    const divs = document.getElementsByClassName("info-arching-close-selector")
    for (let i = 0; i < divs.length; i++) {
      divs[i].classList.toggle("d-none")
      if (!divs[i].classList.contains("d-none")) {
        e.target.innerHTML = 'Mostrar Menos'
      } else {
        e.target.innerHTML = 'Detalles del Arqueo'
      }
    }
  }
}
