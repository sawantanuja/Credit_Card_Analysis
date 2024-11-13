/*	Credit Card Transaction Analysis */

/* Q1:What is the average transaction amount for each gender?*/

SELECT gender, AVG(amount) AS Average_Transaction_Amount
FROM credit_card_transcations
GROUP BY gender;



/* Q2: How many transactions occurred for each expenditure type? */

SELECT exp_type, COUNT(transaction_id) AS Transaction_Count
FROM credit_card_transcations
GROUP BY exp_type;


/* Q3:How many transactions were made each day?*/

SELECT transaction_date, COUNT(transaction_id) AS Transaction_Count
FROM credit_card_transcations
GROUP BY transaction_date
ORDER BY transaction_date;



/* Q4: What is the average transaction amount for each city? */

SELECT city, AVG(amount) AS Average_Transaction_Amount
FROM credit_card_transcations
GROUP BY city
ORDER BY Average_Transaction_Amount DESC;


/* Q5: Write a querytop 5 cities with highest spends and their percentage contribution of total credit card spends*/

with cte1 as (	
select city,sum(amount) as total_spend from credit_card_transcations
group by city)
,total_spend as (select sum(cast(amount as bigint)) as total_amount from credit_card_transcations)
select top 5 cte1.*,total_spend*1.0/ total_amount*100 as percentage_contributution from cte1, total_spend
order by total_spend desc



/* Q6: write a query to print highest spend month and amount spent in that month for each card type*/

with cte as (
select card_type, MONTH(transaction_date) as month,
YEAR(transaction_date) as year,SUM(amount) as amt_spent from credit_card_transcations
group by card_type, MONTH(transaction_date),YEAR(transaction_date)
--order by card_type,amt_spent desc
)
select * from (select *, rank() over(partition by card_type order by amt_spent desc) as rn from cte) a where rn=1


/* Q7: write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type) */

with cum_sum as(
select *, sum(amount) over(partition by card_type order by transaction_date,transaction_id) as cumulative_total
from credit_card_transcations)
select * from (select  *,RANK() over(partition by card_type order by cumulative_total) as rn  from cum_sum where cumulative_total >= 1000000) 
a where rn=1


/* Q8: write a query to find city which had lowest percentage spend for gold card type */

with cte as (
select city,card_type,sum(amount) as total 
,sum(case when card_type='Gold' then amount end) as gold_amount
from credit_card_transcations
group by city,card_type)
select 
top 1 city,sum(gold_amount)*1.0/sum(total) as gold_ratio from cte
group by city
having sum(gold_amount) is not null
order by gold_ratio


/* Q9: write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)*/

with cte as (
select city,exp_type,sum(amount) as total from credit_card_transcations
group by city,exp_type)
select 
city,max( case when rn_asc=1 then exp_type end) as lowest_exp_type
,min(case when rn_desc=1 then exp_type end) as highest_exp_type
from 
(select *
,rank() over(partition by city order by total desc) rn_desc
,rank() over(partition by city order by total asc) rn_asc
from cte) A
group by city

/* Q10: write a query to find percentage contribution of spends by females for each expense type */

select exp_type,
sum(case when gender ='F' then amount else 0 end)*1.0/sum(amount) as female_contribution
from credit_card_transcations
group by exp_type
order by female_contribution desc



/* Q11:during weekends which city has highest total spend to total no of transcations ratio*/

select top 1 city,sum(amount)*1.0/count(1) as ratio  from credit_card_transcations 
where datepart(weekday,transaction_date) in (1,7)
group by city
order by ratio desc

/* Q12:which city took least number of days to reach its 500th transaction after the first transaction in that city*/

with cte as (
select *
,ROW_NUMBER() over(partition by city order by transaction_date,transaction_id) as rn 
from credit_card_transcations)
select top 1  city,datediff(day,min(transaction_date),max(transaction_date)) as date_diff
from cte 
where rn=1 or rn=500
group by city
having count(1)=2 ---if city has 1 transaction it will not work
order by date_diff 
