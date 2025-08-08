class CreateSolarTargets < ActiveRecord::Migration[7.1]
  def change
    create_table :solar_targets do |t|
      t.string :sistema
      t.decimal :kwh_proyectados_por_generacion_anual
      t.decimal :ahorros_proyectados_por_generacion
      t.string :mes_de_inicio

      t.timestamps
    end
  end
end
