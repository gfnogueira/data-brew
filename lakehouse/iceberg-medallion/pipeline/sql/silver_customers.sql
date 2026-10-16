select
  customer_id,
  trim(name)                           as name,
  lower(segment)                       as segment,
  cast(signup_date as date)            as signup_date
from src
where customer_id is not null
