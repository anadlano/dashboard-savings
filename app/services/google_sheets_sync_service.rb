class GoogleSheetsSyncService < GoogleSheetsService
  def sincronizar_datos
    data = get_data

    data.each do |row_data|
      # Buscar o crear registro
      record = SolarSystem.find_or_initialize_by(
        sistema: row_data['sistema'],
        fecha: parse_fecha(row_data['fecha']),
        periodo: row_data['periodo']
      )

      # Mapear y limpiar los datos con los nombres correctos
      record.assign_attributes(
        cfe_sin_solar: parse_currency(row_data['cfe_sin_solar_(sin_iva)']),
        iva_cfe_sin_solar: parse_currency(row_data['iva_cfe_sin_solar']),
        cfe_sin_solar_total: parse_currency(row_data['cfe_sin_solar_(total)']),
        cfe_con_solar: parse_currency(row_data['cfe_con_solar_(sin_iva)']),
        iva_cfe_con_solar: parse_currency(row_data['iva_cfe_con_solar']),
        cfe_con_solar_total: parse_currency(row_data['cfe_con_solar_(total)_+_dap']),
        ahorro_antes_pago: parse_currency(row_data['ahorro_antes_pago_(sin_iva)']),
        iva_ahorro: parse_currency(row_data['iva_ahorro']),
        ahorro_antes_pago_total: parse_currency(row_data['ahorro_antes_pago_(total)']),
        mensualidad_solara: parse_currency(row_data['mensualidad_solara_(sin_iva)']),
        iva_mensualidad: parse_currency(row_data['iva_mensualidad']),
        mensualidad_solara_total: parse_currency(row_data['mensualidad_solara_(total)']),
        ahorro_final: parse_currency(row_data['ahorro_final_(sin_iva)']),
        iva_ahorro_final: parse_currency(row_data['iva_ahorro_final']),
        ahorro_final_total: parse_currency(row_data['ahorro_final_(total)'])
      )

      record.save! if record.changed?
    end

    Rails.logger.info "Sincronizados #{data.length} registros desde Google Sheets"
    data.length
  rescue => e
    Rails.logger.error "Error sincronizando datos: #{e.message}"
    0
  end

  private

  def parse_fecha(fecha_string)
    return nil if fecha_string.blank?

    # El formato parece ser "28/7/2025" (día/mes/año)
    begin
      Date.strptime(fecha_string.to_s, "%d/%m/%Y")
    rescue ArgumentError
      # Intentar otros formatos
      ["%Y-%m-%d", "%m/%d/%Y"].each do |format|
        begin
          return Date.strptime(fecha_string.to_s, format)
        rescue ArgumentError
          next
        end
      end
      Date.current # Fallback
    end
  end

  def parse_currency(currency_string)
    return 0.0 if currency_string.blank?

    # Limpiar el string: quitar $, comas, espacios
    cleaned = currency_string.to_s
                            .gsub('$', '')
                            .gsub(',', '')
                            .gsub(' ', '')
                            .strip

    # Convertir a float
    cleaned.to_f
  end
end
