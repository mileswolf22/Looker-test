view: cuadrante_izquierdo_inferior {
  derived_table: {
    sql:
      -- =====================================================
      -- QUERY PARA CUADRANTE INFERIOR IZQUIERDO
      -- Medidor de Precio + KPIs + Gráfico Combinado Temporal
      -- =====================================================

      WITH semana_limite AS (
        SELECT
          -- Calcular semana límite en formato YYYYWW (semana actual - 5 semanas)
          CAST(EXTRACT(YEAR FROM DATE_SUB(CURRENT_DATE(), INTERVAL 5 WEEK)) AS STRING) ||
          LPAD(CAST(EXTRACT(ISOWEEK FROM DATE_SUB(CURRENT_DATE(), INTERVAL 5 WEEK)) AS STRING), 2, '0') AS semana_limite_str
      ),

      -- Obtener precios internacionales para calcular Precio Importación
      precios_internacionales AS (
        SELECT
          semana,
          fecha_contable,
          CAST(Tipo_Cambio AS FLOAT64) AS Tipo_Cambio,
          CAST(Rebar_FOB_Turkey AS FLOAT64) AS precio_usd_turkey_rebar,
          CAST(Rebar_FOB_Spain AS FLOAT64) AS precio_usd_spain_rebar,
          CAST(Precio_Varilla_Malasia AS FLOAT64) AS precio_usd_malasia_varilla,
          CAST(Angulo_Comercial_Turkey AS FLOAT64) AS precio_usd_turkey_angulo,
          CAST(Angulo_Comercial_China AS FLOAT64) AS precio_usd_china_angulo,
          CAST(Vigas_IPN_Turkey AS FLOAT64) AS precio_usd_turkey_vigas,
          CAST(Pulso_Vigas_Int AS FLOAT64) AS precio_usd_pulso_vigas,
          CAST(Indice_AMM_Sur_Europa AS FLOAT64) AS precio_usd_amm_europa,
          CAST(indice_AMM_Sudeste_Asiatico AS FLOAT64) AS precio_usd_amm_asia
        FROM `datahub-deacero.mart_comercial.ven_mart_comercial`
        CROSS JOIN semana_limite
        WHERE fecha_contable IS NOT NULL
          AND Tipo_Cambio IS NOT NULL
          AND semana >= (SELECT semana_limite_str FROM semana_limite)
          AND (
            Rebar_FOB_Turkey IS NOT NULL
            OR Rebar_FOB_Spain IS NOT NULL
            OR Precio_Varilla_Malasia IS NOT NULL
            OR Angulo_Comercial_Turkey IS NOT NULL
            OR Angulo_Comercial_China IS NOT NULL
            OR Vigas_IPN_Turkey IS NOT NULL
            OR Pulso_Vigas_Int IS NOT NULL
            OR Indice_AMM_Sur_Europa IS NOT NULL
            OR indice_AMM_Sudeste_Asiatico IS NOT NULL
          )
      ),

      -- Unificar precios internacionales y convertir a MXN
      precios_importacion_unificados AS (
        SELECT
          semana,
          fecha_contable,
          Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_turkey_rebar IS NOT NULL
            THEN Tipo_Cambio * precio_usd_turkey_rebar ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_turkey_rebar IS NOT NULL AND precio_usd_turkey_rebar > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_spain_rebar IS NOT NULL
            THEN Tipo_Cambio * precio_usd_spain_rebar ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_spain_rebar IS NOT NULL AND precio_usd_spain_rebar > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_malasia_varilla IS NOT NULL
            THEN Tipo_Cambio * precio_usd_malasia_varilla ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_malasia_varilla IS NOT NULL AND precio_usd_malasia_varilla > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_turkey_angulo IS NOT NULL
            THEN Tipo_Cambio * precio_usd_turkey_angulo ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_turkey_angulo IS NOT NULL AND precio_usd_turkey_angulo > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_china_angulo IS NOT NULL
            THEN Tipo_Cambio * precio_usd_china_angulo ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_china_angulo IS NOT NULL AND precio_usd_china_angulo > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_turkey_vigas IS NOT NULL
            THEN Tipo_Cambio * precio_usd_turkey_vigas ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_turkey_vigas IS NOT NULL AND precio_usd_turkey_vigas > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_pulso_vigas IS NOT NULL
            THEN Tipo_Cambio * precio_usd_pulso_vigas ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_pulso_vigas IS NOT NULL AND precio_usd_pulso_vigas > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_amm_europa IS NOT NULL
            THEN Tipo_Cambio * precio_usd_amm_europa ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_amm_europa IS NOT NULL AND precio_usd_amm_europa > 0

        UNION ALL

        SELECT semana, fecha_contable, Tipo_Cambio,
          CASE WHEN Tipo_Cambio IS NOT NULL AND precio_usd_amm_asia IS NOT NULL
            THEN Tipo_Cambio * precio_usd_amm_asia ELSE NULL END AS precio_mxn
        FROM precios_internacionales
        WHERE precio_usd_amm_asia IS NOT NULL AND precio_usd_amm_asia > 0
      ),

      -- Datos base del cuadrante inferior izquierdo
      datos_base AS (
        SELECT
          semana,
          mes,
          anio,
          trimestre,
          nombre_periodo_mostrar,
          fecha_contable,
          CAST(precio_caida_pedidos AS FLOAT64) AS precio_caida_pedidos,
          CAST(platts AS FLOAT64) AS platts,
          CAST(Platts_total AS FLOAT64) AS platts_total,
          CAST(senal_de_precio AS FLOAT64) AS senal_de_precio,
          CAST(precio_senial AS FLOAT64) AS precio_senial,
          CAST(toneladas_pvo AS FLOAT64) AS toneladas_pvo,
          CAST(toneladas_facturadas AS FLOAT64) AS toneladas_facturadas,
          CAST(toneladas_caida_de_pedidos AS FLOAT64) AS toneladas_caida_de_pedidos,
          CAST(imp_facturado_exworks_mn AS FLOAT64) AS imp_facturado_exworks_mn
        FROM `datahub-deacero.mart_comercial.ven_mart_comercial`
        CROSS JOIN semana_limite
        WHERE semana >= (SELECT semana_limite_str FROM semana_limite)
          AND fecha_contable IS NOT NULL
          AND semana IS NOT NULL
      ),

      -- Agregar precio importación promedio por semana
      datos_con_precio_importacion AS (
        SELECT
          db.semana,
          db.mes,
          db.anio,
          db.trimestre,
          db.nombre_periodo_mostrar,
          db.fecha_contable,
          db.precio_caida_pedidos,
          db.platts,
          COALESCE(db.platts_total, db.platts) AS platts_final,
          COALESCE(db.senal_de_precio, db.precio_senial) AS senal_precio_final,
          db.toneladas_pvo,
          db.toneladas_facturadas,
          db.toneladas_caida_de_pedidos,
          db.imp_facturado_exworks_mn,
          AVG(piu.precio_mxn) OVER (PARTITION BY db.semana) AS precio_importacion_promedio
        FROM datos_base db
        LEFT JOIN precios_importacion_unificados piu
          ON db.semana = piu.semana
      ),

      -- Agregación por semana con cálculos estadísticos
      datos_agregados AS (
        SELECT
          semana,
          MIN(mes) AS mes,
          MIN(anio) AS anio,
          MIN(trimestre) AS trimestre,
          MIN(nombre_periodo_mostrar) AS nombre_periodo_mostrar,
          MIN(fecha_contable) AS fecha_contable_min,
          MAX(fecha_contable) AS fecha_contable_max,
          -- Promedios para líneas de precio
          AVG(precio_caida_pedidos) AS precio_caida_promedio,
          AVG(platts_final) AS platts_promedio,
          AVG(senal_precio_final) AS senal_precio_promedio,
          AVG(precio_importacion_promedio) AS precio_importacion_promedio,
          -- Sumas para volumen
          SUM(toneladas_pvo) AS toneladas_pvo_total,
          SUM(toneladas_facturadas) AS toneladas_facturadas_total,
          SUM(toneladas_caida_de_pedidos) AS toneladas_caida_de_pedidos_total,
          -- Estadísticas para límites (usando STDDEV)
          STDDEV(precio_caida_pedidos) AS precio_caida_stddev,
          AVG(precio_caida_pedidos) + STDDEV(precio_caida_pedidos) AS limite_superior,
          AVG(precio_caida_pedidos) - STDDEV(precio_caida_pedidos) AS limite_inferior,
          -- Cálculo de precio OPVO (si se necesita como precio)
          CASE
            WHEN SUM(toneladas_pvo) > 0 AND SUM(imp_facturado_exworks_mn) > 0
            THEN SUM(imp_facturado_exworks_mn) / SUM(toneladas_pvo)
            ELSE NULL
          END AS precio_opvo_calculado
        FROM datos_con_precio_importacion
        WHERE precio_caida_pedidos IS NOT NULL
        GROUP BY semana
      ),

      -- Agregar cálculos de variación semanal y precio semana anterior
      datos_con_variaciones AS (
        SELECT
          semana,
          mes,
          anio,
          trimestre,
          nombre_periodo_mostrar,
          fecha_contable_min,
          fecha_contable_max,
          precio_caida_promedio,
          platts_promedio,
          senal_precio_promedio,
          precio_importacion_promedio,
          toneladas_pvo_total,
          toneladas_facturadas_total,
          toneladas_caida_de_pedidos_total,
          limite_superior,
          limite_inferior,
          precio_opvo_calculado,
          -- Precio semana anterior usando LAG
          LAG(precio_caida_promedio) OVER (ORDER BY semana) AS precio_semana_anterior,
          -- Variación porcentual semana a semana para toneladas
          LAG(toneladas_facturadas_total) OVER (ORDER BY semana) AS toneladas_semana_anterior,
          CASE
            WHEN LAG(toneladas_facturadas_total) OVER (ORDER BY semana) IS NOT NULL
             AND LAG(toneladas_facturadas_total) OVER (ORDER BY semana) > 0
            THEN ROUND(((toneladas_facturadas_total - LAG(toneladas_facturadas_total) OVER (ORDER BY semana)) /
                        LAG(toneladas_facturadas_total) OVER (ORDER BY semana)) * 100, 2)
            ELSE NULL
          END AS variacion_porcentual_toneladas,
          -- Rango para medidor (MIN y MAX de precio_caida_pedidos histórico)
          MIN(precio_caida_promedio) OVER () AS precio_minimo_historico,
          MAX(precio_caida_promedio) OVER () AS precio_maximo_historico
        FROM datos_agregados
      )

      SELECT
        semana,
        mes,
        anio,
        trimestre,
        nombre_periodo_mostrar,
        fecha_contable_min,
        fecha_contable_max,
        -- Valores para KPIs y medidor
        ROUND(precio_caida_promedio, 2) AS precio_caida_promedio,
        ROUND(limite_superior, 2) AS limite_superior,
        ROUND(limite_inferior, 2) AS limite_inferior,
        ROUND(precio_semana_anterior, 2) AS precio_semana_anterior,
        ROUND(precio_minimo_historico, 2) AS precio_minimo_historico,
        ROUND(precio_maximo_historico, 2) AS precio_maximo_historico,
        -- Valores para líneas de precio
        ROUND(platts_promedio, 2) AS platts_promedio,
        ROUND(senal_precio_promedio, 2) AS senal_precio_promedio,
        ROUND(precio_importacion_promedio, 2) AS precio_importacion_promedio,
        ROUND(precio_opvo_calculado, 2) AS precio_opvo_calculado,
        -- Valores para barras de volumen
        ROUND(toneladas_pvo_total, 2) AS toneladas_pvo_total,
        ROUND(toneladas_facturadas_total, 2) AS toneladas_facturadas_total,
        ROUND(toneladas_caida_de_pedidos_total, 2) AS toneladas_caida_de_pedidos_total,
        -- Variación porcentual
        variacion_porcentual_toneladas,
        -- Formato de semana para etiquetas
        CONCAT('S', SUBSTR(CAST(semana AS STRING), -2)) AS semana_label
      FROM datos_con_variaciones
      WHERE precio_caida_promedio IS NOT NULL
      ORDER BY semana ASC ;;
  }

  # ============================================
  # DIMENSIONS (Campos para agrupar/filtrar)
  # ============================================

  dimension: semana {
    type: string
    sql: ${TABLE}.semana ;;
    description: "Semana en formato YYYYWW"
  }

  dimension: semana_label {
    type: string
    sql: ${TABLE}.semana_label ;;
    description: "Etiqueta de semana formateada (ej: S45)"
  }

  dimension: mes {
    type: string
    sql: ${TABLE}.mes ;;
    description: "Mes en formato YYYYMM"
  }

  dimension: anio {
    type: number
    sql: ${TABLE}.anio ;;
    description: "Año"
  }

  dimension: trimestre {
    type: string
    sql: ${TABLE}.trimestre ;;
    description: "Trimestre"
  }

  dimension: nombre_periodo_mostrar {
    type: string
    sql: ${TABLE}.nombre_periodo_mostrar ;;
    description: "Período formateado para mostrar"
  }

  dimension: fecha_contable_min {
    type: date
    datatype: date
    sql: ${TABLE}.fecha_contable_min ;;
    description: "Fecha contable mínima de la semana"
  }

  dimension: fecha_contable_max {
    type: date
    datatype: date
    sql: ${TABLE}.fecha_contable_max ;;
    description: "Fecha contable máxima de la semana"
  }

  # ============================================
  # MEASURES (Valores numéricos calculables)
  # ============================================

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # KPIs y Medidor
  measure: precio_caida_promedio {
    type: average
    sql: ${TABLE}.precio_caida_promedio ;;
    value_format_name: usd
    description: "Precio caída promedio (para medidor y KPIs)"
  }

  measure: limite_superior {
    type: average
    sql: ${TABLE}.limite_superior ;;
    value_format_name: usd
    description: "Límite superior (Promedio + STDDEV)"
  }

  measure: limite_inferior {
    type: average
    sql: ${TABLE}.limite_inferior ;;
    value_format_name: usd
    description: "Límite inferior (Promedio - STDDEV)"
  }

  measure: precio_semana_anterior {
    type: average
    sql: ${TABLE}.precio_semana_anterior ;;
    value_format_name: usd
    description: "Precio caída semana anterior"
  }

  measure: precio_minimo_historico {
    type: min
    sql: ${TABLE}.precio_minimo_historico ;;
    value_format_name: usd
    description: "Precio mínimo histórico (para rango del medidor)"
  }

  measure: precio_maximo_historico {
    type: max
    sql: ${TABLE}.precio_maximo_historico ;;
    value_format_name: usd
    description: "Precio máximo histórico (para rango del medidor)"
  }

  # Líneas de Precio
  measure: platts_promedio {
    type: average
    sql: ${TABLE}.platts_promedio ;;
    value_format_name: usd
    description: "Platts promedio por semana"
  }

  measure: senal_precio_promedio {
    type: average
    sql: ${TABLE}.senal_precio_promedio ;;
    value_format_name: usd
    description: "Señal de precio promedio por semana"
  }

  measure: precio_importacion_promedio {
    type: average
    sql: ${TABLE}.precio_importacion_promedio ;;
    value_format_name: usd
    description: "Precio importación promedio por semana"
  }

  measure: precio_opvo_calculado {
    type: average
    sql: ${TABLE}.precio_opvo_calculado ;;
    value_format_name: usd
    description: "Precio OPVO calculado (si se necesita como precio)"
  }

  # Volumen (Barras)
  measure: toneladas_pvo_total {
    type: sum
    sql: ${TABLE}.toneladas_pvo_total ;;
    value_format_name: decimal_2
    description: "Toneladas PVO totales por semana"
  }

  measure: toneladas_facturadas_total {
    type: sum
    sql: ${TABLE}.toneladas_facturadas_total ;;
    value_format_name: decimal_2
    description: "Toneladas facturadas totales por semana"
  }

  measure: toneladas_caida_de_pedidos_total {
    type: sum
    sql: ${TABLE}.toneladas_caida_de_pedidos_total ;;
    value_format_name: decimal_2
    description: "Toneladas caída de pedidos totales por semana"
  }

  measure: variacion_porcentual_toneladas {
    type: average
    sql: ${TABLE}.variacion_porcentual_toneladas ;;
    value_format_name: decimal_2
    description: "Variación porcentual semana a semana de toneladas"
  }

  # ============================================
  # SETS (Agrupaciones de campos)
  # ============================================

  set: detail {
    fields: [
      semana,
      semana_label,
      mes,
      anio,
      trimestre,
      nombre_periodo_mostrar,
      fecha_contable_min,
      fecha_contable_max,
      precio_caida_promedio,
      limite_superior,
      limite_inferior,
      precio_semana_anterior,
      precio_minimo_historico,
      precio_maximo_historico,
      platts_promedio,
      senal_precio_promedio,
      precio_importacion_promedio,
      precio_opvo_calculado,
      toneladas_pvo_total,
      toneladas_facturadas_total,
      toneladas_caida_de_pedidos_total,
      variacion_porcentual_toneladas
    ]
  }
}
