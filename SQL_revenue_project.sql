-- What is the total revenue generated?
SELECT ROUND(SUM(price * quantity),2) 
AS total_revenue
FROM orders o
JOIN products p
ON o.product_id = p.product_id; 

-- Which product category generates the most revenue?
SELECT category, ROUND(SUM(price*quantity),2) 
AS total_revenue
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY category
ORDER BY total_revenue DESC; 

-- Which cities generate the most revenue?
SELECT city, ROUND(SUM(quantity * price),2) 
AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN products p
ON o.product_id = p.product_id
GROUP BY city
ORDER BY revenue DESC; 

-- Which month has the highest revenue?
SELECT MONTH(order_date) AS order_month, 
ROUND(SUM(quantity * price),2) AS revenue
FROM orders o
JOIN products p
ON o.product_id = p.product_id
GROUP BY MONTH(order_date)
ORDER BY revenue DESC;


-- What is the average spending per customer?
WITH customer_spending AS (
	SELECT 
	c.customer_id,
	SUM(o.quantity * p.price) AS total_spent
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN products p ON o.product_id = p.product_id
	GROUP BY c.customer_id
)
SELECT 
	ROUND(AVG(total_spent),2) 
    AS avg_spent_by_customer
FROM customer_spending; 


-- Which product category sells the most units?
SELECT SUM(quantity) AS number_of_units, category
FROM orders o
JOIN products p
ON o.product_id = p.product_id 
GROUP BY category
ORDER BY SUM(quantity); 


-- What is the most common payment method?
SELECT payment_method, 
COUNT(payment_method) AS count_method
FROM orders 
GROUP BY payment_method
ORDER BY COUNT(*) DESC;


-- What is the rolling total for revenue? 
WITH Rolling_Total AS (
SELECT SUBSTRING(order_date, 1,7) AS `month`, 
ROUND(SUM(quantity*price),2) AS revenue
FROM orders o
JOIN products p 
ON o.product_id = p.product_id
GROUP BY `month`
ORDER BY `month`
)
SELECT 
`month`, 
revenue, 
SUM(revenue) OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total; 


-- Who are the top 3 highest spending customers per month?
WITH top_monthly_spenders AS 
(
SELECT c.customer_id AS id, 
SUBSTRING(order_date, 1,7) AS `month`, 
ROUND(SUM(o.quantity*p.price),2) AS revenue 
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN products p
ON o.product_id = p.product_id
GROUP BY SUBSTRING(order_date, 1,7),
c.customer_id
),
customer_rankings AS (
SELECT *,
DENSE_RANK() OVER(PARTITION BY `month` ORDER BY revenue DESC) AS rankings
FROM top_monthly_spenders
)
SELECT *
FROM customer_rankings
WHERE rankings <= 3; 


