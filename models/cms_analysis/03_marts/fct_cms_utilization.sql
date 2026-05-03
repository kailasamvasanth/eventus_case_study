-- models/marts/fct_cms_utilization.sql

WITH staging AS (
    SELECT * FROM {{ ref('int_cms_utilization') }}
),

dim_geo AS (
    SELECT * FROM {{ ref('dim_geography') }}
),

dim_hcpcs AS (
    SELECT * FROM {{ ref('dim_hcpcs') }}
)

SELECT 
    g.geo_key,
    h.hcpcs_key,
    s.tot_bene_day_srvcs
FROM staging s
-- Join back to dimensions to grab the surrogate keys
JOIN dim_geo g 
    ON s.state_name = g.state_name
JOIN dim_hcpcs h 
    ON s.hcpcs_cd = h.hcpcs_cd 
    AND s.place_of_srvc = h.place_of_srvc