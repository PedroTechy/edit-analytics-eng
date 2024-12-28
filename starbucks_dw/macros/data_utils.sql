{% macro get_days_from_hours(hour) %}
    case when {{ hour }} < 24 then 0 else {{ hour }} / 24 end
{% endmacro %}


{% macro transaction_verification(transaction_type) %}

    {% set transaction_map = {
        "offer received": "received",
        "offer viewed": "viewed",
        "offer completed": "completed",
        "transaction": "transaction"
    } %}

    case
        {% for key, value in transaction_map.items() %}
            when {{ transaction_type }} = '{{ key }}' then '{{ value }}'
        {% endfor %}
    end
{% endmacro %}

{% macro count_responded(transaction_status_column, responded_value) %}
    sum(case when {{ transaction_status_column }} = '{{ responded_value }}' then 1 else 0 end)
{% endmacro %}
