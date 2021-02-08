USE publications;

select title_id, qty  from sales
group by title_id;

-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
-- 1 a) advance for each author

select t.title_id, a.au_id, a.au_fname, a.au_lname, ta.royaltyper, t.advance, t.advance * ta.royaltyper / 100 as advance
from authors a
right join titleauthor ta on ta.au_id = a.au_id
left join titles t on ta.title_id = t.title_id;

-- 1 b) royalties for each author

select t.title_id,
a.au_id,
a.au_fname,
a.au_lname,
ta.royaltyper,
s.qty,
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as sales_royalty,
t.advance * ta.royaltyper / 100 as advance
from authors a
right join titleauthor ta on ta.au_id = a.au_id
left join titles t on ta.title_id = t.title_id
left join sales s on s.title_id = t.title_id;

-- 2 Aggregate the total royalties for each title and author

select title_id, au_id, advance, sum(sales_royalty) as sum_sales_royalty
from (
select t.title_id,
a.au_id,
a.au_fname,
a.au_lname,
ta.royaltyper,
s.qty,
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as sales_royalty,
t.advance * ta.royaltyper / 100 as advance
from authors a
right join titleauthor ta on ta.au_id = a.au_id
left join titles t on ta.title_id = t.title_id
left join sales s on s.title_id = t.title_id) as total_royalties
group by title_id, au_id;

-- 3 Step 3: Calculate the total profits of each author

select au_id, sum(sum_sales_royalty) + advance AS total_royalties
from
(select title_id, au_id, advance, sum(sales_royalty) as sum_sales_royalty
from (
select t.title_id,
a.au_id,
a.au_fname,
a.au_lname,
ta.royaltyper,
s.qty,
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as sales_royalty,
t.advance * ta.royaltyper / 100 as advance
from authors a
right join titleauthor ta on ta.au_id = a.au_id
left join titles t on ta.title_id = t.title_id
left join sales s on s.title_id = t.title_id) as total_royalties
group by title_id, au_id) as roy_au_tit
group by au_id;

-- Challenge 2 same solution, but in temporary tables

-- temporary table 1

Create temporary table table1
select t.title_id,
a.au_id,
a.au_fname,
a.au_lname,
ta.royaltyper,
s.qty,
t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 as sales_royalty,
t.advance * ta.royaltyper / 100 as advance
from authors a
right join titleauthor ta on ta.au_id = a.au_id
left join titles t on ta.title_id = t.title_id
left join sales s on s.title_id = t.title_id;


-- temporary table 2
Create temporary table table2
select title_id, au_id, advance, sum(sales_royalty) as sum_sales_royalty
from table1
group by title_id, au_id;

select * from table2;

-- call both temporary tables by their names in the last query
select au_id, sum(sum_sales_royalty) + advance AS total_royalties
from table2
group by au_id;

-- 3 create table 

Create table Most_profiting_authors
as (select au_id, sum(sum_sales_royalty) + advance AS total_royalties
from table2
group by au_id)
order by total_royalties desc
limit 5;

select * from Most_profiting_authors;

-- documentation temprary tables
-- https://www.mysqltutorial.org/mysql-temporary-table/