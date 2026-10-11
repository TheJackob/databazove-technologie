-- Active: 1790162643151@@127.0.0.1@5432@retail_sales
/*

    Úloha 1

*/

CREATE VIEW high_value_customers AS
SELECT o.customer_id, c.customer_name, SUM(o.sales) AS "total_sales" FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name
HAVING SUM(o.sales) > 2000;

SELECT * FROM high_value_customers;

/*

    Úloha 2

*/

CREATE VIEW regional_monthly_sales AS
SELECT 
    c.region,
    DATE_TRUNC('month', o.order_date) AS "month",
    SUM(o.sales) AS "monthly_sales"
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY DATE_TRUNC('month', o.order_date), c.region

SELECT * FROM regional_monthly_sales
WHERE region = 'West';

/*

    Úloha 3

*/

CREATE VIEW analyst_orders AS
SELECT order_id, customer_id, product_id, sales, quantity, discount FROM orders;

SELECT * FROM analyst_orders;

/*

    Úloha 4

*/

CREATE INDEX idx_orders_customer_id ON orders(customer_id);
SELECT * FROM orders
WHERE customer_id = 'C001';

/*

    Úloha 5

*/

CREATE INDEX idx_orders_order_date ON orders(order_date);

SELECT DATE_TRUNC('month', order_date) AS month, SUM(sales) FROM orders
GROUP BY month
ORDER BY month ASC;

/*

    Úloha 6

*/

CREATE INDEX idx_orders_region_category ON orders(customer_id, order_date);

SELECT c.customer_name, o.profit FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
WHERE c.region = 'West' AND o.order_date > '2024-01-01';

/*

    Úloha 7

*/

EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 'C001';

/*

    Príprava databázy retail_sales

*/

CREATE DATABASE retail_sales;

CREATE TABLE orders(
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    region VARCHAR(20) NOT NULL,
    category VARCHAR(50) NOT NULL,
    ship_mode VARCHAR(30) NOT NULL,
    sales NUMERIC(10,2) NOT NULL,
    profit NUMERIC(10,2) NOT NULL
);

ALTER DATABASE retail_sales SET datestyle TO 'ISO, MDY';

SELECT * FROM orders;

/*

    Úloha 8

*/

CREATE PROCEDURE get_customer_sales(p_customer_id VARCHAR(20))
LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_total_sales NUMERIC(10,2);
BEGIN
    SELECT SUM(sales) INTO v_total_sales FROM orders
    WHERE customer_id = p_customer_id;

    RAISE NOTICE 'Zákazník % má celkový predaj: %', p_customer_id, v_total_sales;
END
$procedure$;

CALL get_customer_sales('C001');

/*

    Úloha 9

*/

CREATE PROCEDURE apply_regional_discount(
    p_region_name VARCHAR(20),
    p_discount_rate NUMERIC(4,2)
)
LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE orders SET sales = sales * (1-p_discount_rate)
    WHERE region = p_region_name;

    RAISE NOTICE 'Zľava % bola úspešne aplikovaná pre región %', p_discount_rate, p_region_name;
END
$procedure$;

CALL apply_regional_discount('West', 0.10);

/*

    Úloha 10

*/

CREATE PROCEDURE get_sales_between(
    start_date DATE,
    end_date DATE
)
LANGUAGE plpgsql

AS $procedure$
DECLARE
    v_total_sales NUMERIC(10, 2);
BEGIN
    SELECT SUM(sales) INTO v_total_sales FROM orders
    WHERE order_date BETWEEN start_date AND end_date;

    RAISE NOTICE 'Celkový predaj od % do % je: %', start_date, end_date, v_total_sales;
END
$procedure$;

CALL get_sales_between('2024-01-01', '2024-03-31');