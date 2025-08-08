class CreateSolarGenerations < ActiveRecord::Migration[7.1]
  def change
    create_table :solar_generations do |t|
      t.string :sistema
      t.date :fecha
      t.string :periodo
      t.decimal :generacion_esperada
      t.decimal :generacion_garantizada
      t.decimal :generacion_real
      t.decimal :comparativo_real_vs_garantizada
      t.decimal :comparativo_real_vs_esperada

      t.timestamps
    end
  end
end
