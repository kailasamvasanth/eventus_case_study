-- models/marts/fct_cms_utilization.sql

WITH staging AS (
    SELECT * FROM {{ ref('int_cms_utilization') }}
),

dim_geo AS (
    SELECT * FROM {{ ref('dim_geography') }}
),

dim_hcpcs AS (
    SELECT * FROM {{ ref('dim_hcpcs') }}
),

joined AS (
    SELECT 
        g.geo_key,
        g.state_name,
        h.hcpcs_key,
        h.service_category,
        s.tot_bene_day_srvcs
    FROM staging s
    JOIN dim_geo g 
        ON s.state_name = g.state_name
    JOIN dim_hcpcs h 
        ON s.hcpcs_cd = h.hcpcs_cd 
        AND s.place_of_srvc = h.place_of_srvc
),

aggregated AS (
    SELECT
        geo_key,
        state_name,
        -- Numerator: Number of AWV Services
        SUM(CASE WHEN service_category = 'Wellness' THEN tot_bene_day_srvcs ELSE 0 END) as awv_volume,
        -- Denominator: LTC Encounters
        SUM(CASE WHEN service_category IN ('LTC Routine', 'ALF Routine') THEN tot_bene_day_srvcs ELSE 0 END) as ltc_encounters
    FROM joined
    GROUP BY 1, 2
)

SELECT
    geo_key,
    state_name,
    awv_volume,
    ltc_encounters,
    -- Handle division by zero gracefully using Snowflake's DIV0 function
    DIV0(awv_volume, ltc_encounters) as awv_penetration_rate
FROM aggregated