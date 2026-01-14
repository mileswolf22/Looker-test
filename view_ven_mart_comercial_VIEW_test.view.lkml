view: ven_mart_comercial {
  sql_table_name: `datahub-deacero.mart_comercial.ven_mart_comercial` ;;

  # --- Dimensiones ---
  dimension: anio { type: number sql: ${TABLE}.anio ;; }
  dimension: mes { type: string sql: ${TABLE}.mes ;; }
  dimension: trimestre { type: string sql: ${TABLE}.trimestre ;; }
  dimension: semana { type: string sql: ${TABLE}.semana ;; }

  dimension_group: fecha_contable {
    type: time
    timeframes: [raw, time, date, month, year]
    sql: TIMESTAMP(${TABLE}.fecha_contable) ;;
    convert_tz: no
  }

  dimension: clave_periodo { type: number sql: ${TABLE}.clave_periodo ;; }
  dimension: nombre_periodo { type: string sql: ${TABLE}.nombre_periodo ;; }
  dimension: nombre_periodo_mostrar { type: string sql: ${TABLE}.nombre_periodo_mostrar ;; }
  dimension: cla_direccion { type: number sql: ${TABLE}.cla_direccion ;; }
  dimension: nom_direccion { type: string sql: ${TABLE}.nom_direccion ;; }
  dimension: cla_subdireccion { type: number sql: ${TABLE}.cla_subdireccion ;; }
  dimension: nom_subdireccion { type: string sql: ${TABLE}.nom_subdireccion ;; }
  dimension: cla_gerencia { type: number sql: ${TABLE}.cla_gerencia ;; }
  dimension: nom_gerencia { type: string sql: ${TABLE}.nom_gerencia ;; }
  dimension: cla_cliente_unico { type: number sql: ${TABLE}.cla_cliente_unico ;; }
  dimension: nom_cliente_unico { type: string sql: ${TABLE}.nom_cliente_unico ;; }
  dimension: nom_estado_consignado { type: string sql: ${TABLE}.nom_estado_consignado ;; }
  dimension: cla_zona { type: number sql: ${TABLE}.cla_zona ;; }
  dimension: nom_zona { type: string sql: ${TABLE}.nom_zona ;; }
  dimension: cla_nivel_canal { type: number sql: ${TABLE}.cla_nivel_canal ;; }
  dimension: nom_canal { type: string sql: ${TABLE}.nom_canal ;; }
  dimension: cla_grupo_estadistico1 { type: number sql: ${TABLE}.cla_grupo_estadistico1 ;; }
  dimension: nom_grupo_estadistico1 { type: string sql: ${TABLE}.nom_grupo_estadistico1 ;; }
  dimension: cla_grupo_estadistico2 { type: number sql: ${TABLE}.cla_grupo_estadistico2 ;; }
  dimension: nom_grupo_estadistico2 { type: string sql: ${TABLE}.nom_grupo_estadistico2 ;; }
  dimension: cla_grupo_estadistico3 { type: number sql: ${TABLE}.cla_grupo_estadistico3 ;; }
  dimension: nom_grupo_estadistico3 { type: string sql: ${TABLE}.nom_grupo_estadistico3 ;; }
  dimension: cla_grupo_estadistico4 { type: number sql: ${TABLE}.cla_grupo_estadistico4 ;; }
  dimension: nom_grupo_estadistico4 { type: string sql: ${TABLE}.nom_grupo_estadistico4 ;; }
  dimension: segmento_clientes_clasificacion { type: string sql: ${TABLE}.segmento_clientes_clasificacion ;; }


  # --- CAMPOS NUMÉRICOS BASE (incluye campos de Mayra) ---
  dimension: toneladas_facturadas { type: number hidden: yes sql: ${TABLE}.toneladas_facturadas ;; }
  dimension: toneladas_pvo { type: number hidden: yes sql: ${TABLE}.toneladas_pvo ;; }
  dimension: toneladas_tendencia_colaborada { type: number hidden: yes sql: ${TABLE}.toneladas_tendencia_colaborada ;; }
  dimension: importe_estadistico_neto_mn { type: number hidden: yes sql: ${TABLE}.importe_estadistico_neto_mn ;; }
  dimension: importe_estadistico_ajustado { type: number hidden: yes sql: ${TABLE}.importe_estadistico_ajustado ;; }
  dimension: spread { type: number hidden: yes sql: ${TABLE}.spread ;; }
  dimension: costo_mp { type: number hidden: yes sql: ${TABLE}.costo_mp ;; }
  dimension: toneladas_caida_de_pedidos { type: number hidden: yes sql: ${TABLE}.toneladas_caida_de_pedidos ;; }
  dimension: toneladas_pedidas { type: number hidden: yes sql: ${TABLE}.toneladas_pedidas ;; }
  dimension: imp_precio_entrega_mn { type: number hidden: yes sql: ${TABLE}.imp_precio_entrega_mn ;; }
  dimension: precio_caida_pedidos { type: number hidden: yes sql: ${TABLE}.precio_caida_pedidos ;; }
  dimension: senal_de_precio { type: number hidden: yes sql: ${TABLE}.senal_de_precio ;; }
  dimension: platts { type: number hidden: yes sql: ${TABLE}.platts ;; }
  dimension: pulso {type: number hidden: yes sql: ${TABLE}.precio_pulso ;;}

  # --- PRECIOS DE IMPORTACION ---
  dimension : rebar_fob_turkey {type: number hidden: yes sql: ${TABLE}.Rebar_FOB_Turkey ;;}
  dimension : indice_amm_sur_de_europa {type: number hidden: yes sql: ${TABLE}.Indice_AMM_Sur_Europa ;;}
  dimension : rebar_fob_spain {type: number hidden: yes sql: ${TABLE}.Rebar_FOB_Spain ;;}
  dimension : indice_amm_sudeste_asiatico {type: number hidden: yes sql: ${TABLE}.Indice_AMM_Sudeste_Asiatico ;;}
  dimension : angulo_comercial_turkey {type: number hidden: yes sql: ${TABLE}.Angulo_Comercial_Turkey ;;}
  dimension : angulo_comercial_china {type: number hidden: yes sql: ${TABLE}.Angulo_Comercial_China ;;}
  dimension : vigas_ipn_turkey {type: number hidden: yes sql: ${TABLE}.Vigas_IPN_Turkey ;;}
  dimension : pulso_vigas_int {type: number hidden: yes sql: ${TABLE}.Pulso_Vigas_Int ;;}

  dimension: pais {
    type: string
    sql:
    CASE
      WHEN ${nom_grupo_estadistico1} ILIKE '%Turkey%' THEN 'Turkey'
      WHEN ${nom_grupo_estadistico1} ILIKE '%Spain%' THEN 'Spain'
      WHEN ${nom_grupo_estadistico1} ILIKE '%China%' THEN 'China'
      WHEN ${nom_grupo_estadistico1} ILIKE '%Europa%' THEN 'Europa'
      WHEN ${nom_grupo_estadistico1} ILIKE '%Asiatico%' THEN 'Sudeste Asiatico'

      WHEN ${nom_grupo_estadistico2} ILIKE '%Turkey%' THEN 'Turkey'
      WHEN ${nom_grupo_estadistico2} ILIKE '%China%' THEN 'China'

      WHEN ${nom_grupo_estadistico3} ILIKE '%Turkey%' THEN 'Turkey'
      WHEN ${nom_grupo_estadistico3} ILIKE '%China%' THEN 'China'

      ELSE 'Internacional'
      END ;;
  }

  dimension: precio_importacion_referencia {
    type: number
    sql:
      CASE
        -- VARILLA
        WHEN ${nom_grupo_estadistico1} = 'VARILLA'
             AND ${nom_grupo_estadistico2} IS NULL
             AND ${nom_grupo_estadistico3} IS NULL
             AND ${pais} = 'Turkey'
          THEN ${rebar_fob_turkey}

        WHEN ${nom_grupo_estadistico1} = 'VARILLA'
        AND ${pais} = 'Spain'
        THEN ${rebar_fob_spain}

        -- ALAMBRÓN
        WHEN ${nom_grupo_estadistico1} = 'ALAMBRON'
        AND ${nom_grupo_estadistico2} = 'ALAMBRON TREFILAR'
        AND ${pais} = 'Europa'
        THEN ${indice_amm_sur_de_europa}

        WHEN ${nom_grupo_estadistico1} = 'ALAMBRON'
        AND ${nom_grupo_estadistico2} = 'ALAMBRON TREFILAR'
        AND ${pais} = 'Sudeste Asiatico'
        THEN ${indice_amm_sudeste_asiatico}

        -- PERFILES / ÁNGULOS
        WHEN ${nom_grupo_estadistico1} = 'PERFILES'
        AND ${nom_grupo_estadistico2} = 'PERFILES COMERCIALES'
        AND ${nom_grupo_estadistico3} = 'ANGULOS COMERCIALES'
        AND ${pais} = 'Turkey'
        THEN ${angulo_comercial_turkey}

        WHEN ${nom_grupo_estadistico1} = 'PERFILES'
        AND ${nom_grupo_estadistico2} = 'PERFILES COMERCIALES'
        AND ${nom_grupo_estadistico3} = 'ANGULOS COMERCIALES'
        AND ${pais} = 'China'
        THEN ${angulo_comercial_china}

        -- VIGAS
        WHEN ${nom_grupo_estadistico1} = 'PERFILES'
        AND ${nom_grupo_estadistico2} = 'VIGAS IPR'
        AND ${pais} = 'Turkey'
        THEN ${vigas_ipn_turkey}

        WHEN ${nom_grupo_estadistico1} = 'PERFILES'
        AND ${nom_grupo_estadistico2} = 'VIGAS IPR'
        THEN ${pulso_vigas_int}

        ELSE NULL
        END ;;
  }


  # --- MEDIDAS BASE (SUMAS) ---

  measure: total_toneladas_facturadas {
    type: sum
    label: "Volumen (Tons)"
    sql: ${toneladas_facturadas} ;;
    value_format_name: "decimal_0"
  }

  measure: total_toneladas_pvo {
    type: sum
    label: "PVO (Tons)"
    sql: ${toneladas_pvo} ;;
    value_format_name: "decimal_0"
  }

  measure: total_toneladas_tendencia_colaborada {
    type: sum
    label: "Tendencia Colaborada (Tons)"
    sql: ${toneladas_tendencia_colaborada} ;;
    value_format_name: "decimal_0"
  }

  measure: total_importe_estadistico_neto_mn {
    type: sum
    label: "Importe Estadistico Neto MN"
    sql: ${importe_estadistico_neto_mn} ;;
    value_format_name: "decimal_0"
  }

  measure: total_importe_estadistico_ajustado {
    type: sum
    label: "Importe Estadistico Ajustado"
    sql: ${importe_estadistico_ajustado} ;;
    value_format_name: "decimal_0"
  }

  measure: total_spread {
    type: sum
    label: "SPREAD"
    sql: ${spread} ;;
    value_format_name: "decimal_0"
  }

  measure: total_costo_mp {
    type: sum
    label: "Costo Materia Prima"
    sql: ${costo_mp} ;;
    value_format_name: "decimal_0"
  }

  measure: total_toneladas_caida_de_pedidos {
    type: sum
    label: "Toneladas Caida de Pedidos"
    sql: ${toneladas_caida_de_pedidos} ;;
    value_format_name: "decimal_0"
  }

  measure: total_toneladas_pedidas {
    type: sum
    label: "Toneladas Pedidas"
    sql: ${toneladas_pedidas} ;;
    value_format_name: "decimal_0"
  }

  measure: total_imp_precio_entrega_mn {
    type: sum
    label: "Importe Precio Entrega"
    sql: ${imp_precio_entrega_mn} ;;
    value_format_name: "decimal_0"
  }

  measure: total_precio_caida_pedidos {
    type: sum
    label: "Precio Caida de Pedidos"
    sql: ${precio_caida_pedidos} ;;
    value_format_name: "decimal_0"
  }

  measure: total_senal_de_precio {
    type: sum
    label: "Toneladas Señal de Precio"
    sql: ${senal_de_precio} ;;
    value_format_name: "decimal_0"
  }

  measure: total_platts {
    type: sum
    label: "Total Platts"
    sql: ${platts} ;;
    value_format_name: "decimal_0"
  }

  measure: premium_caida_pedidos {
    type:  average
    label: "PremiumVsCaida_Pedidos"
    sql: SAFE_DIVIDE(${precio_caida_pedidos}, ${imp_precio_entrega_mn});;
    value_format_name: "decimal_0"
  }

  # measure: premium_vs_facturacion {
  #   type: average
  #   label: "PremiumVsFacturacion"
  #   sql:  ${};;
  # value_format_name: "decimal_0"
  # }

  measure: indice_precios {
    type: average
    label: "Indice de Precios"
    sql:
      CASE
        WHEN ${precio_caida_pedidos} IS NOT NULL
         AND ${precio_caida_pedidos} != 0
         AND ${pulso} IS NOT NULL
         AND ${pulso} != 0
        THEN ${precio_caida_pedidos} / ${pulso}
        ELSE NULL
      END ;;
    value_format_name: "decimal_0"
  }

}
