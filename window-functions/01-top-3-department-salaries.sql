-- Problem: Top 3 Department Salaries (DataLemur / Amazon)
-- A "high earner" in a department is an employee whose salary ranks among the
-- top three salaries within that department. List the department name, employee
-- name and salary. Ties at the same salary count as one rank level.
-- Sort by department_name ASC, salary DESC, name ASC.
--
-- Concept: DENSE_RANK() + CTE.
-- Why DENSE_RANK: "top three salaries" means the top three DISTINCT salary
-- levels, so tied salaries share a rank and we keep counting without gaps.
-- Why a CTE: you cannot filter a window function in WHERE, because WHERE runs
-- before the SELECT step where window functions are computed. So we rank in the
-- CTE and filter in the outer query, where the column already exists.

WITH ranked_salary AS (
  SELECT
    name,
    salary,
    department_id,
    DENSE_RANK() OVER (
      PARTITION BY department_id
      ORDER BY salary DESC
    ) AS ranking
  FROM employee
)
SELECT
  d.department_name,
  s.name,
  s.salary
FROM ranked_salary AS s
INNER JOIN department AS d
  ON s.department_id = d.department_id
WHERE s.ranking <= 3
ORDER BY d.department_name ASC, s.salary DESC, s.name ASC;
