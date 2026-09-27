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