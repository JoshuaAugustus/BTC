-- depends_on: {{ ref('btc_usd_max')   }}

WITH WHALES AS (

select 
output_address,
sum(output_value) as total_output_value,
count(stg.*) as total_transactions

from {{ ref('stg_btc_transactions') }} stg

where output_value > 10

group by output_address
order by total_output_value desc
)

select
output_address,
total_output_value,
total_transactions,
{{convert_to_usd('total_output_value')}} as total_value_usd
from
WHALES
order by total_output_value desc