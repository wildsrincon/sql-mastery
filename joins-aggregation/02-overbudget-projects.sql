-- Problem: Find the Overbudget Projects (StrataScratch / LinkedIn)
-- Three tables: linkedin_projects holds a title, a budget and the project's
-- start and end dates; linkedin_emp_projects links employees to projects; and
-- linkedin_employees holds an annual salary. A project is overbudget when the
-- prorated cost of everyone assigned to it exceeds its budget, where prorating
-- means charging each annual salary in proportion to the project's length
-- against a 365-day year — a six-month project costs half a salary.
-- Output: the title, the budget, and the total prorated expense rounded UP to
-- the next whole dollar. Only overbudget projects.
-- Sort by title.
--
-- Note on the wording: the prompt says employees are assigned "for particular
-- periods", but linkedin_emp_projects has two columns and no dates. There is
-- no per-employee period to read. Every employee on a project prorates by the
-- project's own duration. When the prose and the schema disagree, the schema
-- wins — the prose is somebody's intent, the schema is what exists.
--
-- Concept: integer division silently truncating inside an aggregate.
-- Why ::numeric on the SUM: salary is an integer, so SUM(salary) is bigint,
--   and bigint / bigint is INTEGER division in Postgres — it throws the
--   fraction away before the multiplication, and then the days multiply the
--   loss. Measured it directly: SUM(salary)/365 and SUM(salary)/365.0 return
--   different numbers on this data. No error, no warning, just a wrong column
--   that looks plausible.
-- Why HAVING and not WHERE: the filter compares a SUM, and WHERE runs before
--   rows are grouped, so the sum does not exist yet.
-- Why CEILING is safe inside HAVING here: budget is an integer, so
--   CEILING(x) > budget means CEILING(x) >= budget + 1, which holds only when
--   x > budget. It is equivalent to comparing the raw value — proven, not
--   assumed. That equivalence would break against a non-integer budget.
-- Why GROUP BY a.id and not just the title: id is the real key. Grouping by
--   title alone would merge two distinct projects that happen to share a name
--   and sum the employees of both into one row.

SELECT
    a.title,
    a.budget,
    CEILING((a.end_date - a.start_date) *
            (SUM(c.salary)::numeric / 365)) AS prorated_employee_expense
FROM linkedin_projects a
INNER JOIN linkedin_emp_projects b ON a.id = b.project_id
INNER JOIN linkedin_employees c ON b.emp_id = c.id
GROUP BY
    a.id,
    a.title,
    a.budget,
    a.end_date,
    a.start_date
HAVING CEILING((a.end_date - a.start_date) * (SUM(c.salary)::numeric / 365)) > a.budget
ORDER BY a.title ASC;

-- Gotcha: the expense expression is written twice, once in SELECT and once in
-- HAVING. On the first fix I added ::numeric to the SELECT copy and left the
-- HAVING copy dividing integers — so the query DISPLAYED the right number and
-- FILTERED on a truncated one. Truncation only shrinks, so projects that were
-- overbudget by a little vanished from the output while the visible column
-- looked correct. Duplicated logic drifts, and it drifted in under two minutes
-- with the bug fresh in my head. A CTE computing the expense once removes the
-- second copy and the whole class of error with it.
