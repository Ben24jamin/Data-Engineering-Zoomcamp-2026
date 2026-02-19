<<<<<<< HEAD
{% macro safe_cast(column, data_type) %}
    {% if target.type == 'bigquery' %}
        safe_cast({{ column }} as {{ data_type }})
    {% else %}
        cast({{ column }} as {{ data_type }})
    {% endif %}
=======
{% macro safe_cast(column, data_type) %}
    {% if target.type == 'bigquery' %}
        safe_cast({{ column }} as {{ data_type }})
    {% else %}
        cast({{ column }} as {{ data_type }})
    {% endif %}
>>>>>>> db4a91f1addeb41ed4f65f6eb013909de54e7bbe
{% endmacro %}