
{{ config(
    materialized='table',
    alias='covid_fact_tbl'
) }}

with col_pivot_cvd as (
    select 
        state_country,
        country,
        update_date,
        update_time,
        case_type,
        case_count
    from (
        select 
            state_country,
            country,
            update_date,
            update_time,
            confirmed_case,
            deaths_case,
            recovered_case,
            suspected_case
        from {{ source('main', 'dbt_source_ingest_raw') }}
    ) src
    unpivot (
        case_count for case_type in (
            confirmed_case,
            deaths_case,
            recovered_case,
            suspected_case
        )
    ) unpvt
),

dedup_covd_tbl as (
    select  
        state_country,
        country,
        update_date,
        update_time,
        case_type,
        case_count,
        row_number() over (
            partition by state_country, country, case_type, update_date 
            order by update_date desc, update_time desc
        )::integer as row_num
    from col_pivot_cvd
)

select 
    state_country,
    country,
    update_date,
    update_time,
    case_type,
    case_count
from dedup_covd_tbl
where row_num = 1
