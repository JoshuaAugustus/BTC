{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'append'
  )
}}

with flattened as (

select 
stg.hashkey,
stg.block_number,
stg.block_timestamp,
stg.is_coinbase,
f.value:address::string as output_address,
f.value:value::float as output_value

from {{ ref('stg_btc') }} stg,
LATERAL FLATTEN(input => outputs) f
where f.value:address is not null

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records whose timestamp occurred since the last run of this model)
  -- (If event_time is NULL or the table is truncated, the condition will always be true and load all records)
and stg.BLOCK_TIMESTAMP >= (select max(BLOCK_TIMESTAMP) from {{ this }} )

{% endif %}

)

select
hashkey,
block_number,
block_timestamp,
is_coinbase,
output_address,
output_value
from flattened
