class SolarReportService
  def initialize(filtros = {})
    @filtros = filtros
    @data_financiera = obtener_datos_financieros_filtrados
    @data_generacion = obtener_datos_generacion_filtrados
    @data_proyeccion = obtener_datos_proyeccion_filtrados
  end

  def generar_reporte_completo
    {
      titulo: generar_titulo,
      # Datos financieros (existentes)
      data: @data_financiera,
      totales: calcular_totales_financieros(@data_financiera),
      sistemas_agrupados: agrupar_por_sistema_y_periodo(@data_financiera),
      total_registros: @data_financiera.count,

      # Nuevos datos de generación
      data_generacion: @data_generacion,
      totales_generacion: calcular_totales_generacion(@data_generacion),
      sistemas_agrupados_generacion: agrupar_generacion_por_sistema_y_periodo(@data_generacion),
      total_registros_generacion: @data_generacion.count,

      # Nuevos datos de proyección
      data_proyeccion: @data_proyeccion,
      totales_proyeccion: calcular_totales_proyeccion(@data_proyeccion),
      total_sistemas_proyeccion: @data_proyeccion.count,

      # Métricas combinadas
      performance_general: calcular_performance_general,

      comparativo_ahorros: calcular_comparativo_ahorros
    }
  end

  private

  def obtener_datos_financieros_filtrados
    query = SolarSystem.all
    aplicar_filtros_comunes(query)
  end

  def obtener_datos_generacion_filtrados
    query = SolarGeneration.all
    aplicar_filtros_comunes(query)
  end

  def obtener_datos_proyeccion_filtrados
    query = SolarTarget.all

    if @filtros[:sistemas].present?
      query = query.where(sistema: @filtros[:sistemas])
    end

    query.order(:sistema)
  end

  def aplicar_filtros_comunes(query)
    if @filtros[:sistemas].present?
      query = query.where(sistema: @filtros[:sistemas])
    end

    if @filtros[:periodos].present?
      query = query.where(periodo: @filtros[:periodos])
    end

    query.order(:sistema, :periodo, :fecha)
  end

  def calcular_totales_financieros(data)
    data.calcular_totales
  end

  def calcular_totales_generacion(data)
    data.calcular_totales
  end

  def calcular_totales_proyeccion(data)
    data.calcular_totales
  end

  def agrupar_por_sistema_y_periodo(data)
    grupos = {}

    data.find_each do |record|
      clave = "#{record.sistema}_#{record.periodo}"

      grupos[clave] ||= {
        sistema: record.sistema,
        periodo: record.periodo,
        registros: []
      }

      grupos[clave][:registros] << record
    end

    grupos.sort_by do |clave, grupo|
      [grupo[:sistema], -grupo[:periodo].to_i]
    end.to_h
  end

  def agrupar_generacion_por_sistema_y_periodo(data)
    grupos = {}

    data.find_each do |record|
      clave = "#{record.sistema}_#{record.periodo}"

      grupos[clave] ||= {
        sistema: record.sistema,
        periodo: record.periodo,
        registros: []
      }

      grupos[clave][:registros] << record
    end

    grupos.sort_by do |clave, grupo|
      [grupo[:sistema], -grupo[:periodo].to_i]
    end.to_h
  end

  def calcular_performance_general
    # Calcular métricas de performance general
    total_generacion = @data_generacion.sum(:generacion_real)
    total_esperada = @data_generacion.sum(:generacion_esperada)
    total_garantizada = @data_generacion.sum(:generacion_garantizada)

    performance_vs_esperada = total_esperada > 0 ? ((total_generacion / total_esperada) * 100).round(2) : 0
    performance_vs_garantizada = total_garantizada > 0 ? ((total_generacion / total_garantizada) * 100).round(2) : 0

    {
      performance_vs_esperada: performance_vs_esperada,
      performance_vs_garantizada: performance_vs_garantizada,
      total_generacion_real: total_generacion,
      total_generacion_esperada: total_esperada,
      total_generacion_garantizada: total_garantizada,
      diferencia_vs_esperada: total_generacion - total_esperada,
      diferencia_vs_garantizada: total_generacion - total_garantizada
    }
  end

  def calcular_comparativo_ahorros
      # Calcular total de ahorros reales (suma de ahorro_final)
      total_ahorros_reales = @data_financiera.sum(:ahorro_final)

      # Calcular total de ahorros proyectados
      total_ahorros_proyectados = @data_proyeccion.sum(:ahorros_proyectados_por_generacion)

      # Calcular porcentaje de performance
      performance_ahorros_pct = if total_ahorros_proyectados > 0
        ((total_ahorros_reales / total_ahorros_proyectados) * 100).round(2)
      else
        0
      end
      diferencia_ahorros = total_ahorros_reales - total_ahorros_proyectados

    {
      total_ahorros_reales: total_ahorros_reales.round(2),
      total_ahorros_proyectados: total_ahorros_proyectados.round(2),
      performance_ahorros_pct: performance_ahorros_pct,
      diferencia_ahorros: diferencia_ahorros.round(2),
      status: determinar_status_ahorros(performance_ahorros_pct)
    }
  end

  def determinar_status_ahorros(performance_pct)
    case performance_pct
    when 0..89
      "por_debajo"
    when 90..109
      "en_target"
    when 110..Float::INFINITY
      "por_encima"
    else
      "sin_datos"
    end
  end

  def generar_titulo
    titulo_partes = ["Reporte Solara Completo"]

    if @filtros[:sistemas].present?
      case @filtros[:sistemas].length
      when 1
        titulo_partes << @filtros[:sistemas].first
      when 2..3
        titulo_partes << @filtros[:sistemas].join(", ")
      else
        titulo_partes << "#{@filtros[:sistemas].length} Sistemas"
      end
    end

    if @filtros[:periodos].present?
      case @filtros[:periodos].length
      when 1
        titulo_partes << @filtros[:periodos].first
      when 2..3
        titulo_partes << @filtros[:periodos].join(", ")
      else
        titulo_partes << "#{@filtros[:periodos].length} Períodos"
      end
    end

    titulo_partes.join(" - ")
  end
end
