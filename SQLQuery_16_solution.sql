SELECT *
from credit_card_transcations;

SELECT top 5
    *
from credit_card_transcations;


SELECT MIN(transaction_date) , MAX(transaction_date)
from credit_card_transcations;
-- '2013-10-04'	'2015-05-26'
SELECT distinct card_type
from credit_card_transcations;
-- Silver Signature Gold Platinum

SELECT distinct exp_type
FROM credit_card_transcations;
-- Entertainment Food Bills Fuel Travel Grocery
SELECT distinct gender
from credit_card_transcations;
-- F M

--1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends 

with
    cte
    as
    (
        SELECT city, SUM(amount) as total_spend
        from credit_card_transcations
        GROUP by city
    ),
    total_spend
    as
    
    (
        select sum(CAST(amount as bigint) ) as total_amount
        from credit_card_transcations
    )
SELECT top 5
    *, CAST(100.0 * total_spend  / (select total_amount
    from total_spend) as decimal(10,2)) as percentage_contribution
from cte
ORDER BY total_spend desc


-- 2- write a query to print highest spend month and amount spent in that month for each card type

with cte as (
SELECT card_type,DATEPART(YEAR, transaction_date) as yt , DATEPART(MONTH,transaction_date) as mt , SUM(amount) as total_spend
from credit_card_transcations
GROUP BY card_type,DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)

)

select * from (select * , RANK() OVER (partition by card_type order by total_spend desc) as rn from cte ) a where rn =1;


-- 3- write a query to print the transaction details(all columns from the table) for each card type when
-- it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)


with cte as (
SELECT *, SUM(amount) OVER(partition by card_type order by transaction_date , transaction_id asc) as total_spend
from credit_card_transcations
)
SELECT * from( select * , RANK() over( partition by card_type ORDER BY transaction_date , transaction_id asc) as rn from cte where total_spend >= 1000000) a
 where rn =1;

 -- 4- write a query to find city which had lowest percentage spend for gold card type

 select top 1 city from credit_card_transcations where card_type = 'Gold' GROUP BY city ORDER BY SUM(amount) ASC

 -- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

 SELECT distinct exp_type from credit_card_transcations;

 
 with cte as (
    SELECT city, exp_type, sum(amount) as total_amount from credit_card_transcations GROUP BY city, exp_type
 )

 SELECT city, MAX( case when rn_asc = 1 then exp_type end) as lowest_exp_type, MIN(case when rn_desc =1 then exp_type end) as highest_exp_type from
  (SELECT * ,
  RANK() OVER( partition by city order by  total_amount desc) as rn_desc,
  RANK() OVER (partition by city order by total_amount asc) as rn_asc
from cte 
) a group by city;