-- Problem: Second Highest Salary (DataLemur)
-- Find the second highest salary among all employees. If multiple employees
-- share the second highest salary, display the salary only once.
--
-- Concept: DENSE_RANK() without PARTITION BY + DISTINCT for ties.
-- Why DENSE_RANK: with ties on the top salary, RANK would skip rank 2 entirely
-- (1, 1, 3...), while DENSE_RANK guarantees rank 2 is the second highest
-- DISTINCT salary. No PARTITION BY because the ranking is global (whole
-- company), not per department.
-- Why DISTINCT: if several employees share the rank-2 salary, the WHERE returns
-- one row per employee — identical values. DISTINCT collapses them to one.
-- Lesson: passing the platform's test doesn't prove the tie case is handled if
-- the test dataset happens to have no ties at rank 2. Guard the edge case the
-- statement asks for, not just the visible dataset.

WITH highest_salary AS (
  SELECT
    employee_id,
    name,
    salary,
    department_id,
    manager_id,
    DENSE_RANK() OVER (
      ORDER BY salary DESC
    ) AS s_highest_salary
  FROM employee
)
SELECT DISTINCT
  s.salary AS second_highest_salary
FROM highest_salary AS s
WHERE s.s_highest_salary = 2;
