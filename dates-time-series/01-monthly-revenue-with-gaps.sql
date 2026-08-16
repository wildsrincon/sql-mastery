-- Problem: Monthly revenue for 2025, with the empty months kept
-- Source: written for practice, not from a platform. The data ships alongside
--   in 01-monthly-revenue-with-gaps.fixture.sql, and the expected 12 rows are
--   listed at the bottom of that file. Verified by diffing this query's output
--   against them.
--
-- One table, orders, holding one row per order with a date, an amount and a
-- status of 'completed', 'refunded' or 'cancelled'. Return the revenue for
-- each month of 2025 — all twelve of them, including the months where nothing
-- was earned, which must read 0 rather than be missing. Only completed orders
-- count as revenue. Each row also carries the previous month's revenue.
-- Sort by month ascending.
--
-- Concept: a period that has no rows cannot come out of a GROUP BY.
-- Why generate_series: orders can only produce months it actually contains.
--   March has nothing but a cancellation and a refund, July has no orders at
--   all, and no query over that table — however clever — can invent them. The
--   calendar has to be built independently and the data attached to it, which
--   inverts the usual direction: the dimension leads, the facts follow.
-- Why the status filter sits inside the CTE: it has to run BEFORE the outer
--   join. Moved to the final WHERE it would test a column of the right-hand
--   table, and a NULL from an unmatched row fails that test — silently turning
--   the LEFT JOIN into an INNER JOIN and deleting exactly the empty months the
--   query exists to preserve.
-- Why a date range and not EXTRACT(YEAR FROM ordered_at) = 2025: wrapping the
--   column in a function makes the predicate non-sargable, so an index on
--   ordered_at cannot be used and the planner falls back to a full scan. Same
--   answer, different cost — invisible at 22 rows, decisive at 22 million.
-- Why COALESCE before LAG and not after: LAG reads the value of the previous
--   row as that row already stands. Coalescing afterwards would leave the month
--   following an empty one showing NULL instead of 0.

WITH meses AS (
  SELECT generate_series(
    '2025-01-01'::date,
    '2025-12-01'::date,
    '1 month'::interval
  )::date AS mes
),
ingresos_por_mes AS (
  SELECT
    date_trunc('month', ordered_at)::date AS mes,
    SUM(amount) AS ingresos
  FROM orders
  WHERE status = 'completed'
    AND ordered_at >= '2025-01-01'
    AND ordered_at < '2026-01-01'
  GROUP BY 1
),
base AS (
  SELECT
    c.mes,
    COALESCE(o.ingresos, 0) AS ingresos
  FROM meses c
  LEFT JOIN ingresos_por_mes o USING (mes)
)
SELECT
  mes,
  ingresos,
  LAG(ingresos) OVER (ORDER BY mes) AS ingresos_mes_anterior
FROM base
ORDER BY mes;

-- Gotcha: the ::date cast on generate_series is load-bearing. Without it the
-- series comes back as timestamp, USING (mes) never matches the date column on
-- the other side, and the query returns twelve rows all reading 0. That is the
-- worst possible failure — the row count is right, the shape is right, and the
-- numbers are quietly all wrong. A type mismatch across a join surface does not
-- raise; it just stops matching.
