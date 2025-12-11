-- task3_mysql_screenshot_ready.sql
-- MySQL-only script for Task 3: Ecommerce analysis
-- Purpose: create a small ecommerce database, insert sample data, run analysis queries.
-- Notes:
--  - Designed for MySQL Server and MySQL Workbench.
--  - Run the whole file (Run All) to create DB/tables/data.
--  - For screenshots: select each query marked with a 📸 and run it individually.

-- =========================
-- 0) Create database and use it
-- =========================
DROP DATABASE IF EXISTS Ecommerce_SQL_Database;
CREATE DATABASE Ecommerce_SQL_Database;
USE Ecommerce_SQL_Database;

-- =========================
-- 1) Drop tables if exist (safe re-run)
-- =========================
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- =========================
-- 2) Create tables
-- Brief: simple normalized schema: customers -> orders -> order_items, plus products.
-- =========================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    email VARCHAR(150),
    country VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150),
    category VARCHAR(50)
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2), -- price per unit at purchase time
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =========================
-- 3) Insert sample data
-- Small dataset so queries run fast and screenshots are clear.
-- =========================
INSERT INTO customers (name, email, country) VALUES
('Asha Verma','asha@example.com','India'),
('John Doe','john@example.com','USA'),
('Sara Khan','sara@example.com','India'),
('Liu Wei','liu@example.com','China'),
('Carlos Mendez','carlos@example.com','Spain');

INSERT INTO products (product_name, category) VALUES
('Wireless Mouse','Accessories'),
('Gaming Keyboard','Accessories'),
('Office Chair','Furniture'),
('Bluetooth Speaker','Electronics'),
('Notebook','Stationery');

INSERT INTO orders (customer_id, order_date) VALUES
(1,'2025-11-20'),
(2,'2025-11-21'),
(1,'2025-11-22'),
(3,'2025-11-23'),
(4,'2025-11-24');

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1,1,2,12.50),
(1,5,5,2.00),
(2,2,1,45.00),
(3,3,1,120.00),
(3,1,1,12.50),
(4,4,2,30.00),
(5,2,3,45.00),
(5,5,10,2.00);

-- =========================
-- 4) Screenshot queries
-- Each query below that has a 📸 must be run individually and screenshotted.
-- Capture: editor with the query visible + the result grid or Action Output message.
-- =========================

-- 📸 SCREENSHOT #1 — Customers table (sample rows)
SELECT * FROM customers;

-- 📸 SCREENSHOT #2 — Orders table (sample rows)
SELECT * FROM orders;

-- 📸 SCREENSHOT #3 — Products table (sample rows)
SELECT * FROM products;

-- 📸 SCREENSHOT #4 — Order Items table (sample rows)
SELECT * FROM order_items;

-- =========================
-- Aggregations / Grouping
-- =========================

-- 📸 SCREENSHOT #5 — Revenue by country
-- Explanation: join customers -> orders -> order_items, sum quantity*price per country.
SELECT c.country, SUM(oi.quantity * oi.price) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.country
ORDER BY total_revenue DESC;

-- 📸 SCREENSHOT #6 — Revenue by category
-- Explanation: group order items by product category to find category revenue.
SELECT p.category, SUM(oi.quantity * oi.price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- =========================
-- Joins examples
-- =========================

-- 📸 SCREENSHOT #7 — INNER JOIN (customers who have orders)
SELECT DISTINCT c.customer_id, c.name, o.order_id, o.order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- 📸 SCREENSHOT #8 — LEFT JOIN (all customers + orders if any)
SELECT c.customer_id, c.name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- 📸 SCREENSHOT #9 — RIGHT JOIN (all orders + customer info; MySQL supports RIGHT JOIN)
SELECT c.customer_id, c.name, o.order_id, o.order_date
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- =========================
-- Subquery example
-- =========================

-- 📸 SCREENSHOT #10 — Top 5 spending customers (subquery approach)
-- Explanation: inner query computes total_spent per customer; outer sorts & limits.
SELECT name, total_spent
FROM (
    SELECT c.name, SUM(oi.quantity * oi.price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) t
ORDER BY total_spent DESC
LIMIT 5;

-- =========================
-- ARPU (Average Revenue Per User)
-- =========================

-- 📸 SCREENSHOT #11 — ARPU (revenue / number of customers with orders)
-- Explanation: divides total revenue by count of distinct customers who placed orders.
SELECT 
    ROUND(SUM(oi.quantity * oi.price) / NULLIF(COUNT(DISTINCT o.customer_id),0),2) AS ARPU
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- =========================
-- View creation
-- =========================

-- 📸 SCREENSHOT #12 — CREATE VIEW success message
-- Explanation: create a reusable view customer_sales with total_spent per customer.
CREATE OR REPLACE VIEW customer_sales AS
SELECT c.customer_id, c.name,
       COALESCE(SUM(oi.quantity * oi.price),0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name;

-- 📸 SCREENSHOT #13 — View output (query the view)
SELECT * FROM customer_sales ORDER BY total_spent DESC;

-- =========================
-- Index creation (optimization)
-- =========================

-- 📸 SCREENSHOT #14 — CREATE INDEX success message
-- Explanation: add index on orders.customer_id to speed joins.
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- Optional additional indexes (no screenshot required)
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- =========================
-- End of file
-- =========================
