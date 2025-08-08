class DashboardController < ApplicationController
  before_action :sincronizar_datos, only: [:index]

  def index
    @sistemas_disponibles = SolarSystem.sistemas_unicos
    @periodos_disponibles = SolarSystem.periodos_unicos
    @total_registros = SolarSystem.count
    @ultimo_registro = SolarSystem.order(:updated_at).last&.updated_at
  end

  def api_data
    filtros = params.permit(:sistemas, :periodos)

    # Convertir strings separados por comas a arrays
    filtros_procesados = {}

    if filtros[:sistemas].present?
      filtros_procesados[:sistemas] = filtros[:sistemas].split(',').map(&:strip)
    end

    if filtros[:periodos].present?
      filtros_procesados[:periodos] = filtros[:periodos].split(',').map(&:strip)
    end

    service = SolarReportService.new(filtros_procesados)
    reporte = service.generar_reporte_completo

    Rails.logger.debug "=== DEBUG api_data ==="
    Rails.logger.debug "Clase de data_generacion: #{reporte[:data_generacion].first&.class}"

    render json: {
    # Datos financieros existentes
      data: serialize_data_financiera(reporte[:data]),
      totales: reporte[:totales],
      sistemas_agrupados: serialize_sistemas_agrupados_financiera(reporte[:sistemas_agrupados]),
      total_registros: reporte[:total_registros],
      comparativo_ahorros: reporte[:comparativo_ahorros],

    # Nuevos datos de generación
      data_generacion: serialize_generacion_data(reporte[:data_generacion]),
      totales_generacion: reporte[:totales_generacion],
      sistemas_agrupados_generacion: serialize_sistemas_agrupados_generacion(reporte[:sistemas_agrupados_generacion]),
      total_registros_generacion: reporte[:total_registros_generacion],

    # Nuevos datos de proyección
      data_proyeccion: serialize_proyeccion_data(reporte[:data_proyeccion]),
      totales_proyeccion: reporte[:totales_proyeccion],
      total_sistemas_proyeccion: reporte[:total_sistemas_proyeccion],

    # Performance general
      performance_general: reporte[:performance_general],
      comparativo_ahorros: reporte[:comparativo_ahorros],

      updated_at: Time.current,
      titulo: reporte[:titulo]
    }
  end

  def generar_pdf
    filtros = params.permit(:sistemas, :periodos)

    # Convertir strings separados por comas a arrays
    filtros_procesados = {}

    if filtros[:sistemas].present?
      filtros_procesados[:sistemas] = filtros[:sistemas].split(',').map(&:strip)
    end

    if filtros[:periodos].present?
      filtros_procesados[:periodos] = filtros[:periodos].split(',').map(&:strip)
    end

    service = SolarReportService.new(filtros_procesados)
    reporte = service.generar_reporte_completo

    pdf_service = SolarPdfService.new(reporte)
    pdf_data = pdf_service.generar_pdf

    send_data pdf_data,
            filename: "reporte-solara-#{Date.current}.pdf",
            type: 'application/pdf',
            disposition: 'attachment'
  end

  private



  def sincronizar_datos
    begin
    # Sincronizar datos financieros
      GoogleSheetsSyncService.new.sincronizar_datos

    # Sincronizar datos de generación
      SolarGenerationSyncService.new.sincronizar_datos

    # Sincronizar datos de proyección
      SolarTargetSyncService.new.sincronizar_datos

    rescue => e
      Rails.logger.error "Error sincronizando datos: #{e.message}"
      flash.now[:warning] = "No se pudieron sincronizar los datos más recientes"
    end
  end

  def serialize_generacion_data(data)

    Rails.logger.debug "=== DEBUG serialize_generacion_data ==="
    Rails.logger.debug "Clase del primer registro: #{data.first&.class}"
    Rails.logger.debug "Métodos disponibles: #{data.first&.methods&.grep(/generacion/)}"



    data.map do |record|
      {
        id: record.id,
        sistema: record.sistema,
        fecha: record.fecha,
        periodo: record.periodo,
        generacion_esperada: record.generacion_esperada,
        generacion_garantizada: record.generacion_garantizada,
        generacion_real: record.generacion_real,
        comparativo_real_vs_garantizada: record.comparativo_real_vs_garantizada,
        comparativo_real_vs_esperada: record.comparativo_real_vs_esperada,
        performance_vs_garantizada_pct: record.performance_vs_garantizada_pct,
        performance_vs_esperada_pct: record.performance_vs_esperada_pct
      }
    end
  end

  def serialize_proyeccion_data(data)
    data.map do |record|
      {
      id: record.id,
      sistema: record.sistema,
      kwh_proyectados_por_generacion_anual: record.kwh_proyectados_por_generacion_anual,
      ahorros_proyectados_por_generacion: record.ahorros_proyectados_por_generacion,
      mes_de_inicio: record.mes_de_inicio  # O el campo correcto según dónde esté
    }
    end
  end

  def serialize_sistemas_agrupados_generacion(sistemas_agrupados)
    Rails.logger.debug "=== DEBUG serialize_sistemas_agrupados_generacion ==="
    Rails.logger.debug "Sistemas agrupados keys: #{sistemas_agrupados.keys}"

    sistemas_agrupados.transform_values do |grupo|
       Rails.logger.debug "Clase de registros en grupo: #{grupo[:registros].first&.class}"
    {
      sistema: grupo[:sistema],
      periodo: grupo[:periodo],
      registros: serialize_generacion_data(grupo[:registros])
    }
    end
  end

  def serialize_data_financiera(data)
    data.map do |record|
      {
        id: record.id,
        sistema: record.sistema,
        fecha: record.fecha,
        periodo: record.periodo,
        cfe_sin_solar: record.cfe_sin_solar,
        cfe_sin_solar_total: record.cfe_sin_solar_total,
        cfe_con_solar: record.cfe_con_solar,
        cfe_con_solar_total: record.cfe_con_solar_total,
        ahorro_antes_pago: record.ahorro_antes_pago,
        ahorro_antes_pago_total: record.ahorro_antes_pago_total,
        mensualidad_solara: record.mensualidad_solara,
        mensualidad_solara_total: record.mensualidad_solara_total,
        ahorro_final: record.ahorro_final,
        ahorro_final_total: record.ahorro_final_total
      }
    end
  end

  def serialize_sistemas_agrupados_financiera(sistemas_agrupados)
    sistemas_agrupados.transform_values do |grupo|
      {
        sistema: grupo[:sistema],
        periodo: grupo[:periodo],
        registros: serialize_data_financiera(grupo[:registros])
      }
    end
  end

end
