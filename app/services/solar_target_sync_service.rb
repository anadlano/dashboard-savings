class SolarTargetSyncService < GoogleSheetsService
  def sincronizar_datos
    data = get_target_data

    data.each do |row_data|
      record = SolarTarget.find_or_initialize_by(
        sistema: row_data['sistema']
      )

      record.assign_attributes(
        kwh_proyectados_por_generacion_anual: parse_currency(row_data['kwh_proyectados_por_generacion_anual']),
        ahorros_proyectados_por_generacion: parse_currency(row_data['ahorros_proyectados_por_generación']),
        mes_de_inicio: row_data['mes_de_inicio']
      )

      record.save! if record.changed?
    end

    Rails.logger.info "Sincronizados #{data.length} registros de proyección desde Google Sheets"
    data.length
  rescue => e
    Rails.logger.error "Error sincronizando datos de proyección: #{e.message}"
    0
  end

  private

  def parse_currency(currency_string)
    return 0.0 if currency_string.blank?

    cleaned = currency_string.to_s
                            .gsub('$', '')
                            .gsub(',', '')
                            .gsub(' ', '')
                            .strip

    cleaned.to_f
  end
end
