-- Active: 1790162643151@@127.0.0.1@5432@datacraftinglab_db
-- Active: 1790162643151@@127.0.0.1@5432@superstore
/*

    Úloha 1

*/

with daily_sales AS(
    SELECT sale_date, SUM(total_amount) AS total_daily_sales FROM flourmills_sales
    GROUP BY sale_date
)
SELECT sale_date, total_daily_sales FROM daily_sales
WHERE total_daily_sales > 3000000
ORDER BY total_daily_sales DESC;

/*

    Úloha 2

*/

WITH category_sales AS (
    SELECT product_category, SUM(total_amount) AS total_sales FROM flourmills_sales
    GROUP BY product_category
)
SELECT product_category, total_sales FROM category_sales
ORDER BY total_sales DESC;

/*

    Úloha 3

*/

WITH product_sales AS (
    SELECT product_category,
           product_name,
           SUM(total_amount) AS total_product_sales
    FROM flourmills_sales
    GROUP BY product_category, product_name
),
ranked_products AS (
    SELECT product_category,
           product_name,
           total_product_sales,
           RANK() OVER (
               PARTITION BY product_category 
               ORDER BY total_product_sales DESC
           ) AS category_rank
    FROM product_sales
)
SELECT product_category,
       product_name,
       total_product_sales,
       category_rank
FROM ranked_products
WHERE category_rank BETWEEN 1 AND 3
ORDER BY product_category ASC, category_rank ASC;

/*

    Úloha 4

*/

WITH customer_revenue AS (
    SELECT customer_type,
           SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY customer_type
),
revenue_share AS (
    SELECT customer_type,
           revenue,
           SUM(revenue) OVER () AS total_revenue,
           ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) AS revenue_percentage
    FROM customer_revenue
)
SELECT customer_type,
       revenue,
       total_revenue,
       revenue_percentage
FROM revenue_share
ORDER BY revenue DESC;

/*

    Úloha 5

*/

WITH ranked_transactions AS (
    SELECT customer_id,
           product_name,
           sale_date,
           total_amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id 
               ORDER BY sale_date DESC
           ) AS row_num
    FROM flourmills_sales
)
SELECT customer_id,
       product_name,
       sale_date,
       total_amount
FROM ranked_transactions
WHERE row_num = 1
ORDER BY customer_id ASC;

/*

    Úloha 6

*/

WITH RECURSIVE date_range AS (
    SELECT MIN(sale_date) AS current_date_val, 
           MAX(sale_date) AS max_date_val
    FROM flourmills_sales

    UNION ALL

    SELECT (current_date_val + INTERVAL '1 day')::date, 
           max_date_val
    FROM date_range
    WHERE current_date_val < max_date_val
)
SELECT current_date_val AS sale_date
FROM date_range
ORDER BY sale_date ASC;

/*

    Úloha 7

*/

WITH RECURSIVE monthly_revenue AS (
    SELECT DATE_TRUNC('month', sale_date) AS month,
           SUM(total_amount) AS revenue
    FROM flourmills_sales
    GROUP BY DATE_TRUNC('month', sale_date)
),
ordered_months AS (
    SELECT ROW_NUMBER() OVER (ORDER BY month) AS rn,
           month,
           revenue
    FROM monthly_revenue
),
cumulative_target AS (
    SELECT rn,
           month,
           revenue,
           revenue AS cumulative_revenue
    FROM ordered_months
    WHERE rn = 1

    UNION ALL

    SELECT o.rn,
           o.month,
           o.revenue,
           c.cumulative_revenue + o.revenue AS cumulative_revenue
    FROM ordered_months o
    JOIN cumulative_target c ON o.rn = c.rn + 1
    WHERE c.cumulative_revenue < 500000000
)
SELECT rn,
       month,
       revenue,
       cumulative_revenue
FROM cumulative_target
ORDER BY rn;