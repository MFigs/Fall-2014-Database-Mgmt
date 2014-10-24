-- Michael Figueiredo
-- 10/24/14
-- Database Management
-- Lab 6

-- Query 1
select c.name, c.city
from customers c
where c.city in (select city
                 from (select city, count(pid) as productCount
                       from products
                       group by city
                      ) as cityProductCountPairs
                 where productCount in (select max(productCount)
                                        from (select city, count(pid) as productCount
                                              from products
                                              group by city
                                             ) as cityProductCountPairs1
                                       )
                 limit 1									   
                );
				
-- Query 2
select c.name, c.city
from customers c
where c.city in (select city
                 from (select city, count(pid) as productCount
                       from products
                       group by city
                      ) as cityProductCountPairs
                 where productCount in (select max(productCount)
                                        from (select city, count(pid) as productCount
                                              from products
                                              group by city
                                             ) as cityProductCountPairs1
                                       )  
                );


-- Query 3
select *
from products p
where p.priceUSD > (select avg(priceUSD)
                    from products p1
                   );
			
-- Query 4
select c.name as customer_name, o.pid, o.dollars
from orders o,
     customers c
where o.cid = c.cid
order by o.dollars ASC;

-- Query 5
select c.name as customer_name, coalesce(sum(o.dollars), 0)
from customers c 
left outer join orders o
on c.cid = o.cid
group by c.cid
order by c.name;

-- Query 6
select c.name as customer_name, p.name as product_name, a.name as agent_name
from customers c,
     products p,
     agents a,
     orders o
where o.aid = a.aid
and   o.pid = p.pid
and   o.cid = c.cid
and   a.city = 'New York';

-- Query 7
select o.ordno, o.mon, o.cid, o.aid, o.pid, o.qty, o.dollars
from orders o,
     products p
where o.pid = p.pid
and   o.dollars != (p.priceUSD * o.qty);