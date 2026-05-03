-- models/intermediate/int_cms_utilization.sql

WITH clean_staging AS (
    SELECT * FROM {{ ref('stg_cms_utilization') }}
),

categorized AS (
    SELECT 
        geo_lvl,
        state_name,
        hcpcs_cd,
        place_of_srvc,
        tot_bene_day_srvcs,
        
        -- Business Logic: Create Service Category derived field
        CASE 
            WHEN hcpcs_cd IN ('99307', '99308', '99309', '99310') AND place_of_srvc = 'F' THEN 'LTC Routine'
            WHEN hcpcs_cd IN ('99347', '99348', '99349', '99350') AND place_of_srvc = 'O' THEN 'ALF Routine'
            WHEN hcpcs_cd IN ('G0438', 'G0439') THEN 'Wellness'
            ELSE NULL 
        END AS service_category

    FROM clean_staging
    WHERE 
        -- Geographic Filtering: Keep only state-level entities
        geo_lvl = 'STATE'
        AND state_name NOT IN ('National', 'Unknown', 'Foreign Country', 'All Other Countries')
)

SELECT *
FROM categorized
WHERE 
    -- Noise Reduction: Drop anything outside our target KPI scope
    service_category IS NOT NULL
    AND tot_bene_day_srvcs > 0