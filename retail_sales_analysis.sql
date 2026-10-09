CREATE DATABASE IF NOT EXISTS retail_analysis;
USE retail_analysis;

-- Reset tables so the script can be run again
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. Create tables
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    discount_rate DECIMAL(4,2) NOT NULL DEFAULT 0,
    order_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 2. Insert fictional customers
INSERT INTO customers VALUES
(1, 'Aarav Sharma', 'Delhi'),
(2, 'Isha Verma', 'Noida'),
(3, 'Kabir Singh', 'Lucknow'),
(4, 'Meera Gupta', 'Jaipur'),
(5, 'Sana Khan', 'Mumbai');

-- 3. Insert products
INSERT INTO products VALUES
(101, 'Wireless Mouse', 'Accessories', 799.00),
(102, 'Keyboard', 'Accessories', 1499.00),
(103, 'Laptop Stand', 'Office', 1299.00),
(104, 'Desk Lamp', 'Office', 999.00),
(105, 'Notebook Set', 'Stationery', 249.00);

-- 4. Insert sample orders
INSERT INTO orders VALUES
(1001, '2025-01-05', 1, 101, 2, 0.00, 'Completed'),
(1002, '2025-01-12', 2, 102, 1, 0.10, 'Completed'),
(1003, '2025-01-20', 3, 105, 4, 0.00, 'Completed'),
(1004, '2025-02-03', 4, 103, 1, 0.05, 'Completed'),
(1005, '2025-02-11', 5, 104, 2, 0.00, 'Completed'),
(1006, '2025-02-18', 1, 102, 1, 0.00, 'Returned'),
(1007, '2025-03-02', 2, 101, 3, 0.05, 'Completed'),
(1008, '2025-03-10', 3, 103, 2, 0.10, 'Completed'),
(1009, '2025-03-15', 4, 105, 5, 0.00, 'Completed'),
(1010, '2025-03-25', 5, 102, 2, 0.10, 'Cancelled'),
(1011, '2025-04-04', 1, 104, 1, 0.00, 'Completed'),
(1012, '2025-04-09', 2, 103, 1, 0.00, 'Completed'),
(1013, '2025-04-17', 3, 101, 2, 0.00, 'Completed'),
(1014, '2025-04-22', 4, 102, 1, 0.05, 'Completed'),
(1015, '2025-05-06', 5, 105, 6, 0.10, 'Completed'),
(1016, '2025-05-12', 1, 103, 1, 0.00, 'Completed'),
(1017, '2025-05-19', 2, 104, 2, 0.05, 'Returned'),
(1018, '2025-05-24', 3, 102, 1, 0.00, 'Completed'),
(1019, '2025-06-08', 4, 101, 2, 0.10, 'Completed'),
(1020, '2025-06-15', 5, 103, 1, 0.00, 'Completed');

-- Revenue formula:
-- quantity * unit price * (1 - discount rate)
-- Only Completed orders count as revenue in this project.

-- ANALYSIS 1: Overall business KPIs
SELECT
    COUNT(*) AS completed_orders,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.quantity * p.unit_price *
        (1 - o.discount_rate)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.unit_price *
        (1 - o.discount_rate)), 2) AS average_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_status = 'Completed';

-- ANALYSIS 2: Monthly revenue trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    ROUND(SUM(o.quantity * p.unit_price *
        (1 - o.discount_rate)), 2) AS monthly_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- ANALYSIS 3: Product performance
SELECT
    p.product_name,
    p.category,
    SUM(o.quantity) AS units_sold,
    ROUND(SUM(o.quantity * p.unit_price *
        (1 - o.discount_rate)), 2) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC;

-- ANALYSIS 4: Customer spending
SELECT
    c.customer_name,
    c.city,
    COUNT(o.order_id) AS completed_orders,
    ROUND(SUM(o.quantity * p.unit_price *
        (1 - o.discount_rate)), 2) AS customer_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name, c.city
ORDER BY customer_revenue DESC;

-- ANALYSIS 5: Orders above average order value (subquery)
SELECT
    o.order_id,
    o.order_date,
    p.product_name,
    ROUND(o.quantity * p.unit_price *
        (1 - o.discount_rate), 2) AS order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE o.order_status = 'Completed'
AND o.quantity * p.unit_price * (1 - o.discount_rate) >
(
    SELECT AVG(o2.quantity * p2.unit_price *
        (1 - o2.discount_rate))
    FROM orders o2
    JOIN products p2 ON o2.product_id = p2.product_id
    WHERE o2.order_status = 'Completed'
)
ORDER BY order_value DESC;

-- ANALYSIS 6: Rank products by revenue
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(o.quantity * p.unit_price *
            (1 - o.discount_rate)) AS revenue
    FROM products p
    JOIN orders o ON p.product_id = o.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_name,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM product_sales
ORDER BY revenue_rank;

-- ANALYSIS 7: Cumulative monthly revenue
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
        SUM(o.quantity * p.unit_price *
            (1 - o.discount_rate)) AS revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    sales_month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (ORDER BY sales_month),
        2
    ) AS cumulative_revenue
FROM monthly_sales
ORDER BY sales_month;

-- ANALYSIS 8: Order status distribution
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- ANALYSIS 9: Customers with no completed orders
SELECT
    c.customer_id,
    c.customer_name,
    c.city
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
WHERE o.order_id IS NULL;

-- ANALYSIS 10: Basic data quality checks
SELECT *
FROM orders
WHERE quantity <= 0
   OR discount_rate < 0
   OR discount_rate > 1;
