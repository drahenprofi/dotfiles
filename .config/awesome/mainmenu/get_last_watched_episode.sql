select p.url from moz_historyvisits as h 
inner join moz_places as p 
on h.place_id = p.id 
where p.url like '%hunter-x-hunter%' 
order by h.visit_date desc 
limit 1;