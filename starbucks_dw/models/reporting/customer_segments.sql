
-- The params here defined are not rules, but values defenied based on "common sense" for this use case.

-- 1. Enhanced customer_segments model
WITH customer_response_behavior AS (
  SELECT
    customer_id,
    COUNT(DISTINCT transaction_id) as total_transactions,
    SUM(CASE WHEN transaction_status = 'Responded' THEN 1 ELSE 0 END) as total_responses
  FROM {{ ref('fct_customer_transactions') }}
  GROUP BY customer_id
)

SELECT
  c.customer_id,
  -- demographic segments
  CASE
    WHEN c.gender = 'M' then 'Male'
    WHEN c.gender = 'F' then 'Female'
    ELSE 'Not Available'
  END as gender_segment,
  CASE
    WHEN c.age < 18 THEN 'Young'
    WHEN c.age < 30 THEN 'Young-Adult'
    WHEN c.age >= 30 AND c.age < 50 THEN 'Middle-aged'
    WHEN c.age >= 50 THEN 'Senior'
  END as age_segment,
  CASE
    WHEN c.income < 50000 THEN 'Low Income'
    WHEN c.income >= 50000 AND c.income < 100000 THEN 'Middle Income'
    WHEN c.income >= 100000 THEN 'High Income'
  END as income_segment,
  -- engagement segments
  CASE
    WHEN CURRENT_DATE - c.subscribed_date < 180 THEN 'New Customer'
    WHEN CURRENT_DATE - c.subscribed_date < 365 THEN 'Recent Customer'
    ELSE 'Longstanding Customer'
  END as customer_tenure_segment,
  CASE
    WHEN crb.total_transactions >= 10 THEN 'High Activity'
    WHEN crb.total_transactions >= 5 THEN 'Medium Activity'
    ELSE 'Low Activity'
  END as activity_segment,
  crb.total_transactions,
  crb.total_responses,
  c.subscribed_date,
  CURRENT_TIMESTAMP as updated_at
FROM {{ ref('dim_customer') }} c
LEFT JOIN customer_response_behavior crb ON c.customer_id = crb.customer_id

-- with the gender, age, income as well as the engagement segments the analyst is able to better understand the customers habits and when combining the information here present
-- with the information on customer_responses can understand which are more likely to respond to promotional offers
