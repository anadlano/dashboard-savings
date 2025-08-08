# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_08_06_023343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "solar_generations", force: :cascade do |t|
    t.string "sistema"
    t.date "fecha"
    t.string "periodo"
    t.decimal "generacion_esperada"
    t.decimal "generacion_garantizada"
    t.decimal "generacion_real"
    t.decimal "comparativo_real_vs_garantizada"
    t.decimal "comparativo_real_vs_esperada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solar_systems", force: :cascade do |t|
    t.string "sistema", null: false
    t.date "fecha"
    t.string "periodo"
    t.decimal "cfe_sin_solar", precision: 10, scale: 2, default: "0.0"
    t.decimal "iva_cfe_sin_solar", precision: 10, scale: 2, default: "0.0"
    t.decimal "cfe_sin_solar_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "cfe_con_solar", precision: 10, scale: 2, default: "0.0"
    t.decimal "iva_cfe_con_solar", precision: 10, scale: 2, default: "0.0"
    t.decimal "cfe_con_solar_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "ahorro_antes_pago", precision: 10, scale: 2, default: "0.0"
    t.decimal "iva_ahorro", precision: 10, scale: 2, default: "0.0"
    t.decimal "ahorro_antes_pago_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "mensualidad_solara", precision: 10, scale: 2, default: "0.0"
    t.decimal "iva_mensualidad", precision: 10, scale: 2, default: "0.0"
    t.decimal "mensualidad_solara_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "ahorro_final", precision: 10, scale: 2, default: "0.0"
    t.decimal "iva_ahorro_final", precision: 10, scale: 2, default: "0.0"
    t.decimal "ahorro_final_total", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fecha"], name: "index_solar_systems_on_fecha"
    t.index ["periodo"], name: "index_solar_systems_on_periodo"
    t.index ["sistema"], name: "index_solar_systems_on_sistema"
  end

  create_table "solar_targets", force: :cascade do |t|
    t.string "sistema"
    t.decimal "kwh_proyectados_por_generacion_anual"
    t.decimal "ahorros_proyectados_por_generacion"
    t.string "mes_de_inicio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
