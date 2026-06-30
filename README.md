# sql-mastery

Advanced SQL practice on my path from Full Stack Developer to Data Engineer.
One folder per topic, one file per problem. Each file includes the problem
statement, my solution, and the concept it practices.

> Module 1 · Week 1 of my [Data Engineering roadmap](https://github.com/wildsrincon):
> advanced SQL fundamentals. SQL first, tools later — ~60% of real data
> engineering work is SQL.

## Window functions

| # | Problem | Concept |
|---|---------|---------|
| 01 | [Top 3 Department Salaries](window-functions/01-top-3-department-salaries.sql) | `DENSE_RANK()` + CTE (why you can't filter a window function in `WHERE`) |
| 02 | [Month-over-Month Revenue Change](window-functions/02-month-over-month-revenue.sql) | `LAG()` offset function + `PARTITION BY` |
| 03 | [Cumulative Revenue per Product](window-functions/03-running-total-revenue.sql) | `SUM() OVER (... ORDER BY ...)` running total |

## What is a window function?

<!-- TODO (Wilder): write this section yourself — it's your C1 English practice.
     5-6 lines explaining what a window function is, in your own words. -->

## Key takeaways

- A window function computes a value over a set of related rows **without
  collapsing them** like `GROUP BY` does — you keep the row-level detail and the
  aggregate side by side.
- `RANK` leaves gaps after ties; `DENSE_RANK` does not.
- You cannot filter a window function in `WHERE` (logical execution order:
  `FROM → WHERE → ... → SELECT`); wrap it in a CTE and filter in the outer query.
- Adding `ORDER BY` inside a window aggregate turns a static total into a
  running total.
