with offer_performance as (
  select
    offer_id,
    offer_type,
    offer_channel,
    count(*) as total_offers_sent,
    {{ count_responded('transaction_status', 'Responded') }} as total_offers_responded,
    round({{ count_responded('transaction_status', 'Responded') }} * 1.0 / count(*), 2) as response_rate
  from {{ ref('fct_offer_transactions') }}
  group by offer_id, offer_type, offer_channel
)
select * from offer_performance

-- This is a rather simple model but allows the analyst to then group as
-- needed and depending on the granularity required
