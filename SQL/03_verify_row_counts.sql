USE retail_intelligence;

SELECT 'brands'      AS tbl, COUNT(*) AS row_count FROM brands      UNION ALL
SELECT 'categories',          COUNT(*)              FROM categories  UNION ALL
SELECT 'products',            COUNT(*)              FROM products    UNION ALL
SELECT 'stores',              COUNT(*)              FROM stores      UNION ALL
SELECT 'staffs',              COUNT(*)              FROM staffs      UNION ALL
SELECT 'customers',           COUNT(*)              FROM customers   UNION ALL
SELECT 'orders',              COUNT(*)              FROM orders      UNION ALL
SELECT 'order_items',         COUNT(*)              FROM order_items UNION ALL
SELECT 'stocks',              COUNT(*)              FROM stocks;