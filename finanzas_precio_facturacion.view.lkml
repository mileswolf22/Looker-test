# =====================================================

# KPI Precio - Cuadrante Facturación (incluye tendencias Precio, Spread, EBIT, % EBIT)
# Dashboard: Facturación (cuadrante Precio + tendencias para Spread, EBIT, % EBIT)
# Fuente: ven_mart_comercial
# =====================================================
# Precio: importe destino mn (ExWorks) / toneladas. Spread: Precio Exworks - Costo MP.
# EBIT: Utilidad bruta - Fletes - SG&A - S&H. % EBIT: EBIT / Ventas × 100.
# =====================================================
# Ventana de periodos: todo el año 2025 + 2026 hasta la fecha actual.
# =====================================================

view: kpi_precio_facturacion {
  derived_table: {
    sql:
      WITH
      -- Agregación mensual: precio, spread, EBIT, % EBIT (insumos)
      base_mensual AS (
        SELECT
          v.anio,
          v.mes,
          MAX(v.nombre_periodo_mostrar) AS nombre_periodo_mostrar,
          SUM(SAFE_CAST(v.imp_facturado_exworks_mn AS FLOAT64)) AS importe_exworks_mn,
          SUM(SAFE_CAST(v.toneladas_facturadas AS FLOAT64)) AS toneladas_facturadas,
          SUM(SAFE_CAST(v.costo_mp AS FLOAT64) * SAFE_CAST(v.toneladas_facturadas AS FLOAT64)) AS costo_mp_ponderado,
          SUM(SAFE_CAST(v.importe_estadistico_neto_mn AS FLOAT64)) AS importe_estadistico_mn,
          SUM(SAFE_CAST(v.costo_flete_total AS FLOAT64)) AS costo_flete_total_sum,
          SUM(SAFE_CAST(v.sga_total AS FLOAT64)) AS sga_total_sum,
          SUM(SAFE_CAST(v.sh AS FLOAT64)) AS sh_sum
        FROM `datahub-deacero.mart_comercial.ven_mart_comercial` AS v
        WHERE v.mes IS NOT NULL
          AND v.anio IS NOT NULL
          AND v.fecha_contable IS NOT NULL
          AND v.fecha_contable <= CURRENT_DATE()
          AND (
            CAST(v.anio AS INT64) = 2025
            OR (
              CAST(v.anio AS INT64) = 2026
              AND DATE(CAST(v.anio AS INT64), CAST(SUBSTR(CAST(v.mes AS STRING), 5, 2) AS INT64), 1) <= CURRENT_DATE()
            )
          )
        GROUP BY v.anio, v.mes
      ),
      -- Precio, Spread ($/ton), EBIT ($), % EBIT
      con_metricas AS (
        SELECT
          anio,
          mes,
          nombre_periodo_mostrar,
          importe_exworks_mn,
          toneladas_facturadas,
          SAFE_DIVIDE(importe_exworks_mn, NULLIF(toneladas_facturadas, 0)) AS precio,
          SAFE_DIVIDE(importe_exworks_mn - costo_mp_ponderado, NULLIF(toneladas_facturadas, 0)) AS spread,
          (importe_estadistico_mn - costo_mp_ponderado - IFNULL(costo_flete_total_sum, 0) - IFNULL(sga_total_sum, 0) - IFNULL(sh_sum, 0)) AS ebit,
          SAFE_DIVIDE((importe_estadistico_mn - costo_mp_ponderado - IFNULL(costo_flete_total_sum, 0) - IFNULL(sga_total_sum, 0) - IFNULL(sh_sum, 0)), NULLIF(importe_estadistico_mn, 0)) * 100 AS pct_ebit
        FROM base_mensual
      ),
      -- LAG para comparativos vs mes anterior
      con_comparativos AS (
        SELECT
          anio,
          mes,
          nombre_periodo_mostrar,
          importe_exworks_mn,
          toneladas_facturadas,
          precio,
          spread,
          ebit,
          pct_ebit,
          LAG(precio) OVER (ORDER BY anio, mes) AS precio_mes_ant,
          LAG(spread) OVER (ORDER BY anio, mes) AS spread_mes_ant,
          LAG(ebit) OVER (ORDER BY anio, mes) AS ebit_mes_ant,
          LAG(pct_ebit) OVER (ORDER BY anio, mes) AS pct_ebit_mes_ant
        FROM con_metricas
      )
      SELECT
        anio,
        mes,
        nombre_periodo_mostrar,
        ROUND(importe_exworks_mn, 2) AS importe_exworks_mn,
        ROUND(toneladas_facturadas, 2) AS toneladas_facturadas,
        ROUND(precio, 2) AS precio,
        ROUND(precio - precio_mes_ant, 2) AS vs_mes_ant,
        ROUND(SAFE_DIVIDE(precio - precio_mes_ant, precio_mes_ant) * 100, 2) AS pct_cambio,
        CASE WHEN precio_mes_ant IS NULL OR (precio - precio_mes_ant) = 0 THEN 0 WHEN (precio - precio_mes_ant) > 0 THEN 1 ELSE -1 END AS tendencia,
        ROUND(spread, 2) AS spread,
        ROUND(spread - spread_mes_ant, 2) AS vs_mes_ant_spread,
        ROUND(SAFE_DIVIDE(spread - spread_mes_ant, spread_mes_ant) * 100, 2) AS pct_cambio_spread,
        CASE WHEN spread_mes_ant IS NULL OR (spread - spread_mes_ant) = 0 THEN 0 WHEN (spread - spread_mes_ant) > 0 THEN 1 ELSE -1 END AS tendencia_spread,
        ROUND(ebit, 2) AS ebit,
        ROUND(ebit - ebit_mes_ant, 2) AS vs_mes_ant_ebit,
        ROUND(SAFE_DIVIDE(ebit - ebit_mes_ant, ebit_mes_ant) * 100, 2) AS pct_cambio_ebit,
        CASE WHEN ebit_mes_ant IS NULL OR (ebit - ebit_mes_ant) = 0 THEN 0 WHEN (ebit - ebit_mes_ant) > 0 THEN 1 ELSE -1 END AS tendencia_ebit,
        ROUND(pct_ebit, 2) AS pct_ebit,
        ROUND(pct_ebit - pct_ebit_mes_ant, 2) AS vs_mes_ant_pct_ebit,
        ROUND(SAFE_DIVIDE(pct_ebit - pct_ebit_mes_ant, pct_ebit_mes_ant) * 100, 2) AS pct_cambio_pct_ebit,
        CASE WHEN pct_ebit_mes_ant IS NULL OR (pct_ebit - pct_ebit_mes_ant) = 0 THEN 0 WHEN (pct_ebit - pct_ebit_mes_ant) > 0 THEN 1 ELSE -1 END AS tendencia_pct_ebit
      FROM con_comparativos
      WHERE toneladas_facturadas > 0
        AND precio IS NOT NULL
      ORDER BY anio DESC, mes DESC ;;
  }

  # ---------- Dimensiones ----------
  dimension: anio {
    type: number
    sql: ${TABLE}.anio ;;
    description: "Año del periodo"
  }

  dimension: mes {
    type: string
    sql: ${TABLE}.mes ;;
    description: "Mes en formato YYYYMM"
  }

  dimension: nombre_periodo_mostrar {
    type: string
    sql: ${TABLE}.nombre_periodo_mostrar ;;
    description: "Etiqueta del periodo (ej. Ene-2025)"
  }

  # ---------- Medidas principales (cuadrante Precio) ----------
  measure: precio {
    type: average
    sql: ${TABLE}.precio ;;
    value_format_name: decimal_2
    description: "Precio por tonelada (ExWorks, según datalake: importe destino mn/toneladas facturadas)"
  }

  measure: vs_mes_ant {
    type: average
    sql: ${TABLE}.vs_mes_ant ;;
    value_format_name: decimal_2
    description: "Vs Mes Ant (diferencia de precio vs mes anterior)"
  }

  measure: pct_cambio {
    type: average
    sql: ${TABLE}.pct_cambio ;;
    value_format_name: decimal_2
    description: "% Cambio (vs mes anterior)"
  }

  measure: tendencia {
    type: average
    sql: ${TABLE}.tendencia ;;
    value_format_name: decimal_2
    description: "Tendencia Precio (1=al alza, -1=a la baja, 0=sin cambio; vs mes anterior)"
  }

  measure: spread {
    type: average
    sql: ${TABLE}.spread ;;
    value_format_name: decimal_2
    description: "Spread $/ton (Precio Exworks - Costo MP)"
  }

  measure: vs_mes_ant_spread {
    type: average
    sql: ${TABLE}.vs_mes_ant_spread ;;
    value_format_name: decimal_2
    description: "Vs Mes Ant Spread ($/ton)"
  }

  measure: pct_cambio_spread {
    type: average
    sql: ${TABLE}.pct_cambio_spread ;;
    value_format_name: decimal_2
    description: "% Cambio Spread (vs mes anterior)"
  }

  measure: tendencia_spread {
    type: average
    sql: ${TABLE}.tendencia_spread ;;
    value_format_name: decimal_2
    description: "Tendencia Spread (1=al alza, -1=a la baja, 0=sin cambio; vs mes anterior)"
  }

  measure: ebit {
    type: sum
    sql: ${TABLE}.ebit ;;
    value_format_name: decimal_2
    description: "EBIT del mes ($)"
  }

  measure: vs_mes_ant_ebit {
    type: average
    sql: ${TABLE}.vs_mes_ant_ebit ;;
    value_format_name: decimal_2
    description: "Vs Mes Ant EBIT ($)"
  }

  measure: pct_cambio_ebit {
    type: average
    sql: ${TABLE}.pct_cambio_ebit ;;
    value_format_name: decimal_2
    description: "% Cambio EBIT (vs mes anterior)"
  }

  measure: tendencia_ebit {
    type: average
    sql: ${TABLE}.tendencia_ebit ;;
    value_format_name: decimal_2
    description: "Tendencia EBIT (1=al alza, -1=a la baja, 0=sin cambio; vs mes anterior)"
  }

  measure: pct_ebit {
    type: average
    sql: ${TABLE}.pct_ebit ;;
    value_format_name: decimal_2
    description: "% EBIT (EBIT / Ventas × 100)"
  }

  measure: vs_mes_ant_pct_ebit {
    type: average
    sql: ${TABLE}.vs_mes_ant_pct_ebit ;;
    value_format_name: decimal_2
    description: "Vs Mes Ant % EBIT (puntos porcentuales)"
  }

  measure: pct_cambio_pct_ebit {
    type: average
    sql: ${TABLE}.pct_cambio_pct_ebit ;;
    value_format_name: decimal_2
    description: "% Cambio % EBIT (vs mes anterior)"
  }

  measure: tendencia_pct_ebit {
    type: average
    sql: ${TABLE}.tendencia_pct_ebit ;;
    value_format_name: decimal_2
    description: "Tendencia % EBIT (1=al alza, -1=a la baja, 0=sin cambio; vs mes anterior)"
  }

  # ---------- Medidas auxiliares (drill) ----------
  measure: importe_exworks_mn {
    type: sum
    sql: ${TABLE}.importe_exworks_mn ;;
    value_format_name: decimal_2
    description: "Importe facturado ExWorks MN del mes"
  }

  measure: toneladas_facturadas {
    type: sum
    sql: ${TABLE}.toneladas_facturadas ;;
    value_format_name: decimal_2
    description: "Toneladas facturadas del mes"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [anio, mes, nombre_periodo_mostrar, precio, vs_mes_ant, pct_cambio, spread, vs_mes_ant_spread, pct_cambio_spread, ebit, vs_mes_ant_ebit, pct_cambio_ebit, pct_ebit, vs_mes_ant_pct_ebit, pct_cambio_pct_ebit, importe_exworks_mn, toneladas_facturadas]
  }
}
