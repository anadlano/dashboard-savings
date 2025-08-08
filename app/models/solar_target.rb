class SolarTarget < ApplicationRecord
  validates :sistema, presence: true
  validates :kwh_proyectados_por_generacion_anual, presence: true
  validates :ahorros_proyectados_por_generacion, presence: true
  has_many :solar_systems, foreign_key: :sistema, primary_key: :sistema

  # Scopes
  scope :by_sistema, ->(sistema) { where(sistema: sistema) if sistema.present? }

  def self.sistemas_unicos
    distinct.pluck(:sistema).compact.sort
  end

  def self.calcular_totales
    {
      kwh_proyectados_total: sum(:kwh_proyectados_por_generacion_anual),
      ahorros_proyectados_total: sum(:ahorros_proyectados_por_generacion)
    }
  end
end
