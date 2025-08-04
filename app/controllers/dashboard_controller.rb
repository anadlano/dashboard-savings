class DashboardController < ApplicationController
  before_action :initialize_sheets_service

  def index
    @data = fetch_sheet_data
  end

  def api_data
    data = fetch_sheet_data
    render json: {
      data: data,
      updated_at: Time.current,
      total_records: data.length
    }
  end

  private

  def initialize_sheets_service
    @sheets_service = GoogleSheetsService.new
  end

  def fetch_sheet_data
    @sheets_service.get_data
  rescue => e
    Rails.logger.error "Error in dashboard: #{e.message}"
    []
  end
end
