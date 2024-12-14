{{
  config(
    materialized = 'table',
    )
}}

{% set surrogate_key_columns = [
    'transactions.offer_id',
    'transactions.transaction_id',
    'offers.channel'
    ]
%}

with
    offers as (
        select offer_id, offer_type, channel, difficulty_rank, duration
        from {{ ref('dim_offer') }}
    ),

    transactions as (
        select
            transaction_id,
            offer_id,
            transaction_type,
            reward,
            hours_since_start,
            days_since_start
        from {{ ref('stg_transcript') }}
    ),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(surrogate_key_columns) }}
            as offer_transaction_key,
            transactions.offer_id,
            transactions.transaction_id,
            offers.offer_type,
            offers.channel as offer_channel,
            offers.difficulty_rank as offer_difficulty_rank,
            offers.duration as offer_duration,
            transactions.reward as offer_reward,
            {{ transaction_verification('transactions.transaction_type') }} as transaction_status,
            transactions.hours_since_start,
            transactions.days_since_start,
            current_timestamp as ingested_at
        from transactions
        inner join offers on transactions.offer_id = offers.offer_id
    )

select *
from final
