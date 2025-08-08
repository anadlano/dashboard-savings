class SolarGeneration < ApplicationRecord
  validates :sistema, presence: true
  validates :fecha, presence: true
  validates :periodo, presence: true

  # Scopes para filtros
  scope :by_sistema, ->(sistema) { where(sistema: sistema) if sistema.present? }
  scope :by_periodo, ->(periodo) { where(periodo: periodo) if periodo.present? }
  scope :by_fecha_range, ->(fecha_inicio, fecha_fin) {
    where(fecha: fecha_inicio..fecha_fin) if fecha_inicio.present? && fecha_fin.present?
  }

  # Métodos de clase
  def self.sistemas_unicos
    distinct.pluck(:sistema).compact.sort
  end

  def self.periodos_unicos
    distinct.pluck(:periodo).compact.sort.reverse
  end

  # Cálculos agregados
  def self.calcular_totales
    {
      generacion_esperada: sum(:generacion_esperada),
      generacion_garantizada: sum(:generacion_garantizada),
      generacion_real: sum(:generacion_real),
      comparativo_real_vs_garantizada: sum(:comparativo_real_vs_garantizada),
      comparativo_real_vs_esperada: sum(:comparativo_real_vs_esperada)
    }
  end

  # Métodos de instancia
  def performance_vs_garantizada_pct
    return 0 if generacion_garantizada.zero?
    ((generacion_real / generacion_garantizada) * 100).round(2)
  end

  def performance_vs_esperada_pct
    return 0 if generacion_esperada.zero?
    ((generacion_real / generacion_esperada) * 100).round(2)
  end
end
