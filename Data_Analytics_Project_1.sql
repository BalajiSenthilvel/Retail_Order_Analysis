--

CREATE TABLE df_orders
(
[order_id] int primary key,
[order_date] date,
[ship_mode] varchar(20),
[segment] varchar(20),
[country] varchar(20),
[city] varchar(20),
[state] varchar(20),
[postal_code] int,
[region] varchar(20),
[category] varchar(20),
[sub_category] varchar(20),
[product_id] varchar(20),
[cost_price] int,
[quantity] int,
[discount] decimal(7,2),
[sales_price] decimal(7,2),
[profit] decimal(7,2)
)

--Data Analysis of Retail_Orders

USE practise
select distinct year(order_date)  from df_orders;

--find top 10 highest reveue generating products 
select top 10 product_id, sum(sales_price) AS Highest_Revenue
from df_orders
group by product_id
order by Highest_Revenue desc;


--find top 5 highest selling products in each region

with cte as
(
select region, product_id, sum(sales_price) AS Sales
from df_orders
group by product_id, region
--order by region,sales desc
)
select * 
from
(select *, row_number() over (partition by region order by sales desc) as rn
from cte) a
where rn<=5;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

with cte as
( select year(order_date) as order_year, month(order_date) as order_month, sum(sales_price) AS Sales
from df_orders
group by year(order_date), month(order_date) )
select *, round(sales_2023*0.01/Sales_2022,4) AS YOY_Growth
from(
select order_month,
sum(case when order_year ='2022' then sales else 0 end) as Sales_2022,
sum(case when order_year ='2023' then sales else 0 end) as Sales_2023
from cte
group by order_month
)a;

--for each category which month had highest sales 
with cte as
( select category,format(order_date,'yyyy-MM') AS Order_yr_mm,sum(sales_price) AS Sales
from df_orders
group by category,format(order_date,'yyyy-MM') ) 
select * from (select *, ROW_NUMBER() over (partition by category order by sales desc) as rn
from cte)a
where rn =1;

--which sub category had highest growth by profit in 2023 compare to 2022

with cte as
(select sub_category,year(order_date) as order_year, sum(sales_price) AS Sales
from df_orders
group by sub_category,year(order_date)),
cte2 as
(Select sub_category,
sum(case when order_year ='2022' then sales else 0 end) as Sales_2022,
sum(case when order_year ='2023' then sales else 0 end) as Sales_2023
from cte
group by sub_category)
select top 1*,(Sales_2023- Sales_2022)*100/ Sales_2022 as YOY
from cte2
order by YOY desc;




