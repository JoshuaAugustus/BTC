{{ config(materialized = 'ephemeral') }}

select 
* 
from {{ ref('stg_btc_outputs') }} stg
where is_coinbase = false
