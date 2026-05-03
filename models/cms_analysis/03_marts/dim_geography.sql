-- models/marts/dim_geography.sql

WITH staging AS (
    SELECT * FROM {{ ref('int_cms_utilization') }}
)

SELECT DISTINCT
    -- Create a surrogate key using MD5 hash for faster joins in Snowflake
    MD5(CAST(state_name AS VARCHAR)) AS geo_key,
    state_name
FROM staging