#Q1 Overall KPI Summary
USE retail_intelligence;

SELECT
    COUNT(DISTINCT o.order_id)                                       AS total_orders,
    COUNT(DISTINCT o.customer_id)                                    AS total_customers,
    SUM(oi.quantity)                                                 AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2)  AS total_revenue,
    ROUND(AVG(oi.quantity * oi.list_price * (1 - oi.discount)), 2)  AS avg_item_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 4;

#Q2 Store-Wise Revenue
USE retail_intelligence;

SELECT
    st.store_name,
    st.city,
    st.state,
    COUNT(DISTINCT o.order_id)                                       AS total_orders,
    COUNT(DISTINCT o.customer_id)                                    AS unique_customers,
    SUM(oi.quantity)                                                 AS units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2)  AS total_revenue,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) /
          COUNT(DISTINCT o.order_id), 2)                            AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores      st ON o.store_id  = st.store_id
WHERE o.order_status = 4
GROUP BY st.store_id, st.store_name, st.city, st.state
ORDER BY total_revenue DESC;

#Q3 Brand Performance by Store
USE retail_intelligence;

SELECT
    st.store_name,
    b.brand_name,
    SUM(oi.quantity)                                                  AS units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2)   AS revenue,
    RANK() OVER (PARTITION BY st.store_id
                 ORDER BY SUM(oi.quantity * oi.list_price * (1 - oi.discount)) DESC
                )                                                      AS rank_in_store
FROM orders o
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN products    p  ON oi.product_id = p.product_id
JOIN brands      b  ON p.brand_id    = b.brand_id
JOIN stores      st ON o.store_id    = st.store_id
WHERE o.order_status = 4
GROUP BY st.store_id, st.store_name, b.brand_id, b.brand_name
ORDER BY st.store_name, rank_in_store;

#Q4 Category Profitability
USE retail_intelligence;

SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id)                                      AS num_products,
    SUM(oi.quantity)                                                  AS units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2)   AS total_revenue,
    ROUND(AVG(oi.list_price), 2)                                      AS avg_list_price,
    ROUND(AVG(oi.discount) * 100, 2)                                  AS avg_discount_pct
FROM order_items oi
JOIN products   p  ON oi.product_id  = p.product_id
JOIN categories c  ON p.category_id  = c.category_id
JOIN orders     o  ON oi.order_id    = o.order_id
WHERE o.order_status = 4
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

#Q5 Staff Performance Leaderoard
USE retail_intelligence;

SELECT
    CONCAT(sf.first_name,' ',sf.last_name)                           AS staff_name,
    st.store_name,
    COUNT(DISTINCT o.order_id)                                       AS orders_handled,
    SUM(oi.quantity)                                                 AS units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2)  AS total_revenue,
    ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)) /
          COUNT(DISTINCT o.order_id), 2)                            AS avg_revenue_per_order,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1-oi.discount)) DESC
                )                                                     AS overall_rank
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN staffs      sf ON o.staff_id = sf.staff_id
JOIN stores      st ON o.store_id = st.store_id
WHERE o.order_status = 4
GROUP BY sf.staff_id, staff_name, st.store_name
ORDER BY total_revenue DESC;

#Q6  Monthly Revenue Trend with MoM Growth
USE retail_intelligence;

WITH monthly AS (
    SELECT
        YEAR(o.order_date)                                            AS yr,
        MONTH(o.order_date)                                           AS mth,
        DATE_FORMAT(o.order_date,'%Y-%m')                             AS yr_month,
        COUNT(DISTINCT o.order_id)                                    AS orders,
        ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY yr, mth, yr_month
)
SELECT
    yr,
    mth,
    yr_month,
    orders,
    revenue,
    LAG(revenue) OVER (ORDER BY yr, mth)                             AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY yr, mth)) /
         LAG(revenue) OVER (ORDER BY yr, mth) * 100
    , 2)                                                             AS mom_growth_pct
FROM monthly
ORDER BY yr, mth;

#Q7 Delayed Shipments
USE retail_intelligence;

SELECT
    o.order_id,
    CONCAT(c.first_name,' ',c.last_name)   AS customer_name,
    st.store_name,
    CONCAT(sf.first_name,' ',sf.last_name) AS staff_name,
    o.order_date,
    o.required_date,
    o.shipped_date,
    DATEDIFF(o.shipped_date, o.required_date) AS delay_days,
    CASE
        WHEN o.shipped_date IS NULL           THEN 'Not Shipped'
        WHEN o.shipped_date > o.required_date THEN 'Late'
        ELSE 'On Time'
    END AS shipment_status
FROM orders o
JOIN customers c  ON o.customer_id = c.customer_id
JOIN stores    st ON o.store_id    = st.store_id
JOIN staffs    sf ON o.staff_id    = sf.staff_id
WHERE o.shipped_date > o.required_date
   OR o.shipped_date IS NULL
ORDER BY delay_days DESC;

#Q8 Inventory Helath
USE retail_intelligence;

SELECT
    st.store_name,
    p.product_name,
    b.brand_name,
    c.category_name,
    sk.quantity                                      AS stock_qty,
    COALESCE(sold.units_sold, 0)                    AS total_units_sold,
    CASE
        WHEN sk.quantity < 5  THEN 'CRITICAL'
        WHEN sk.quantity < 20 THEN 'LOW'
        ELSE 'HEALTHY'
    END                                              AS stock_status,
    CASE
        WHEN COALESCE(sold.units_sold,0) > 0
        THEN ROUND(sk.quantity / sold.units_sold * 30, 1)
        ELSE NULL
    END                                              AS est_days_of_stock
FROM stocks sk
JOIN products   p  ON sk.product_id = p.product_id
JOIN brands     b  ON p.brand_id    = b.brand_id
JOIN categories c  ON p.category_id = c.category_id
JOIN stores     st ON sk.store_id   = st.store_id
LEFT JOIN (
    SELECT oi.product_id, SUM(oi.quantity) AS units_sold
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 4
    GROUP BY oi.product_id
) sold ON sk.product_id = sold.product_id
ORDER BY sk.quantity ASC;

#Q9  Customer Segmentation
USE retail_intelligence;

SELECT
    customer_segment,
    COUNT(DISTINCT customer_id)   AS total_customers,
    ROUND(SUM(revenue), 2)        AS segment_revenue,
    ROUND(AVG(revenue), 2)        AS avg_spend
FROM (
    SELECT
        c.customer_id,
        CASE
            WHEN COUNT(DISTINCT o.order_id) >= 5 THEN 'High Value'
            WHEN COUNT(DISTINCT o.order_id) >= 2 THEN 'Returning'
            ELSE 'One-Time'
        END                                                           AS customer_segment,
        SUM(oi.quantity * oi.list_price * (1-oi.discount))           AS revenue
    FROM customers c
    JOIN orders      o  ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 4
    GROUP BY c.customer_id
) AS customer_summary
GROUP BY customer_segment
ORDER BY segment_revenue DESC;

#Q10 Top 15 Products by Revenue
USE retail_intelligence;

SELECT
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year,
    SUM(oi.quantity)                                                   AS units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2)      AS total_revenue,
    ROUND(AVG(oi.discount)*100, 2)                                     AS avg_discount_pct,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.list_price * (1-oi.discount)) DESC
                )                                                       AS revenue_rank
FROM order_items oi
JOIN products   p ON oi.product_id = p.product_id
JOIN brands     b ON p.brand_id    = b.brand_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders     o ON oi.order_id   = o.order_id
WHERE o.order_status = 4
GROUP BY p.product_id, p.product_name, b.brand_name, c.category_name, p.model_year
ORDER BY revenue_rank
LIMIT 15;

#Q11 Order Status Breakdown
USE retail_intelligence;

SELECT
    CASE order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
    END                                                                AS status_label,
    COUNT(*)                                                           AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)                AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY order_status;

#Q12 Year over Year Revenue by Store 
USE retail_intelligence;

SELECT
    st.store_name,
    YEAR(o.order_date)                                                 AS year,
    ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2)      AS annual_revenue,
    LAG(ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)),2))
        OVER (PARTITION BY st.store_id ORDER BY YEAR(o.order_date))   AS prev_year_revenue,
    ROUND(
        (SUM(oi.quantity * oi.list_price * (1-oi.discount)) -
         LAG(SUM(oi.quantity * oi.list_price * (1-oi.discount)))
             OVER (PARTITION BY st.store_id ORDER BY YEAR(o.order_date))) /
         LAG(SUM(oi.quantity * oi.list_price * (1-oi.discount)))
             OVER (PARTITION BY st.store_id ORDER BY YEAR(o.order_date)) * 100
    , 2)                                                               AS yoy_growth_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN stores      st ON o.store_id = st.store_id
WHERE o.order_status = 4
GROUP BY st.store_id, st.store_name, year
ORDER BY st.store_name, year;


