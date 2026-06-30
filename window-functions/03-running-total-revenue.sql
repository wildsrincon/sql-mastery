-- Problem: Cumulative Revenue per Product (running total)
-- For each product, show product, month, revenue and a running_total column with
-- the cumulative revenue of that product from its first month up to the current
-- month. Sort by product ASC, month ASC.
--
-- Concept: SUM() OVER (... ORDER BY ...) as a running total.
-- Key insight: adding ORDER BY to a window aggregate changes its meaning.
--   SUM(x) OVER (PARTITION BY g)            => static group total (same value per row)
--   SUM(x) OVER (PARTITION BY g ORDER BY t) => running total (accumulates row by row)
-- The ORDER BY is the switch that turns a static total into a cumulative one.
-- PARTITION BY product restarts the accumulation for each product.

SELECT
  product,
  month,
  revenue,
  SUM(revenue) OVER (
    PARTITION BY product
    ORDER BY month
  ) AS running_total
FROM monthly_sales
ORDER BY product, month;
