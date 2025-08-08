require 'google/apis/sheets_v4'
require 'googleauth'

class GoogleSheetsService
  def initialize
    @service = Google::Apis::SheetsV4::SheetsService.new
    @service.authorization = authorize
    @sheet_id = ENV['GOOGLE_SHEET_ID']
  end

  def get_data(range = 'A:Z')
    response = @service.get_spreadsheet_values(@sheet_id, range)
    process_data(response.values)
  rescue => e
    Rails.logger.error "Error fetching Google Sheets data: #{e.message}"
    []
  end

  def get_generation_data(range = 'A:Z')
    get_data_from_sheet('generacion', range)
  end

  def get_target_data(range = 'A:Z')
    get_data_from_sheet('proyeccion', range)
  end

  private

  def authorize
    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(ENV['GOOGLE_APPLICATION_CREDENTIALS']),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
    )
  end

  def process_data(raw_data)
    return [] unless raw_data && raw_data.length > 1

    headers = raw_data.first
    data_rows = raw_data[1..-1]

    data_rows.map do |row|
      headers.each_with_index.each_with_object({}) do |(header, index), hash|
        hash[header.to_s.downcase.gsub(' ', '_')] = row[index] || ''
      end
    end
  end

  def get_data_from_sheet(sheet_name, range)
    full_range = "#{sheet_name}!#{range}"
    response = @service.get_spreadsheet_values(@sheet_id, full_range)
    process_data(response.values)
  rescue => e
    Rails.logger.error "Error fetching data from sheet '#{sheet_name}': #{e.message}"
  []
  end

end
