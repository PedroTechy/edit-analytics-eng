{{
  config(
    materialized = 'table',
    )
}}

{% set surrogate_key_columns = [
    'transactions.transaction_id',
    'transactions.customer_id',
    'transactions.offer_id'
    ]
%}

with
    customers as (
        select customer_id, gender, age, income, subscribed_date
        from {{ ref('stg_profile') }}
    ),

    transactions as (
        select transaction_id, customer_id, offer_id, transaction_type
        from {{ ref('stg_transcript') }}
    ),

    final as (
        select
            {{ dbt_utils.generate_surrogate_key(surrogate_key_columns) }}
            as customer_transaction_key,
            transactions.transaction_id,
            transactions.customer_id,
            transactions.offer_id,
            customers.gender,
            customers.age,
            customers.income,
            {{ transaction_verification('transactions.transaction_type') }} as transaction_status,
            customers.subscribed_date as customer_subscribed_date,
            current_timestamp as ingested_at
        from transactions
        inner join customers on transactions.customer_id = customers.customer_id
    )

select * from final
