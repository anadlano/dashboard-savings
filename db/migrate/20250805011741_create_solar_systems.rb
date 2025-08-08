# db/migrate/xxxx_create_solar_systems.rb
class CreateSolarSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :solar_systems do |t|
      t.string :sistema, null: false
      t.date :fecha
      t.string :periodo

      # CFE sin sistema solar
      t.decimal :cfe_sin_solar, precision: 10, scale: 2, default: 0
      t.decimal :iva_cfe_sin_solar, precision: 10, scale: 2, default: 0
      t.decimal :cfe_sin_solar_total, precision: 10, scale: 2, default: 0

      # CFE con sistema solar
      t.decimal :cfe_con_solar, precision: 10, scale: 2, default: 0
      t.decimal :iva_cfe_con_solar, precision: 10, scale: 2, default: 0
      t.decimal :cfe_con_solar_total, precision: 10, scale: 2, default: 0

      # Ahorro antes de pago
      t.decimal :ahorro_antes_pago, precision: 10, scale: 2, default: 0
      t.decimal :iva_ahorro, precision: 10, scale: 2, default: 0
      t.decimal :ahorro_antes_pago_total, precision: 10, scale: 2, default: 0

      # Mensualidad Solara
      t.decimal :mensualidad_solara, precision: 10, scale: 2, default: 0
      t.decimal :iva_mensualidad, precision: 10, scale: 2, default: 0
      t.decimal :mensualidad_solara_total, precision: 10, scale: 2, default: 0

      # Ahorro final
      t.decimal :ahorro_final, precision: 10, scale: 2, default: 0
      t.decimal :iva_ahorro_final, precision: 10, scale: 2, default: 0
      t.decimal :ahorro_final_total, precision: 10, scale: 2, default: 0

      t.timestamps
    end

    add_index :solar_systems, :sistema
    add_index :solar_systems, :periodo
    add_index :solar_systems, :fecha
  end
end
