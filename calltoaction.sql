#rop temporary table if exists temp_a;
   
#create temporary table temp_a (primary key (adid)) as
                select adid, adtypeid
                ,               case when coalesce(a.adurl, '') <> '' then 1 else 0 end DomainName
                ,               case when a.adurl like '%/%' then 1 else 0 end URL
                ,               case when coalesce(a.adurl, '') <> '' and a.adurl not like '%/%' then 1 else 0 end BaseDomain
                ,               case when a.adurl like '%facebook.%' then 1 else 0 end FacebookURL
                ,               case when coalesce(a.Phone, '') <> '' then 1 else 0 end Phone
                ,               case when coalesce(a.HashTag, '') <> '' then 1 else 0 end HashTag
                from ads a
                where a.statusid >= -2
                and a.adtypeid = 1;
   
    
drop temporary table temp_d;
 
create temporary table temp_d(year int, month int, adid int, numOccurences int, est_spend decimal(12,2), media_value decimal(12,2), primary key(year, month, adid));
 
insert into temp_d(year, month, adid, numOccurences, est_spend, media_value)
select year(OccurenceDateTime) year, month(OccurenceDateTime) month, o.adid, count(*) numOccurences, sum(est_spend) est_spend, sum(media_value) media_value
from adoccurence o
inner join ads a on o.adid = a.adid
where OccurenceDateTime >= '2012-10-01' and OccurenceDateTime < '2016-04-01'
and coalesce(spot_reach, 'N') = 'N'
and a.adtypeid in (1,3,4,5,6)
group by o.adid, year(OccurenceDateTime), month(OccurenceDateTime);
 
# create table _del_temp_d like temp_d;
# insert into _del_temp_d select * from temp_d;
 
select d.year, d.month, count(distinct d.adid) ads
, sum(est_spend) est_spend, sum(media_value) media_value
, sum(numOccurences) numOccurences
, sum(t.DomainName) DomainName
, sum(t.URL) URL
, sum(t.BaseDomain) BaseDomain
, sum(t.FacebookURL) FacebookURL
, sum(t.Phone) Phone
, sum(t.HashTag) HashTag
, sum(case when t.Phone = 1 and t.DomainName + t.URL + t.BaseDomain + t.FacebookURL + t.HashTag = 0 then 1 else 0 end) PhoneOnly
, sum(case when t.HashTag = 1 and t.DomainName + t.URL + t.BaseDomain + t.FacebookURL + t.Phone = 0 then 1 else 0 end) HashTagOnly
, sum(case when t.DomainName = 1 and t.HashTag + t.URL + t.FacebookURL + t.Phone = 0 then 1 else 0 end) DomainOnly
, sum(case when t.DomainName + t.URL + t.BaseDomain + t.FacebookURL + t.Phone + t.HashTag = 0 then 1 else 0 end) NoneOfAbove
# from _del_temp_d d
from temp_d d
inner join ads a on d.adid = a.adid
inner join ads pa on coalesce(a.parentadid, a.adid) = pa.adid
inner join temp_a t
                on pa.adid = t.adid
where pa.adtypeid in (1)
group by d.year, d.month;
 
 
 
 
 
select d.year, d.month, count(distinct d.adid) ads
, sum(est_spend) est_spend, sum(media_value) media_value
, sum(numOccurences) numOccurences
, sum(t.DomainName * est_spend) DomainName
, sum(t.URL * est_spend) URL
, sum(t.BaseDomain * est_spend) BaseDomain
, sum(t.FacebookURL * est_spend) FacebookURL
, sum(t.Phone * est_spend) Phone
, sum(t.HashTag * est_spend) HashTag
, sum(case when t.Phone = 1 and t.DomainName + t.URL + t.BaseDomain + t.FacebookURL + t.HashTag = 0 then 1 else 0 end * est_spend) PhoneOnly
, sum(case when t.HashTag = 1 and t.DomainName + t.URL + t.BaseDomain + t.FacebookURL + t.Phone = 0 then 1 else 0 end * est_spend) HashTagOnly
, sum(case when t.DomainName = 1 and t.HashTag + t.URL + t.FacebookURL + t.Phone = 0 then 1 else 0 end * est_spend) DomainOnly
, sum(case when t.DomainName + t.URL + t.BaseDomain + t.FacebookURL + t.Phone + t.HashTag = 0 then 1 else 0 end * est_spend) NoneOfAbove
from _del_temp_d d
# from temp_d d
inner join ads a on d.adid = a.adid
inner join ads pa on coalesce(a.parentadid, a.adid) = pa.adid
inner join temp_a t
                on pa.adid = t.adid
where pa.adtypeid in (1,3,4,5,6)
group by d.year, d.month;