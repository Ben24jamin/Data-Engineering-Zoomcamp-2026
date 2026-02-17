{% macro get_ratecode_type(ratecode_id_column) %}

{% set ratecodes = {
    1: 'Standard rate',
    2: 'JFK',
    3: 'Newark',
    4: 'Nassau or Westchester',
    5: 'Negotiated fare',
    6: 'Group ride',
    99: 'NULL/unknown'
} %}

case {{ ratecode_id_column }}
    {% for rate_code_id, ratecode_description in ratecodes.items() %}
    when {{ rate_code_id }} then '{{ ratecode_description }}'
    {% endfor %}
    else 'Unknown'  -- Optional: handle any unexpected values
end as rate_code_type  -- This will name the output column

{% endmacro %}