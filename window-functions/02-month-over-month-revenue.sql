-- Problem: Month-over-Month Revenue Change
-- For each product, show product, month, revenue and a column revenue_change =
-- this month's revenue minus the previous month's revenue OF THE SAME PRODUCT.
-- The first month of each product has no previous month, so revenue_change is NULL.
-- Sort by product ASC, month ASC.
--
-- Concept: LAG() offset function.
-- LAG(x) returns the value from the PREVIOUS row in the window order.
-- PARTITION BY product => do not mix products (each product has its own timeline).
-- ORDER BY month => "previous" means the previous month in time.
-- The first row of each partition has no previous row, so LAG returns NULL and
-- (revenue - NULL) = NULL automatically (no CASE needed).

SELECT
  product,
  month,
  revenue,
  revenue - LAG(revenue) OVER (
    PARTITION BY product
    ORDER BY month
  ) AS revenue_change
FROM monthly_sales
ORDER BY product, month;
