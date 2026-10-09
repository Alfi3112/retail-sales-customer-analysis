# Retail Sales and Customer Analysis Using SQL

## Project Overview
This is a self-directed SQL portfolio project created to practice data analysis using MySQL. It uses fictional retail transaction data to explore revenue, product performance, customer spending, and order status.

## Business Objectives
- Calculate total revenue and average order value.
- Analyze monthly revenue trends.
- Identify top-performing products.
- Compare customer spending.
- Find orders above the average order value.
- Rank products using SQL window functions.
- Calculate cumulative monthly revenue.
- Analyze completed, returned, and cancelled orders.

## Tools and Skills
- MySQL 8.0+
- SQL joins and aggregations
- GROUP BY and aggregate functions
- Common Table Expressions (CTEs)
- Subqueries
- Window functions: DENSE_RANK() and SUM() OVER()
- Data quality checks

## Dataset
The project contains three related tables:
- customers: customer IDs, names, and cities
- products: product names, categories, and prices
- orders: order dates, quantities, discounts, and statuses

All data is fictional and created for practice. No real customer information is used.

## Revenue Definition
Revenue is calculated as:

Quantity × Unit Price × (1 − Discount Rate)

Only orders marked Completed are included in revenue calculations. Returned and cancelled orders are excluded.

## How to Run
1. Open `retail_sales_analysis.sql`.
2. Connect to MySQL 8.0 or later.
3. Run the script from beginning to end.
4. Review the output of each analysis query.

The script creates the database, tables, and sample records itself, so no separate dataset download is required.

## Learning Outcomes
This project demonstrates the use of SQL to answer business questions, summarize transaction data, rank products, analyze customer spending, and validate data.

## Project Limitations
This is a small practice dataset. Its results are illustrative and should not be interpreted as real business performance.

## About Me
I am a Computer Science graduate developing practical skills in SQL and data analytics. This project is part of my learning portfolio.
