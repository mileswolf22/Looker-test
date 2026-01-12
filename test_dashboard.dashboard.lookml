dashboard: score_de_precios
title: "Score de precios"
layout: newspaper
preferred_viewer: dashboards-next

filters:
- name: periodo
  title: "Periodo"
  type: field_filter
  field: ven_mart_comercial.periodo

- name: zona
  title: "Zona"
  type: field_filter
  field: ven_mart_comercial.zona

elements:

# ─────────── HEADER / TEXTO ───────────
- name: titulo
  type: text
  row: 0
  col: 0
  width: 24
  height: 3
  text: |
    ## ⭐ Score de precios

# ─────────── TABLA REFERENCIAS ───────────
- name: referencias
  title: "Referencias"
  type: table
  explore: ven_mart_comercial
  fields: [
  ven_mart_comercial.referencia,
  ven_mart_comercial.precio,
  ven_mart_comercial.variacion
]
  row: 3
  col: 0
  width: 8
  height: 6

# ─────────── BARRAS COMPARATIVAS ───────────
- name: precios_por_semana
  title: "Precio vs Importación"
  type: looker_column
  explore: ven_mart_comercial
  fields: [
  ven_mart_comercial.semana,
  ven_mart_comercial.precio_caida,
  ven_mart_comercial.precio_importacion
]
  row: 3
  col: 8
  width: 8
  height: 6

# ─────────── BUBBLE CHART ───────────
- name: spread_vs_indice
  title: "Spread vs Índice Precio"
  type: looker_scatter
  explore: ven_mart_comercial
  fields: [
  ven_mart_comercial.indice_precio,
  ven_mart_comercial.spread,
  ven_mart_comercial.volumen
]
  row: 3
  col: 16
  width: 8
  height: 6

# ─────────── GAUGE / KPI ───────────
- name: medidor_precio
  title: "Medidor de Precio"
  type: looker_gauge
  explore: ven_mart_comercial
  fields: [ven_mart_comercial.precio_actual]
  row: 9
  col: 0
  width: 8
  height: 6

# ─────────── DONUT ───────────
- name: distribucion_escenarios
  title: "Escenarios"
  type: looker_pie
  explore: ven_mart_comercial
  fields: [
  ven_mart_comercial.escenario,
  ven_mart_comercial.participacion
]
  row: 9
  col: 8
  width: 8
  height: 6

# ─────────── ALERTA TEXTO ───────────
- name: alerta
  type: text
  row: 9
  col: 16
  width: 8
  height: 4
  text: |
    ### ⚠️ PUEDE SUFRIR CAMBIOS

# ─────────── TABLA DETALLE ───────────
- name: costos
  title: "Costos y Spread"
  type: table
  explore: ven_mart_comercial
  fields: [
  ven_mart_comercial.mes,
  ven_mart_comercial.precio_varilla,
  ven_mart_comercial.costo_mezcla,
  ven_mart_comercial.spread
]
  row: 13
  col: 16
  width: 8
  height: 6
