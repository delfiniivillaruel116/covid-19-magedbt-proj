WITH parsed_data AS (
    SELECT
        "province/state" AS state_country,
        "Country/region" AS Country,

         -- Extract DATE from "Last Update", CASE statement is transforming different data formats. The ELSE  "Last Update" was implemented to intendedly fail the job so Developers Can Catch the new incoming format and Add new transformation
         CAST(
  CASE
    WHEN LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) = 4 
         AND SPLIT_PART("Last Update", ' ', 2) ~ '^\d{1,2}:\d{2}$' 
      THEN STRPTIME("Last Update", '%m/%d/%Y %H:%M')

    WHEN LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) = 4 
         AND SPLIT_PART("Last Update", ' ', 2) ~ '^\d{2}:\d{2}:\d{2}$' 
      THEN STRPTIME("Last Update", '%m/%d/%Y %H:%M:%S')

    WHEN LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) < 4 
         AND LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) <> 0 
      THEN STRPTIME("Last Update", '%m/%d/%y %H:%M')

    WHEN LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) = 4 
         AND SPLIT_PART(REGEXP_REPLACE("Last Update", ' +', ' '), ' ', 2) ~ '\d{1,2}(am|pm)' 
      THEN STRPTIME("Last Update", '%m/%d/%Y %I%p')

    WHEN LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) = 4 
         AND SPLIT_PART("Last Update", ' ', 2) ~ '^\d{1}:\d{2}:\d{2}$' 
      THEN STRPTIME("Last Update", '%m/%d/%Y %H:%M:%S')

    WHEN LENGTH(SPLIT_PART(SPLIT_PART("Last Update", ' ', 1), '/', 3)) = 0 
      THEN STRPTIME("Last Update", '%Y-%m-%d %H:%M:%S')

    ELSE NULL
  END AS DATE
) AS update_date,
        -- Extract TIME as string
        STRFTIME(
            CASE
                WHEN "Last Update" ~ '\d+/\d+/\d+ \d{1,2}:\d{2}:\d{2}' THEN STRPTIME("Last Update", '%m/%d/%Y %H:%M:%S')
                WHEN "Last Update" ~ '\d+/\d+/\d+ \d{1,2}:\d{2}' THEN STRPTIME("Last Update", '%m/%d/%Y %H:%M')
                WHEN REGEXP_REPLACE("Last Update", ' +', ' ') ~ '\d+/\d+/\d+ \d{1,2}(am|pm)' THEN STRPTIME("Last Update", '%m/%d/%Y %I%p')
                WHEN "Last Update" ~ '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' THEN STRPTIME("Last Update", '%Y-%m-%d %H:%M:%S')
                ELSE NULL
            END,
            '%H:%M:%S'
        ) AS update_time,
        
        --Used function coalesce to Convert null values to Zero
        COALESCE(confirmed, 0) AS confirmed_case,
        COALESCE(deaths, 0) AS deaths_case,
        COALESCE(recovered, 0) AS recovered_case,
        COALESCE(suspected, 0) AS suspected_case
     -- This is the table Created by Data exporter Raw_ingest_tbl
    FROM covid19.main.raw_ingest_daily_upd_tbl
),
-- Extract the max update date, this will be used for incremental loading
max_existing_date AS (
    SELECT MAX(update_date) AS max_date
    FROM parsed_data
)
-- Final table covid19.main.dbt_source_ingest_raw
SELECT *
FROM parsed_data