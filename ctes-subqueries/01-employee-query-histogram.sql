-- Problem: Employee Query Histogram (DataLemur / IBM)
-- Generate a histogram of the number of unique queries run by employees during
-- Q3 2023 (July to September), including employees who ran zero queries.
-- Output: unique_queries (histogram bucket) and employee_count.
--
-- Concept: two-level aggregation with a CTE + LEFT JOIN with the filter in ON.
-- Why two aggregations: the first pass counts unique queries per employee (one
-- row per employee); the second pass groups THAT result to count employees per
-- bucket. You can't do both in a single GROUP BY — the second aggregation needs
-- the first one's output as its input, and the CTE names that intermediate step.
-- Why the date filter lives in ON and not WHERE: for an employee with no
-- queries in Q3, q.query_starttime is NULL, and NULL >= date evaluates to NULL,
-- so a WHERE filter would drop the row — silently turning the LEFT JOIN into an
-- INNER JOIN and losing the zero-query employees the histogram needs.

WITH employee_queries AS (
  SELECT
    e.employee_id,
    COUNT(DISTINCT q.query_id) AS unique_queries
  FROM employees AS e
  LEFT JOIN queries AS q
    ON e.employee_id = q.employee_id
    AND q.query_starttime >= '2023-07-01T00:00:00Z'
    AND q.query_starttime < '2023-10-01T00:00:00Z'
  GROUP BY e.employee_id
)
SELECT
  unique_queries,
  COUNT(employee_id) AS employee_count
FROM employee_queries
GROUP BY unique_queries
ORDER BY unique_queries;
