WITH offer_details AS (
  SELECT
    offer_id,
    offer_type,
    channel as offer_channel,
    difficulty_rank,
    duration,
    reward
  FROM {{ ref('dim_offer') }}
),

customer_transactions AS (
  SELECT
    transaction_id,
    customer_id,
    offer_id,
    transaction_status
  FROM {{ ref('fct_customer_transactions') }}
)

SELECT
  ct.customer_id,
  ct.transaction_id,
  od.offer_id,
  od.offer_type,
  od.offer_channel,
  od.difficulty_rank,
  od.duration,
  od.reward,
  ct.transaction_status,
  ft.days_since_start,
  ft.hours_since_start,
  CASE WHEN ct.transaction_status = 'Responded' THEN 1 ELSE 0 END as response_flag,
  CASE
    WHEN ft.hours_since_start <= 24 THEN 'Same Day Response'
    WHEN ft.hours_since_start <= 72 THEN 'Quick Response'
    ELSE 'Delayed Response'
  END as response_timing,
  CURRENT_TIMESTAMP as updated_at
FROM customer_transactions ct
JOIN offer_details od ON ct.offer_id = od.offer_id
JOIN {{ ref('fct_offer_transactions') }} ft ON ct.transaction_id = ft.transaction_id
  AND ct.offer_id = ft.offer_id

-- Joined the information from the offers, customers and transactions to get a better quantify the responses of the customers to the different offers
