-- Active: 1790162643151@@127.0.0.1@5432@superstore
CREATE DATABASE db;

CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE employees(
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100)
);

CREATE TABLE projects(
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    employee_id INT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

SELECT * FROM projects;

CREATE DATABASE superstore;

CREATE TABLE customers(
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    region VARCHAR(50)
);

CREATE TABLE products(
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(100)
);

CREATE TABLE orders(
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    product_id VARCHAR(20),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    order_date DATE,
    ship_date DATE,
    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(10,2),
    profit NUMERIC(10,2)
);

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;

/*

    2. Úloha

*/

SELECT o.order_id, c.customer_name, o.sales FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE sales > 500
ORDER BY sales DESC;

/*

    3. Úloha

*/

SELECT o.order_id, c.customer_name, p.category, o.sales FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
INNER JOIN products p on p.product_id = o.product_id;

/*

    4. Úloha

*/

SELECT c.region, SUM(o.sales) FROM orders o
RIGHT JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region;

/*

    5. Úloha

*/

SELECT p.product_name, SUM(o.sales) FROM orders o
RIGHT JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id;

/*

    6. Úloha

*/

SELECT c.customer_name, o.order_id, o.sales FROM orders o
FULL OUTER JOIN customers c ON c.customer_id = o.customer_id;

/*

    7. Úloha

*/

SELECT c.region, SUM(o.sales) FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region;

/*

    8. Úloha

*/

SELECT c.customer_name, COUNT(o.order_id) AS "Count" FROM orders o
RIGHT JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

/*

    9. Úloha

*/

SELECT p.category, AVG(o.discount) FROM orders o
INNER JOIN products p ON p.product_id = o.product_id
GROUP BY p.category;

/*

    10. Úloha

*/

SELECT c.customer_name, SUM(o.sales) FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id HAVING SUM(o.sales) > 2000;

/*

    11. Úloha

*/

SELECT c.region, SUM(o.sales), AVG(o.discount), COUNT(o.order_id) FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region;

/*

    12. Úloha

*/

SELECT
    c.region,
    COUNT(CASE WHEN o.sales > 1000 THEN 1 END) AS "high-value",
    COUNT(CASE WHEN o.sales <= 1000 THEN 1 END) AS "low-value"
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.region;

/*

    13. Úloha

*/

SELECT
    c.customer_name as "Name",
    SUM(o.sales) as "Sales SUM",
    AVG(o.discount) as "Discount AVG",
    COUNT(o.order_id) as "Orders COUNT",
    CASE WHEN SUM(o.sales) > 2500 THEN 'VIP' ELSE 'REGULAR' END AS "Group"
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY SUM(o.sales) DESC;