-- Michael Figueiredo
-- 12/1/14
-- Database Management: Lab 10

-- Stored Procedure 1
create or replace function PreReqsFor(int, refcursor) returns refcursor as 
$$
declare
   cNum        int       := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select preReqNum
      from   prerequisites
      where  courseNum = cNum;
   return resultset;
end;
$$ 
language plpgsql;

SELECT PreReqsFor(499, 'results');
FETCH ALL FROM results;


-- Stored Procedure 2
create or replace function IsPreReqFor(int, refcursor) returns refcursor as 
$$
declare
   cNum        int       := $1;
   resultset   REFCURSOR := $2;
begin
   open resultset for 
      select courseNum
      from   prerequisites
      where  preReqNum = cNum;
   return resultset;
end;
$$ 
language plpgsql;

SELECT IsPreReqFor(120, 'results');
FETCH ALL FROM results;


-- Attempt at Optional Stored Procedure 3
--------------------------------------------------------------------------------------
--create or replace function AllPreReqsFor(int, refcursor) returns refcursor as 
--$$
--declare
--   cNum        int       := $1;
--   resultset   REFCURSOR := $2;
--begin
--   open resultset for
--      CREATE TABLE temp()
--      PreReqsFor(cNum, 'results')
--      FETCH ALL FROM 'results' INTO temp 
--    
--      select *
--      from   temp
--      where  pr.preReqNum = cNum;
--   return resultset;
--end;
--$$ 
--language plpgsql;
--
--SELECT AllPreReqsFor(499, 'results');
--FETCH ALL FROM results;