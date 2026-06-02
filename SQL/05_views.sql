USE retail_intelligence;

CREATE OR REPLACE VIEW vw_sales_summary AS
SELECT
    o.order_id,
    o.order_date,
    YEAR(o.order_date)                                AS order_year,
    MONTH(o.order_date)                               AS order_month,
    DATE_FORMAT(o.order_date,'%Y-%m')                 AS yr_month,
    o.customer_id,
    CONCAT(c.first_name,' ',c.last_name)              AS customer_name,
    c.state                                            AS customer_state,
    o.store_id,
    st.store_name,
    st.city                                            AS store_city,
    st.state                                           AS store_state,
    o.staff_id,
    CONCAT(sf.first_name,' ',sf.last_name)            AS staff_name,
    oi.product_id,
    p.product_name,
    b.brand_name,
    cat.category_name,
    p.model_year,
    oi.quantity,
    oi.list_price,
    oi.discount,
    ROUND(oi.quantity * oi.list_price * (1-oi.discount), 2) AS line_revenue,
    CASE o.order_status
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Rejected'
        WHEN 4 THEN 'Completed'
    END                                                AS order_status_label
FROM orders o
JOIN order_items oi  ON o.order_id    = oi.order_id
JOIN products    p   ON oi.product_id = p.product_id
JOIN brands      b   ON p.brand_id    = b.brand_id
JOIN categories  cat ON p.category_id = cat.category_id
JOIN stores      st  ON o.store_id    = st.store_id
JOIN staffs      sf  ON o.staff_id    = sf.staff_id
JOIN customers   c   ON o.customer_id = c.customer_id;

USE retail_intelligence;

CREATE OR REPLACE VIEW vw_staff_performance AS
SELECT
    CONCAT(sf.first_name,' ',sf.last_name)                            AS staff_name,
    st.store_name,
    st.state,
    COUNT(DISTINCT o.order_id)                                        AS orders_handled,
    SUM(oi.quantity)                                                  AS units_sold,
    ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2)     AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN staffs      sf ON o.staff_id = sf.staff_id
JOIN stores      st ON o.store_id = st.store_id
WHERE o.order_status = 4
GROUP BY sf.staff_id, staff_name, st.store_name, st.state;

USE retail_intelligence;

CREATE OR REPLACE VIEW vw_inventory_health AS
SELECT
    sk.store_id,
    st.store_name,
    sk.product_id,
    p.product_name,
    b.brand_name,
    cat.category_name,
    sk.quantity                                        AS stock_qty,
    COALESCE(sold.units_sold, 0)                      AS units_sold,
    CASE
        WHEN sk.quantity < 5  THEN 'Critical'
        WHEN sk.quantity < 20 THEN 'Low'
        ELSE 'Healthy'
    END                                                AS stock_status
FROM stocks sk
JOIN products   p   ON sk.product_id = p.product_id
JOIN brands     b   ON p.brand_id    = b.brand_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN stores     st  ON sk.store_id   = st.store_id
LEFT JOIN (
    SELECT oi.product_id, SUM(oi.quantity) AS units_sold
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 4
    GROUP BY oi.product_id
) sold ON sk.product_id = sold.product_id;

USE retail_intelligence;

CREATE OR REPLACE VIEW vw_customer_segments AS
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name)                              AS customer_name,
    c.city,
    c.state,
    COUNT(DISTINCT o.order_id)                                        AS order_count,
    ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)), 2)     AS total_spent,
    CASE
        WHEN COUNT(DISTINCT o.order_id) >= 5 THEN 'High Value'
        WHEN COUNT(DISTINCT o.order_id) >= 2 THEN 'Returning'
        ELSE 'One-Time'
    END                                                               AS customer_segment
FROM customers c
JOIN orders      o  ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE o.order_status = 4
GROUP BY c.customer_id, customer_name, c.city, c.state;

USE retail_intelligence;

CREATE OR REPLACE VIEW vw_monthly_trend AS
WITH monthly AS (
    SELECT
        YEAR(o.order_date)                AS yr,
        MONTH(o.order_date)               AS mth,
        DATE_FORMAT(o.order_date,'%Y-%m') AS yr_month,
        COUNT(DISTINCT o.order_id)        AS orders,
        ROUND(SUM(oi.quantity * oi.list_price * (1-oi.discount)),2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 4
    GROUP BY yr, mth, yr_month
)
SELECT
    yr, mth, yr_month, orders, revenue,
    LAG(revenue) OVER (ORDER BY yr, mth)  AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY yr, mth)) /
         LAG(revenue) OVER (ORDER BY yr, mth) * 100
    , 2)                                  AS mom_growth_pct
FROM monthly;