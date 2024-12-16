with offer_performance as (
  select
    offer_id,
    offer_type,
    offer_channel,
    count(*) as total_offers_sent,
    sum(case when transaction_status = 'Responded' then 1 else 0 end) as total_offers_responded,
    round(sum(case when transaction_status = 'Responded' then 1 else 0 end) * 1.0 / count(*), 2) as response_rate
  from {{ ref('fact_offer_transactions') }}
  group by offer_id, offer_type, offer_channel
)
select * from offer_performance
