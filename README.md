# sql-mastery

Advanced SQL practice on my path from Full Stack Developer to Data Engineer.
One folder per topic, one file per problem. Each file includes the problem
statement, my solution, and the concept it practices.

> Module 1 · Week 1 of my [Data Engineering roadmap](https://github.com/wildsrincon):
> advanced SQL fundamentals. SQL first, tools later — ~60% of real data
> engineering work is SQL.

## How this repo works

One folder per topic, one file per problem, committed the same day it is
solved. Start from [`TEMPLATE.sql`](TEMPLATE.sql): the header carries the
problem statement, the concept it practices, and why the obvious alternative
fails. The header is the part worth writing — the query alone does not show
what was learned.

A problem solved in a client and never written to a file leaves nothing behind.
The notes keep the lesson; only the repo keeps the work.

## Window functions

| # | Problem | Concept |
|---|---------|---------|
| 01 | [Top 3 Department Salaries](window-functions/01-top-3-department-salaries.sql) | `DENSE_RANK()` + CTE (why you can't filter a window function in `WHERE`) |
| 02 | [Month-over-Month Revenue Change](window-functions/02-month-over-month-revenue.sql) | `LAG()` offset function + `PARTITION BY` |
| 03 | [Cumulative Revenue per Product](window-functions/03-running-total-revenue.sql) | `SUM() OVER (... ORDER BY ...)` running total |

## CTEs & subqueries

| # | Problem | Concept |
|---|---------|---------|
| 01 | [Employee Query Histogram](ctes-subqueries/01-employee-query-histogram.sql) | Two-level aggregation with a CTE + `LEFT JOIN` filter in `ON` vs `WHERE` |
| 02 | [Second Highest Salary](ctes-subqueries/02-second-highest-salary.sql) | Global `DENSE_RANK()` (no `PARTITION BY`) + `DISTINCT` for ties |
| 03 | [Third Transaction](ctes-subqueries/03-third-transaction.sql) | `ROW_NUMBER()` + `PARTITION BY` + why `ORDER BY` direction matters |

## Joins & aggregation

| # | Problem | Concept |
|---|---------|---------|
| 01 | [Friend Acceptance Rate](joins-aggregation/01-friend-acceptance-rate.sql) | Aggregation vs existence in a filter — `COUNT` of the nullable side after a `LEFT JOIN`, and why `HAVING` undoes the join |

## What is a window function?

A window function computes an aggregate value over a set of related rows, but
unlike `GROUP BY`, it returns a result for each individual row rather than
collapsing each group into a single row. This allows you to keep the row-level
detail and the aggregate side by side. For example, you can use it to calculate
the cumulative revenue per product in a finance report, or to rank rows within
a group.

## Key takeaways

- A window function computes a value over a set of related rows **without
  collapsing them** like `GROUP BY` does — you keep the row-level detail and the
  aggregate side by side.
- `RANK` leaves gaps after ties; `DENSE_RANK` does not.
- You cannot filter a window function in `WHERE` (logical execution order:
  `FROM → WHERE → ... → SELECT`); wrap it in a CTE and filter in the outer query.
- Adding `ORDER BY` inside a window aggregate turns a static total into a
  running total.
- A CTE beats a nested subquery on readability and reuse, not performance —
  modern Postgres (12+) inlines non-recursive CTEs anyway.
- A right-table filter in a `LEFT JOIN` belongs in `ON`, not `WHERE` — in
  `WHERE` it silently turns the join into an `INNER JOIN` (NULL comparisons
  drop the unmatched rows).
- Prefer `EXISTS`/`NOT EXISTS` over `IN`/`NOT IN`: `NOT IN` against a subquery
  that returns any `NULL` yields zero rows, silently.
