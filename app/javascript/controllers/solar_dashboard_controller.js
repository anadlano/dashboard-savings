import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = [
  "sistemasFilter",
  "periodosFilter",
  "activeFilters",
  "sistemasBadge",
  "periodosBadge",
  "summaryGrid",
  "systemsGrid",
  "detailsTable",
  "detailsBody",
  "loadingOverlay",
  "errorMessage",
  // Nuevos targets
  "generationGrid",
  "targetsGrid",
  "performanceGrid",
  "comparativoAhorrosGrid"
  ]

  static values = {
    apiUrl: String,
    refreshInterval: { type: Number, default: 60000 }
  }

  connect() {
    console.log("Solar Dashboard conectado")
    this.loadData()
    this.startAutoRefresh()
    this.updateActiveFiltersDisplay()
  }

  disconnect() {
    this.stopAutoRefresh()
  }

  async loadData() {
    this.showLoading()
    this.hideError()

    try {
      const params = new URLSearchParams(this.buildFilters())
      const response = await fetch(`${this.apiUrlValue}?${params}`)

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const result = await response.json()
      console.log("Datos recibidos:", result)

      // Renderizar datos financieros (existentes)
      this.renderSummary(result.totales, result.total_registros)
      this.renderSystems(result.sistemas_agrupados)
      this.renderDetails(result.data)

      // Renderizar nuevos datos de generación
      this.renderGeneration(result.totales_generacion, result.total_registros_generacion)
      this.renderTargets(result.data_proyeccion, result.totales_proyeccion)
      this.renderPerformance(result.performance_general)
      this.renderComparativoAhorros(result.comparativo_ahorros)

      this.updateActiveFiltersDisplay()
      this.hideLoading()

    } catch (error) {
      console.error('Error cargando datos:', error)
      this.showError(`Error al cargar los datos: ${error.message}`)
      this.hideLoading()
    }
  }

  buildFilters() {
    const filters = {}

    // Obtener sistemas seleccionados
    const sistemasSeleccionados = Array.from(this.sistemasFilterTarget.selectedOptions)
                                       .map(option => option.value)
    if (sistemasSeleccionados.length > 0) {
      filters.sistemas = sistemasSeleccionados.join(',')
    }

    // Obtener períodos seleccionados
    const periodosSeleccionados = Array.from(this.periodosFilterTarget.selectedOptions)
                                       .map(option => option.value)
    if (periodosSeleccionados.length > 0) {
      filters.periodos = periodosSeleccionados.join(',')
    }

    return filters
  }

  aplicarFiltros() {
    console.log("Aplicando filtros:", this.buildFilters())
    this.loadData()
  }

  limpiarFiltros() {
    // Deseleccionar todas las opciones
    Array.from(this.sistemasFilterTarget.options).forEach(option => option.selected = false)
    Array.from(this.periodosFilterTarget.options).forEach(option => option.selected = false)
    this.loadData()
  }

  // Filtros rápidos
  seleccionarTodosSistemas() {
    Array.from(this.sistemasFilterTarget.options).forEach(option => option.selected = true)
    this.aplicarFiltros()
  }

  seleccionarTodosPeriodos() {
    Array.from(this.periodosFilterTarget.options).forEach(option => option.selected = true)
    this.aplicarFiltros()
  }

  seleccionarECLA() {
    Array.from(this.sistemasFilterTarget.options).forEach(option => {
      option.selected = option.value.includes('ECLA')
    })
    this.aplicarFiltros()
  }

  seleccionarUltimosPeriodos() {
    // Seleccionar los 3 períodos más recientes
    const opciones = Array.from(this.periodosFilterTarget.options)
    opciones.forEach((option, index) => {
      option.selected = index < 3
    })
    this.aplicarFiltros()
  }

  updateActiveFiltersDisplay() {
    const sistemasSeleccionados = Array.from(this.sistemasFilterTarget.selectedOptions)
    const periodosSeleccionados = Array.from(this.periodosFilterTarget.selectedOptions)

    if (sistemasSeleccionados.length > 0 || periodosSeleccionados.length > 0) {
      this.activeFiltersTarget.style.display = 'block'

      // Actualizar badge de sistemas
      if (sistemasSeleccionados.length > 0) {
        this.sistemasBadgeTarget.textContent = `${sistemasSeleccionados.length} sistema(s) seleccionado(s)`
        this.sistemasBadgeTarget.style.display = 'inline-block'
      } else {
        this.sistemasBadgeTarget.style.display = 'none'
      }

      // Actualizar badge de períodos
      if (periodosSeleccionados.length > 0) {
        this.periodosBadgeTarget.textContent = `${periodosSeleccionados.length} período(s) seleccionado(s)`
        this.periodosBadgeTarget.style.display = 'inline-block'
      } else {
        this.periodosBadgeTarget.style.display = 'none'
      }
    } else {
      this.activeFiltersTarget.style.display = 'none'
    }
  }

  async exportarPDF() {
    try {
      const params = new URLSearchParams(this.buildFilters())
      const url = `/dashboard/pdf?${params}`
      window.open(url, '_blank')
    } catch (error) {
      console.error('Error exportando PDF:', error)
      alert('Error al generar PDF: ' + error.message)
    }
  }

  refresh() {
    console.log("Actualizando datos manualmente")
    this.loadData()
  }

  // Resto de métodos iguales (renderSummary, renderSystems, etc.)
  renderSummary(totales, totalRegistros) {
    const html = `
      <div class="summary-card">
        <h3>Total Registros</h3>
        <div class="amount neutral">${totalRegistros}</div>
      </div>
      <div class="summary-card">
        <h3>CFE Sin Solar</h3>
        <div class="amount neutral">$${this.formatCurrency(totales.cfe_sin_solar)}</div>
        <small>Total: $${this.formatCurrency(totales.cfe_sin_solar_total)}</small>
      </div>
      <div class="summary-card">
        <h3>CFE Con Solar</h3>
        <div class="amount neutral">$${this.formatCurrency(totales.cfe_con_solar)}</div>
        <small>Total: $${this.formatCurrency(totales.cfe_con_solar_total)}</small>
      </div>
      <div class="summary-card">
        <h3>Ahorro Antes Pago</h3>
        <div class="amount positive">$${this.formatCurrency(totales.ahorro_antes_pago)}</div>
        <small>Total: $${this.formatCurrency(totales.ahorro_antes_pago_total)}</small>
      </div>
      <div class="summary-card">
        <h3>Mensualidad Solara</h3>
        <div class="amount warning">$${this.formatCurrency(totales.mensualidad_solara)}</div>
        <small>Total: $${this.formatCurrency(totales.mensualidad_solara_total)}</small>
      </div>
      <div class="summary-card highlight">
        <h3>Ahorro Final</h3>
        <div class="amount ${totales.ahorro_final >= 0 ? 'positive' : 'negative'}">$${this.formatCurrency(totales.ahorro_final)}</div>
        <small>Total: $${this.formatCurrency(totales.ahorro_final_total)}</small>
      </div>
    `
    this.summaryGridTarget.innerHTML = html
  }

  renderSystems(sistemasAgrupados) {
    const html = Object.entries(sistemasAgrupados).map(([clave, grupo]) => {
      const totalesGrupo = this.calcularTotalesGrupo(grupo.registros)

      return `
        <div class="system-card">
          <div class="system-header">
            <h3>${grupo.sistema}</h3>
            <p>Período: ${grupo.periodo}</p>
            <small>${grupo.registros.length} registro(s)</small>
          </div>
          <div class="system-metrics">
            <div class="metric">
              <span class="label">CFE Sin Solar:</span>
              <span class="value">$${this.formatCurrency(totalesGrupo.cfe_sin_solar)}</span>
            </div>
            <div class="metric">
              <span class="label">CFE Con Solar:</span>
              <span class="value">$${this.formatCurrency(totalesGrupo.cfe_con_solar)}</span>
            </div>
            <div class="metric">
              <span class="label">Ahorro Antes Pago:</span>
              <span class="value positive">$${this.formatCurrency(totalesGrupo.ahorro_antes_pago)}</span>
            </div>
            <div class="metric">
              <span class="label">Mensualidad Solara:</span>
              <span class="value warning">$${this.formatCurrency(totalesGrupo.mensualidad_solara)}</span>
            </div>
            <div class="metric highlight">
              <span class="label">Ahorro Final:</span>
              <span class="value ${totalesGrupo.ahorro_final >= 0 ? 'positive' : 'negative'}">$${this.formatCurrency(totalesGrupo.ahorro_final)}</span>
            </div>
          </div>
        </div>
      `
    }).join('')

    this.systemsGridTarget.innerHTML = html
  }

  renderDetails(data) {
    const html = data.map(record => `
      <tr>
        <td>${record.sistema}</td>
        <td>${this.formatDate(record.fecha)}</td>
        <td>${record.periodo}</td>
        <td>$${this.formatCurrency(record.cfe_sin_solar_total)}</td>
        <td>$${this.formatCurrency(record.cfe_con_solar_total)}</td>
        <td class="positive">$${this.formatCurrency(record.ahorro_antes_pago_total)}</td>
        <td class="warning">$${this.formatCurrency(record.mensualidad_solara_total)}</td>
        <td class="${record.ahorro_final >= 0 ? 'positive' : 'negative'}">$${this.formatCurrency(record.ahorro_final_total)}</td>
      </tr>
    `).join('')

    this.detailsBodyTarget.innerHTML = html
  }

  calcularTotalesGrupo(registros) {
    return registros.reduce((acc, record) => ({
      cfe_sin_solar: acc.cfe_sin_solar + parseFloat(record.cfe_sin_solar || 0),
      cfe_con_solar: acc.cfe_con_solar + parseFloat(record.cfe_con_solar || 0),
      ahorro_antes_pago: acc.ahorro_antes_pago + parseFloat(record.ahorro_antes_pago || 0),
      mensualidad_solara: acc.mensualidad_solara + parseFloat(record.mensualidad_solara || 0),
      ahorro_final: acc.ahorro_final + parseFloat(record.ahorro_final || 0)
    }), {
      cfe_sin_solar: 0,
      cfe_con_solar: 0,
      ahorro_antes_pago: 0,
      mensualidad_solara: 0,
      ahorro_final: 0
    })
  }

  formatCurrency(amount) {
    return new Intl.NumberFormat('es-MX', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(amount || 0)
  }

  formatDate(dateString) {
    if (!dateString) return ''
    return new Date(dateString).toLocaleDateString('es-MX')
  }

  showLoading() {
    this.loadingOverlayTarget.style.display = 'flex'
  }

  hideLoading() {
    this.loadingOverlayTarget.style.display = 'none'
  }

  showError(message) {
    this.errorMessageTarget.querySelector('p').textContent = message
    this.errorMessageTarget.style.display = 'block'
  }

  hideError() {
    this.errorMessageTarget.style.display = 'none'
  }

  startAutoRefresh() {
    this.refreshTimer = setInterval(() => {
      console.log("Auto-actualizando datos...")
      this.loadData()
    }, this.refreshIntervalValue)
  }

  stopAutoRefresh() {
    if (this.refreshTimer) {
      clearInterval(this.refreshTimer)
    }
  }
  renderGeneration(totalesGeneracion, totalRegistrosGeneracion) {
  const html = `
    <div class="generation-card">
      <h3>Total Registros de Generación</h3>
      <div class="amount neutral">${totalRegistrosGeneracion}</div>
    </div>
    <div class="generation-card">
      <h3>Generación Esperada</h3>
      <div class="amount neutral">${this.formatCurrency(totalesGeneracion.generacion_esperada)} kWh</div>
    </div>
    <div class="generation-card">
      <h3>Generación Garantizada</h3>
      <div class="amount neutral">${this.formatCurrency(totalesGeneracion.generacion_garantizada)} kWh</div>
    </div>
    <div class="generation-card">
      <h3>Generación Real</h3>
      <div class="amount positive">${this.formatCurrency(totalesGeneracion.generacion_real)} kWh</div>
    </div>
    <div class="generation-card highlight">
      <h3>Diferencia vs Garantizada</h3>
      <div class="amount ${totalesGeneracion.comparativo_real_vs_garantizada >= 0 ? 'positive' : 'negative'}">
        ${this.formatCurrency(totalesGeneracion.comparativo_real_vs_garantizada)} kWh
      </div>
    </div>
    <div class="generation-card highlight">
      <h3>Diferencia vs Esperada</h3>
      <div class="amount ${totalesGeneracion.comparativo_real_vs_esperada >= 0 ? 'positive' : 'negative'}">
        ${this.formatCurrency(totalesGeneracion.comparativo_real_vs_esperada)} kWh
      </div>
    </div>
  `
  this.generationGridTarget.innerHTML = html
}

renderTargets(dataProyeccion, totalesProyeccion) {
  if (!dataProyeccion || dataProyeccion.length === 0) {
    this.targetsGridTarget.innerHTML = `
      <div class="targets-card">
        <h3>Sin datos de proyección</h3>
        <div class="amount neutral">0</div>
      </div>
    `
    return
  }

  const html = `
    <div class="targets-card">
      <h3>Sistemas con Proyección</h3>
      <div class="amount neutral">${dataProyeccion.length}</div>
    </div>
    <div class="targets-card">
      <h3>kWh Proyectados Totales</h3>
      <div class="amount neutral">${this.formatCurrency(totalesProyeccion.kwh_proyectados_total)} kWh</div>
    </div>
    <div class="targets-card highlight">
      <h3>Ahorros Proyectados Totales</h3>
      <div class="amount positive">$${this.formatCurrency(totalesProyeccion.ahorros_proyectados_total)}</div>
    </div>
  `
  this.targetsGridTarget.innerHTML = html
}

renderPerformance(performanceGeneral) {
  if (!performanceGeneral) {
    this.performanceGridTarget.innerHTML = `
      <div class="performance-card">
        <h3>Sin datos de performance</h3>
        <div class="amount neutral">0%</div>
      </div>
    `
    return
  }

  const html = `
    <div class="performance-card">
      <h3>Performance vs Esperada</h3>
      <div class="amount ${performanceGeneral.performance_vs_esperada >= 100 ? 'positive' : performanceGeneral.performance_vs_esperada >= 90 ? 'warning' : 'negative'}">
        ${performanceGeneral.performance_vs_esperada}%
      </div>
      <small>Diferencia: ${this.formatCurrency(performanceGeneral.diferencia_vs_esperada)} kWh</small>
    </div>
    <div class="performance-card">
      <h3>Performance vs Garantizada</h3>
      <div class="amount ${performanceGeneral.performance_vs_garantizada >= 100 ? 'positive' : performanceGeneral.performance_vs_garantizada >= 90 ? 'warning' : 'negative'}">
        ${performanceGeneral.performance_vs_garantizada}%
      </div>
      <small>Diferencia: ${this.formatCurrency(performanceGeneral.diferencia_vs_garantizada)} kWh</small>
    </div>
    <div class="performance-card highlight">
      <h3>Generación Real Total</h3>
      <div class="amount positive">${this.formatCurrency(performanceGeneral.total_generacion_real)} kWh</div>
      <small>de ${this.formatCurrency(performanceGeneral.total_generacion_esperada)} kWh esperados</small>
    </div>


  `
  this.performanceGridTarget.innerHTML = html

}

renderComparativoAhorros(comparativoAhorros) {
  if (!comparativoAhorros) {
    this.comparativoAhorrosGridTarget.innerHTML = `
      <div class="comparativo-card">
        <h3>Sin datos de comparativo</h3>
        <div class="amount neutral">0%</div>
      </div>
    `
    return
  }

  const getStatusClass = (status) => {
    switch(status) {
      case 'por_encima': return 'positive'
      case 'en_target': return 'warning'
      case 'por_debajo': return 'negative'
      default: return 'neutral'
    }
  }

  const html = `
    <div class="comparativo-card highlight">
      <h3>Performance de Ahorros</h3>
      <div class="amount ${getStatusClass(comparativoAhorros.status)}">
        ${comparativoAhorros.performance_ahorros_pct}%
      </div>
    </div>
    <div class="comparativo-card">
      <h3>Ahorros Reales</h3>
      <div class="amount positive">$${this.formatCurrency(comparativoAhorros.total_ahorros_reales)}</div>
    </div>
    <div class="comparativo-card">
      <h3>Ahorros Proyectados</h3>
      <div class="amount neutral">$${this.formatCurrency(comparativoAhorros.total_ahorros_proyectados)}</div>
    </div>
    <div class="comparativo-card">
      <h3>Diferencia</h3>
      <div class="amount ${comparativoAhorros.diferencia_ahorros >= 0 ? 'positive' : 'negative'}">
        $${this.formatCurrency(comparativoAhorros.diferencia_ahorros)}
      </div>
    </div>
  `

  this.comparativoAhorrosGridTarget.innerHTML = html
}
}
