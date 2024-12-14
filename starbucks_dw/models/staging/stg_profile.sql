/* TO BE IMPLEMENTED BY THE STUDENT */

{{ config(
    materialized='view'
) }}

WITH source_data AS (
    SELECT
        a AS row_counter,
        COALESCE(gender, 'N/A') AS gender,
        age,
        id AS customer_id,
        to_date(became_member_on::TEXT, 'YYYYMMDD') AS became_member_on,
        COALESCE(income, 0) AS income,
        CURRENT_TIMESTAMP AS ingested_at

    from {{ ref('profile') }}
    where age <> 118

)

SELECT * FROM source_data
