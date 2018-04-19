-- below is for availableat app study
select * from products
limit 10 -- look at available products

select * from productcategories
where categoryname = 'Mobile Application' -- look at category Mobile Application
limit 10

select * from products
where ProdName = 'App' -- look at product name 'app'

select * from availableat
limit 10 -- this is where the call to action info resides

select avl.advertiserid
, count(*)
,avl.*
, adv.name from availableat avl 
join advertisers adv on avl.advertiserid = adv.advertiserid  
group by avl.advertiserid 
order by count(*) desc;
-- number of advertisers ytd that have a call to action to download a mobile app

select
count(distinct adv.name )-- 5693 
from advertisers adv
join ads on ads.advertiserid = adv.advertiserid
join adoccurence ao on ao.adid = ads.adid
where ao.occurencedatetime >= '2015-01-01 00:00:00'


-- number of advertisers with app call to action ytd (2.8 or 3 percent of total ytd) 491731... 491955 when joining to industry
select adv.name as name1
,avl.adid
,adv.*
,ao.*
,ads.*
,adv2.name as name2
,c.name as industry
-- ,count(distinct adv2.name) as ctdName -- 161
from advertisers adv
join availableat avl on avl.advertiserid = adv.advertiserid
join adoccurence ao on ao.adid = avl.adid
join ads on ao.adid = ads.adid
join advertisers adv2 on ads.advertiserid = adv2.advertiserid
join advertisercategories ac on adv2.advertiserid = ac.advertiserid
join categories c on ac.categoryid = c.categoryid
where adv.name in ( 'Google Play', 'App Store', 'Windows Store', 'Android Market') -- app store, google play, windows store, android market
and ao.occurencedatetime >= '2015-01-01 00:00:00'
and ac.isprimary = 1
