-- models/marts/dim_hcpcs.sql

WITH staging AS (
    SELECT * FROM {{ ref('int_cms_utilization') }}
)

SELECT DISTINCT
    -- Surrogate key combining HCPCS and POS
    MD5(CAST(hcpcs_cd AS VARCHAR) || CAST(place_of_srvc AS VARCHAR)) AS hcpcs_key,
    hcpcs_cd,
    place_of_srvc,
    service_category
FROM staging
