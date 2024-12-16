

select
  customer_id,
  case
    when gender = 'M' then 'Male'
    when gender = 'F' then 'Female'
    when gender = 'N/A' then 'Not Available'
  end as gender_segment,
  case
    when age < 18 then 'Young'
    when age < 30 then 'Young-Adult'
    when age >= 30 and age < 50 then 'Middle-aged'
    when age >= 50 then 'Senior'
  end as age_segment,
  case
    when income < 50000 then 'Low Income'
    when income >= 50000 and income < 100000 then 'Middle Income'
    when income >= 100000 then 'High Income'
  end as income_segment,
  case
    when datediff(current_date, subscribed_date) < 180 then 'New Customer'
    when datediff(current_date, subscribed_date) >= 180 and datediff(current_date, subscribed_date) < 365 then 'Recent Customer'
    when datediff(current_date, subscribed_date) >= 365 then 'Longstanding Customer'
  end as customer_tenure_segment
from {{ ref('dim_customer') }}
