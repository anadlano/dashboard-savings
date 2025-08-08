class SolarGenerationSyncService < GoogleSheetsService
  def sincronizar_datos
    data = get_generation_data

    data.each do |row_data|
      record = SolarGeneration.find_or_initialize_by(
        sistema: row_data['sistema'],
        fecha: parse_fecha(row_data['fecha']),
        periodo: row_data['periodo']
      )

      record.assign_attributes(
        generacion_esperada: parse_currency(row_data['generación_esperada']),
        generacion_garantizada: parse_currency(row_data['generación_garantizada']),
        generacion_real: parse_currency(row_data['generación_real']),
        comparativo_real_vs_garantizada: parse_currency(row_data['comparativo_real_vs_garantizada']),
        comparativo_real_vs_esperada: parse_currency(row_data['comparativo_real_vs_esperada'])
      )

      record.save! if record.changed?
    end

    Rails.logger.info "Sincronizados #{data.length} registros de generación desde Google Sheets"
    data.length
  rescue => e
    Rails.logger.error "Error sincronizando datos de generación: #{e.message}"
    0
  end

  private

  def parse_fecha(fecha_string)
    return nil if fecha_string.blank?

    begin
      Date.strptime(fecha_string.to_s, "%d/%m/%Y")
    rescue ArgumentError
      ["%Y-%m-%d", "%m/%d/%Y"].each do |format|
        begin
          return Date.strptime(fecha_string.to_s, format)
        rescue ArgumentError
          next
        end
      end
      Date.current
    end
  end

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
