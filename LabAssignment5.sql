-- Michael Figueiredo
-- 10/10/14
-- Database Management
-- Lab 5

-- Query 1
select distinct a.city
from agents a, 
     orders o, 
	 customers c
where a.aid = o.aid
and o.cid = c.cid
and c.name = 'Tiptop'
order by a.city ASC;


-- Query 2
select distinct o1.pid
from agents a, 
     orders o, 
	 orders o1, 
	 customers c
where o.aid  = a.aid
and   o1.aid = a.aid
and   o.cid  = c.cid
and   c.city = 'Kyoto'
order by o1.pid ASC;

-- Query 3
select name
from customers
where cid not in (select cid
                  from orders
                 );
				 
				 
-- Query 4
select c.name
from customers c left outer join orders o
on c.cid = o.cid
where o.ordno is null;


-- Query 5
select distinct c.name as cust_Name, a.name as agent_Name
from customers c,
     orders o,
     agents a
where o.cid = c.cid
and   o.aid = a.aid
and   c.city = a.city;


-- Query 6
select c.name as customer_name, a.name as agent_name, c.city as City
from customers c,
     agents a
where c.city = a.city;


-- Query 7
select c.name, c.city
from customers c
where c.city in (select city
                 from (select city, count(pid) as productCount
                       from products
                       group by city
                      ) as cityProductCountPairs
                 where productCount in (select min(productCount)
                                        from (select city, count(pid) as productCount
                                              from products
                                              group by city
                                             ) as cityProductCountPairs1
                                       )  
                ); 