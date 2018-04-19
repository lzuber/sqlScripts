/* T-Mobile Call Data by State */
    select
    (cl.start_time at time zone 'America/Los_Angeles')::date calldate,
--    cl.source_system,
--    cust.name client_name,
--    cust2.name account_name,
--    cont.name revenue_campaign_name,
    coalesce(p.publisher_channel, 'UNKNOWN') publisher_channel,
--    coalesce(p.name, 'UNKNOWN') publisher_name,
    c.state state_code,
--    c.name city_name,
caller_phone_number,
customer_conversion,

    sum(1) all_total_calls,
    sum(case when (cl.ivr_extension='1' and cl.publisher_id != 73994) OR (cl.ivr_extension='2' and cl.publisher_id = 73994) then 1 else 0 end) all_telesales_calls,
    sum(coalesce(billable::int,0)) all_billable_calls,
    sum(coalesce(revenue,0)) all_revenue

    from
    fortknox.call_leg cl
    join fortknox.publisher p on cl.publisher_id = p.publisher_id
    join fortknox.customer_closure cc on cl.advertiser_id = cc.child_customer_id
    join fortknox.customer_closure cc2 on cc.parent_customer_id = cc2.child_customer_id
    join fortknox.customer cust on cc2.parent_customer_id = cust.customer_id
    join fortknox.customer cust2 on cc2.child_customer_id = cust2.customer_id
    join fortknox.customer_contract cont on cl.customer_contract_id = cont.customer_contract_id
    join fortknox.city c on cl.city_id = c.city_id

    where
    cl.start_time >= '2014-10-01'::timestamp at time zone 'America/Los_Angeles'
    and cl.start_time < '2015-01-01'::timestamp at time zone 'America/Los_Angeles'
    and (cc2.parent_customer_id = 327128 OR  --T-Mobile MCM Client account
         cc2.parent_customer_id = 733030 OR  --T-Mobile Corp MCA parent account
         cc2.parent_customer_id = 736902 AND cc.child_customer_id = 736903)  --Optimedia MCA account T-Mobile child data only
    and cc2.distance = 1
    and cl.source_system = 'DCM'

    group by
--    (cl.start_time at time zone 'America/Los_Angeles')::date,
--    cl.source_system,
--    cust.name,
--    cust2.name,
--    cont.name,
    p.publisher_channel,
--    p.name,
    c.state
--    c.name
,cl.caller_phone_number
,(cl.start_time at time zone 'America/Los_Angeles')::date
,customer_conversion