class SolarPdfService
  include ActionView::Helpers::NumberHelper

  def initialize(reporte_data)
    @reporte = reporte_data
  end

  def generar_pdf
    html = generar_html_reporte

    WickedPdf.new.pdf_from_string(
      html,
      page_size: 'A4',
      margin: {
        top: 15,
        bottom: 15,
        left: 10,
        right: 10
      },
      encoding: 'UTF-8',
      orientation: 'Portrait',
      print_media_type: true,
      disable_smart_shrinking: true
    )
  end

  private

  def generar_html_reporte
    ApplicationController.renderer.render(
      template: 'dashboard/reporte_pdf',
      layout: 'pdf',
      locals: {
        reporte: @reporte,
        totales: @reporte[:totales],
        sistemas_agrupados: @reporte[:sistemas_agrupados],
        fecha_generacion: Time.current.strftime("%d/%m/%Y %H:%M")
      }
    )
  end
end
