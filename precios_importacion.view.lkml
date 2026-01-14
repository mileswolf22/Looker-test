view: precios_importacion {
  sql_table_name: `datahub-deacero.mart_comercial.precios_importacion` ;;

  # --- Dimensiones ---
  dimension: fecha_cotizacion {
    type: date
    sql: ${TABLE}.Fecha_de_Cotizacion;; }

  dimension: fecha_llegada {
    type: date
    sql: ${TABLE}. ;;
    }

  dimension: anio_semana_cotizacion {
    type: number
    sql: ${TABLE}.AnioSemanaCotizacion ;;
    }

  dimension: anio_semana_llegada {
    type: number
    sql: ${TABLE}.AnioSemanaLlegada ;;
  }

  dimension: tipo_de_cambio {
    type: number
    sql: ${TABLE}.Tipo_de_Cambio ;;
  }

  dimension: rebar_fob_turkey {
    type: number
    sql: ${TABLE}.Rebar_FOB_Turkey ;;
  }

  dimension: rebar_fob_spain {
    type: number
    sql: ${TABLE}.Rebar_FOB_Spain ;;
  }

  dimension: indice_amm_sur_de_europa {
    type: number
    sql: ${TABLE}.Indice_AMM_Sur_de_Europa ;;
  }

  dimension: indice_amm_sudeste_asiatico {
    type: number
    sql: ${TABLE}.Indice_AMM_Sudeste_Asiatico ;;
  }

  dimension: angulo_comercial_turkey {
    type: number
    sql: ${TABLE}.Angulo_Comercial_Turkey ;;
  }

  dimension: angulo_comercial_china {
    type: number
    sql: ${TABLE}.Angulo_Comercial_China ;;
  }

  dimension: vigas_ipn_turkey {
    type: number
    sql: ${TABLE}.Vigas_IPN_Turkey ;;
  }

  dimension: pulso_vigas_int {
    type: number
    sql: ${TABLE}.Pulso_Vigas_Int ;;
  }

  dimension: pais_origen_pulso_vigas {
    type: string
    sql: ${TABLE}.Pais_Origen_Pulso_Vigas ;;
  }

  dimension: platts {
    type: number
    sql: ${TABLE}.Platts ;;
  }

  dimension: senal_varilla {
    type: number
    sql: ${TABLE}.Senal_Varilla ;;
  }

  dimension: piso_varilla {
    type: number
    sql: ${TABLE}.Piso_Varilla ;;
  }

  dimension: senal_alambron {
    type: number
    sql: ${TABLE}.Senal_Alambron ;;
  }

  dimension: senal_angulos {
    type: number
    sql: ${TABLE}.Senal_Angulos_AAA ;;
  }

  dimension: south_central {
    type: number
    sql: ${TABLE}.Southcentral ;;
  }

  dimension: south_west {
    type: number
    sql: ${TABLE}.Southwest ;;
  }

  dimension: referencias_ipr {
    type: number
    sql: ${TABLE}.Refrencias_IPR ;;
  }

  dimension: referencias_ips {
    type: number
    sql: ${TABLE}.Refrencias_IPS ;;
  }

  dimension: precio_de_varilla_malasia {
    type: number
    sql: ${TABLE}.Precio_de_Varilla_Malasia ;;
  }

  dimension: precio_mercado {
    type: number
    sql: ${TABLE}.Precio_mercado ;;
  }

  }
