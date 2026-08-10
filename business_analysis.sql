
SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;
SELECT * FROM shipping;
SELECT * FROM category;


-- Q1 — Markets Above Minimum Order Volume: total orders, revenue, and profit per market
SELECT
    Market,
    COUNT(DISTINCT `Order Id`)   AS total_orders,
    SUM(`Total Sales`)           AS total_revenue,
    SUM(`Benefit per order`)     AS total_profit
FROM orders
GROUP BY Market
ORDER BY total_revenue DESC;


-- Q2 — On-Time vs Late Delivery Rate by Shipping Mode
SELECT
    `Shipping Mode`,
    ROUND(100.0 * SUM(CASE WHEN `Delivery Status` = 'Shipping on time'
                            THEN 1 ELSE 0 END) / COUNT(*), 2) AS on_time_pct,
    ROUND(100.0 * SUM(CASE WHEN `Delivery Status` = 'Late delivery'
                            THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_delivery_pct,
    ROUND(100.0 * SUM(CASE WHEN `Delivery Status` = 'Advance shipping'
                            THEN 1 ELSE 0 END) / COUNT(*), 2) AS advance_delivery_pct
FROM shipping
GROUP BY `Shipping Mode`
ORDER BY on_time_pct DESC;


-- Q3 — Average Delivery Delay by Market
SELECT
    o.Market,
    ROUND(AVG(s.`Days for shipping (real)` - s.`Days for shipment (scheduled)`), 2) AS avg_delay_days
FROM orders o
INNER JOIN shipping s
    ON s.`Order Id` = o.`Order Id`
GROUP BY o.Market
ORDER BY avg_delay_days;


-- Q4 — Monthly Sales Trend: total sales for each month
SELECT
    MONTHNAME(`order date`) AS month,
    ROUND(SUM(`Total Sales`), 2) AS monthly_revenue
FROM orders
GROUP BY month
ORDER BY monthly_revenue DESC;


-- Q5 — Month-over-Month Sales Growth (%)
WITH monthly_sales AS (
    SELECT
        MONTH(`order date`) AS month,
        YEAR(`order date`)  AS yr,
        ROUND(SUM(`Total Sales`), 2) AS total_sales
    FROM orders
    GROUP BY month, yr
    ORDER BY month
)
SELECT
    month,
    yr,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_rev,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY month))
        / LAG(total_sales) OVER (ORDER BY month) * 100,
        2
    ) AS month_growth_pct
FROM monthly_sales
ORDER BY yr, month;


-- Q6 — Top 10 Products by Revenue
SELECT
    p.`Product Name`,
    ROUND(SUM(o.`Total Sales`), 2) AS total_revenue
FROM orders o
JOIN products p
    ON o.`Product Card Id` = p.`Product Card Id`
GROUP BY p.`Product Name`
ORDER BY total_revenue DESC
LIMIT 10;


-- Q7 — Total Sales, Profit, and Margin per Category
SELECT
    c.`Category Name`,
    ROUND(SUM(o.`Total Sales`), 2) AS total_sales,
    ROUND(SUM(o.`Benefit per order`), 2) AS total_profit,
    ROUND(SUM(o.`Benefit per order`) / SUM(o.`Total Sales`) * 100, 2) AS total_margin_pct
FROM orders o
LEFT JOIN products p
    ON p.`Product Card Id` = o.`Product Card Id`
JOIN category c
    ON c.`Product Category Id` = p.`Product Category Id`
GROUP BY c.`Category Name`
ORDER BY total_sales, total_profit, total_margin_pct;


-- Q8 — Rank Products Within Each Category
SELECT
    `Category Name`,
    `Product Name`,
    total_sales,
    RANK() OVER (
        PARTITION BY `Category Name`
        ORDER BY total_sales DESC
    ) AS product_rank
FROM (
    SELECT
        c.`Category Name`,
        p.`Product Name`,
        SUM(o.`Total Sales`) AS total_sales
    FROM orders o
    LEFT JOIN products p
        ON o.`Product Card Id` = p.`Product Card Id`
    JOIN category c
        ON p.`Product Category Id` = c.`Product Category Id`
    GROUP BY
        c.`Category Name`,
        p.`Product Name`
) AS t
ORDER BY
    `Category Name`,
    product_rank;


-- Q9 — Repeat vs One-Time Customers
WITH customer_orders AS (
    SELECT
        `Customer Id`,
        COUNT(DISTINCT `Order Id`) AS order_count
    FROM orders
    GROUP BY `Customer Id`
)
SELECT
    CASE WHEN order_count = 1 THEN 'One-Time Customer' ELSE 'Repeat Customer' END AS customer_type,
    COUNT(*) AS num_customers
FROM customer_orders
GROUP BY
    CASE WHEN order_count = 1 THEN 'One-Time Customer' ELSE 'Repeat Customer' END;


-- Q10 — Discount Rate vs. Average Profit
SELECT
    CASE
        WHEN `Order Item Discount Rate` = 0      THEN 'No Discount'
        WHEN `Order Item Discount Rate` <= 0.10  THEN '1-10%'
        WHEN `Order Item Discount Rate` <= 0.20  THEN '11-20%'
        ELSE '21%+'
    END AS discount_band,
    COUNT(*) AS order_lines,
    ROUND(AVG(`Benefit per order`), 2) AS avg_profit
FROM orders
GROUP BY
    CASE
        WHEN `Order Item Discount Rate` = 0      THEN 'No Discount'
        WHEN `Order Item Discount Rate` <= 0.10  THEN '1-10%'
        WHEN `Order Item Discount Rate` <= 0.20  THEN '11-20%'
        ELSE '21%+'
    END
ORDER BY discount_band;


-- Q11 — Cancelled Orders by Region: regions with an above-average cancellation rate
WITH region_cancel_rate AS (
    SELECT
        `Order Region`,
        ROUND(100.0 * SUM(CASE WHEN `Order Status` = 'CANCELED'
                                THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancel_rate_pct
    FROM orders
    GROUP BY `Order Region`
)
SELECT *
FROM region_cancel_rate
WHERE cancel_rate_pct > (SELECT AVG(cancel_rate_pct) FROM region_cancel_rate)
ORDER BY cancel_rate_pct DESC;


-- Q12 — Orders Missing Shipping Records
SELECT
    o.`Order Id`,
    o.Market,
    s.`Delivery Status`
FROM orders o
LEFT JOIN shipping s
    ON o.`Order Id` = s.`Order Id`
WHERE s.`Order Id` IS NULL;
