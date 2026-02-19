
select
    trip_id,
   COUNT(payment_type)
from {{ ref('fct_trips') }}
where payment_type  NOT IN (1,2,3,4,5)
group by trip_id
limit 100 