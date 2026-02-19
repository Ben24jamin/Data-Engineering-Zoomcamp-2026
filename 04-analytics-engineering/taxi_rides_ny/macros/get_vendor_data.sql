<<<<<<< HEAD
{#
    Macro to generate vendor_name column using Jinja dictionary.

    This approach works seamlessly across BigQuery, DuckDB, Snowflake, etc.
    by generating a CASE statement at compile time.

    Usage: {{ get_vendor_data('vendor_id') }}
    Returns: SQL CASE expression that maps vendor_id to vendor_name
#}

{% macro get_vendor_data(vendor_id_column) %}

{% set vendors = {
    1: 'Creative Mobile Technologies',
    2: 'Curb Mobility, LLC',
    4: 'Unknown/Other',
    6: 'Myle Technologies Inc',
    7: 'Helix'

} %}

case {{ vendor_id_column }}
    {% for vendor_id, vendor_name in vendors.items() %}
    when {{ vendor_id }} then '{{ vendor_name }}'
    {% endfor %}
end

=======
{#
    Macro to generate vendor_name column using Jinja dictionary.

    This approach works seamlessly across BigQuery, DuckDB, Snowflake, etc.
    by generating a CASE statement at compile time.

    Usage: {{ get_vendor_data('vendor_id') }}
    Returns: SQL CASE expression that maps vendor_id to vendor_name
#}

{% macro get_vendor_data(vendor_id_column) %}

{% set vendors = {
    1: 'Creative Mobile Technologies',
    2: 'Curb Mobility, LLC',
    4: 'Unknown/Other',
    6: 'Myle Technologies Inc',
    7: 'Helix'

} %}

case {{ vendor_id_column }}
    {% for vendor_id, vendor_name in vendors.items() %}
    when {{ vendor_id }} then '{{ vendor_name }}'
    {% endfor %}
end

>>>>>>> db4a91f1addeb41ed4f65f6eb013909de54e7bbe
{% endmacro %}