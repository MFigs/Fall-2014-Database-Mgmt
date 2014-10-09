-- Michael Figueiredo
-- 9/29/14
-- Database Management
-- Lab 4

-- Query 1
select distinct city
from agents
where aid in (select aid
              from orders
              where cid in (select cid
                            from customers
                            where name = 'Tiptop'
                           )
             );
		 
-- Query 2
select distinct pid
from orders
where aid in (select aid
              from orders
              where cid in (select cid
                            from customers
                            where city = 'Kyoto'
                           )
             )
order by pid ASC;

-- Query 3
select cid, name
from customers
where cid not in (select cid
                  from orders
                  where aid in (select aid
                                from agents
                                where aid = 'a04'
                               )
                 );
	
-- Query 4
select cid, name
from customers
where cid in (select cid
              from orders
              where pid = 'p01'
             )
and   cid in (select cid
              from orders
              where pid = 'p07'
             );
			 
-- Query 5
select distinct pid
from orders
where cid in (select cid
              from orders
              where aid = 'a04'
             )
order by pid ASC;
		 
-- Query 6
select name, discount
from customers
where cid in (select cid
              from orders
              where aid in (select aid
                            from agents
                            where city = 'Dallas'
                           )
              or aid in (select aid
                         from agents
                         where city = 'Newark'
                        )
             );
		 
-- Query 7
select *
from customers
where discount in (select discount
                   from customers
                   where city = 'Dallas'
                  )
or discount in (select discount
                from customers
                where city = 'Kyoto'
               );