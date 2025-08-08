class SolarSystem < ApplicationRecord
  validates :sistema, presence: true
  validates :fecha, presence: true
  validates :periodo, presence: true
  belongs_to :solar_target, foreign_key: :sistema, primary_key: :sistema

  # Scopes para filtros
  scope :by_sistema, ->(sistema) { where(sistema: sistema) if sistema.present? }
  scope :by_periodo, ->(periodo) { where(periodo: periodo) if periodo.present? }
  scope :by_fecha_range, ->(fecha_inicio, fecha_fin) {
    where(fecha: fecha_inicio..fecha_fin) if fecha_inicio.present? && fecha_fin.present?
  }

  # Métodos de clase para obtener opciones únicas
  def self.sistemas_unicos
    distinct.pluck(:sistema).compact.sort
  end

  def self.periodos_unicos
    distinct.pluck(:periodo).compact.sort.reverse
  end

  # Cálculos agregados
  def self.calcular_totales
    {
      cfe_sin_solar: sum(:cfe_sin_solar),
      cfe_sin_solar_total: sum(:cfe_sin_solar_total),
      cfe_con_solar: sum(:cfe_con_solar),
      cfe_con_solar_total: sum(:cfe_con_solar_total),
      ahorro_antes_pago: sum(:ahorro_antes_pago),
      ahorro_antes_pago_total: sum(:ahorro_antes_pago_total),
      mensualidad_solara: sum(:mensualidad_solara),
      mensualidad_solara_total: sum(:mensualidad_solara_total),
      ahorro_final: sum(:ahorro_final),
      ahorro_final_total: sum(:ahorro_final_total)
    }
  end
end
