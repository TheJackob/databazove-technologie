-- Active: 1790162643151@@127.0.0.1@5432@retail
/*

    1. Úloha

*/

CREATE DATABASE RETAIL;

CREATE TABLE retail_sales(
    invoice_no VARCHAR(20),
    stock_code VARCHAR(50),
    description TEXT,
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price NUMERIC(10,2),
    customer_id INT,
    country VARCHAR(100)
);

SELECT * FROM retail_sales;

/*

    2. Úloha

*/

SELECT
    customer_id,
    invoice_no,
    invoice_date,
    quantity,
    unit_price,
    (quantity * unit_price) AS revenue,
    SUM(quantity * unit_price) OVER(
        PARTITION BY customer_id
        ORDER BY invoice_date
        RANGE BETWEEN INTERVAL '14 days' PRECEDING AND CURRENT ROW
    ) AS revenue_last_14_days
FROM retail_sales
WHERE customer_id IS NOT NULL
ORDER BY customer_id, invoice_date;

/*

    3. Úloha

*/

SELECT
    stock_code,
    country,
    invoice_date,
    quantity,
    ROUND(
        AVG(quantity) OVER(
            PARTITION BY stock_code, country
            ORDER BY invoice_date
            RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
        ),2
    ) AS avg_quantity_7_days
FROM retail_sales
WHERE quantity > 1
ORDER BY stock_code, country, invoice_date;

/*

    4. Úloha

*/

SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    next_invoice_date,
    (next_invoice_date::DATE - invoice_date::DATE) AS days_to_next_invoice
FROM (
    SELECT 
        customer_id,
        invoice_no,
        MIN(invoice_date) AS invoice_date,
        LEAD(MIN(invoice_date), 1) OVER (
            PARTITION BY customer_id
            ORDER BY MIN(invoice_date)
        ) AS next_invoice_date
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_no
) AS sub
WHERE next_invoice_date IS NOT NULL
ORDER BY days_to_next_invoice DESC;

/*

    5. Úloha

*/

SELECT 
    stock_code,
    invoice_no,
    invoice_date,
    previous_price,
    current_price,
    price_difference
FROM (
    SELECT 
        stock_code,
        invoice_no,
        invoice_date,
        LAG(unit_price, 1) OVER (
            PARTITION BY stock_code 
            ORDER BY invoice_date
        ) AS previous_price,
        unit_price AS current_price,
        (unit_price - LAG(unit_price, 1) OVER (
            PARTITION BY stock_code 
            ORDER BY invoice_date
        )) AS price_difference
    FROM retail_sales
) AS sub
WHERE previous_price IS NOT NULL 
  AND price_difference != 0
ORDER BY invoice_date ASC;

/*

    6. Úloha

*/

WITH customer_sales AS (
    SELECT 
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_amount,
    NTILE(4) OVER (ORDER BY total_amount DESC) AS sales_quartile
FROM customer_sales
ORDER BY total_amount DESC;

/*

    7. Úloha

*/

WITH monthly_country_sales AS (
    SELECT 
        country,
        DATE_TRUNC('month', invoice_date)::date AS sales_month,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    GROUP BY country, sales_month
)
SELECT 
    country,
    sales_month AS mesiac,
    total_amount,
    NTILE(4) OVER (
        PARTITION BY country 
        ORDER BY total_amount DESC
    ) AS sales_quartile
FROM monthly_country_sales
ORDER BY country ASC, sales_month ASC;

/*

    8. Úloha

*/

WITH ranked_sales AS (
    SELECT 
        customer_id,
        invoice_no,
        invoice_date,
        stock_code,
        description,
        quantity,
        unit_price,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY invoice_date ASC
        ) AS rn
    FROM retail_sales
)
SELECT 
    customer_id,
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price
FROM ranked_sales
WHERE rn = 1
ORDER BY customer_id ASC;

/*

    9. Úloha

*/

WITH ranked_items AS (
    SELECT 
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        (quantity * unit_price) AS amount,
        ROW_NUMBER() OVER (
            PARTITION BY invoice_no 
            ORDER BY (quantity * unit_price) DESC
        ) AS row_num
    FROM retail_sales
)
SELECT 
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    amount,
    row_num
FROM ranked_items
WHERE row_num <= 3
ORDER BY invoice_no ASC, row_num ASC;

/*

    10. Úloha

*/

WITH customer_monthly_sales AS (
    SELECT 
        country,
        DATE_TRUNC('month', invoice_date)::date AS mesiac,
        customer_id,
        SUM(quantity * unit_price) AS total_amount
    FROM retail_sales
    WHERE customer_id IS NOT NULL
    GROUP BY country, mesiac, customer_id
),
ranked_customers AS (
    SELECT 
        country,
        mesiac,
        customer_id,
        total_amount,
        DENSE_RANK() OVER (
            PARTITION BY country, mesiac 
            ORDER BY total_amount DESC
        ) AS sales_rank
    FROM customer_monthly_sales
)
SELECT 
    country,
    mesiac,
    customer_id,
    total_amount,
    sales_rank
FROM ranked_customers
WHERE sales_rank <= 5
ORDER BY country ASC, mesiac ASC, sales_rank ASC, customer_id ASC;

/*

    11. Úloha

*/

WITH ranked_prices AS (
    SELECT 
        invoice_no,
        stock_code,
        description,
        quantity,
        unit_price,
        DENSE_RANK() OVER (
            PARTITION BY invoice_no 
            ORDER BY unit_price DESC
        ) AS price_rank
    FROM retail_sales
)
SELECT 
    invoice_no,
    stock_code,
    description,
    quantity,
    unit_price,
    price_rank
FROM ranked_prices
WHERE price_rank <= 5
ORDER BY invoice_no ASC, price_rank ASC, stock_code ASC;