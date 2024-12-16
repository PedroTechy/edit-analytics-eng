with offers as (
  select
    offer_id,
    offer_type,
    channel as offer_channel
  from {{ ref('dim_offer') }}
),
transactions as (
  select
    customer_transaction_key,
    customer_id,
    offer_id,
    transaction_status
  from {{ ref('fact_customer_transactions') }}
)
select
  transactions.customer_id,
  offers.offer_id,
  offers.offer_type,
  offers.offer_channel,
  case when transactions.transaction_status = 'Responded' then 1 else 0 end as response_flag,
  current_timestamp as response_timestamp
from transactions
join offers on transactions.offer_id = offers.offer_id
