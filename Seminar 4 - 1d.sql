-- Active: 1790162643151@@127.0.0.1@5432@superstore
/*

    1. Úloha

*/

WITH ranked_orders AS (
    SELECT 
        c.customer_name,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY o.customer_id 
            ORDER BY o.order_date DESC
        ) AS order_rank
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
)
SELECT 
    customer_name,
    order_id,
    order_date
FROM ranked_orders
WHERE order_rank <= 2
ORDER BY customer_name ASC, order_rank ASC;

/*

    2. Úloha

*/

WITH customer_profit AS (
    SELECT 
        c.region,
        c.customer_name,
        SUM(o.profit) AS total_profit
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.region, c.customer_name
)
SELECT 
    region,
    customer_name,
    total_profit,
    RANK() OVER (
        PARTITION BY region 
        ORDER BY total_profit DESC
    ) AS rank_result,
    DENSE_RANK() OVER (
        PARTITION BY region 
        ORDER BY total_profit DESC
    ) AS dense_rank_result
FROM customer_profit
ORDER BY region ASC, total_profit DESC, customer_name ASC;

/*

    3. Úloha

*/

WITH customer_total_sales AS (
    SELECT 
        c.customer_name,
        SUM(o.sales) AS total_sales
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_name
)
SELECT 
    customer_name,
    total_sales,
    NTILE(4) OVER (ORDER BY total_sales DESC) AS quartile
FROM customer_total_sales
ORDER BY total_sales DESC;

/*

    4. Úloha

*/

WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT 
    month,
    monthly_sales,
    LAG(monthly_sales, 1) OVER (ORDER BY month ASC) AS prev_month_sales,
    LEAD(monthly_sales, 1) OVER (ORDER BY month ASC) AS next_month_sales
FROM monthly_sales
ORDER BY month ASC;

/*

    5. Úloha

*/

WITH product_sales_cte AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(o.sales) AS product_sales
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category, p.product_name
)
SELECT 
    category,
    product_name,
    product_sales,
    SUM(product_sales) OVER (PARTITION BY category) AS category_total,
    ROUND(
        (product_sales * 100.0) / SUM(product_sales) OVER (PARTITION BY category), 
        2
    ) AS pct_of_category
FROM product_sales_cte
ORDER BY category ASC, product_sales DESC;

/*

    6. Úloha

*/

WITH customer_activity AS (
    SELECT DISTINCT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) OVER (PARTITION BY o.customer_id) AS last_order_date,
        MAX(o.order_date) OVER () AS latest_order_date
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
)
SELECT 
    customer_id,
    customer_name,
    last_order_date
FROM customer_activity
WHERE last_order_date < latest_order_date - INTERVAL '90 days'
ORDER BY last_order_date ASC;

/*

    7. Úloha

*/

WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date)::date AS month,
        SUM(sales) AS monthly_sales
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
),
sales_lag AS (
    SELECT 
        month,
        monthly_sales,
        LAG(monthly_sales, 1) OVER (ORDER BY month ASC) AS prev_month_sales
    FROM monthly_sales
),
sales_diff AS (
    SELECT 
        month,
        monthly_sales,
        prev_month_sales,
        (monthly_sales - prev_month_sales) AS sales_change,
        ROUND(
            ((monthly_sales - prev_month_sales) * 100.0) / prev_month_sales, 
            2
        ) AS growth_percentage
    FROM sales_lag
)
SELECT 
    month,
    monthly_sales,
    prev_month_sales,
    sales_change,
    growth_percentage
FROM sales_diff
ORDER BY month ASC;

/*

    8. Úloha

*/

WITH first_order AS (
    SELECT 
        customer_id,
        MIN(DATE_TRUNC('month', order_date))::date AS first_month
    FROM orders
    GROUP BY customer_id
),
returning_customers AS (
    SELECT DISTINCT f.customer_id
    FROM first_order f
    WHERE f.first_month = '2024-06-01'
      AND EXISTS (
          SELECT 1 
          FROM orders o 
          WHERE o.customer_id = f.customer_id 
            AND DATE_TRUNC('month', o.order_date) > f.first_month
      )
)
SELECT COUNT(*) AS returning_count
FROM returning_customers;