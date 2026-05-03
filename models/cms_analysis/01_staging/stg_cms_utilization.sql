-- models/staging/stg_cms_utilization.sql

WITH raw_data AS (
    SELECT * FROM {{ source('cms', 'MEDICARE_SERVICES_2023') }}
)

SELECT
    -- Standardization: Trim spaces and enforce consistent casing
    TRIM(UPPER(RNDRNG_PRVDR_GEO_LVL)) AS geo_lvl,
    TRIM(RNDRNG_PRVDR_GEO_DESC) AS state_name,
    TRIM(UPPER(HCPCS_CD)) AS hcpcs_cd,
    TRIM(UPPER(PLACE_OF_SRVC)) AS place_of_srvc,

    -- Null Handling: Convert null service counts to 0 to protect downstream math
    COALESCE(TOT_BENE_DAY_SRVCS, 0) AS tot_bene_day_srvcs

FROM raw_data
WHERE 
    -- Only drop rows if the fundamental dimension keys are corrupt/missing
    RNDRNG_PRVDR_GEO_DESC IS NOT NULL 
    AND HCPCS_CD IS NOT NULL