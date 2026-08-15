-- Problem: Find the Average Total Compensation by Title and Gender (StrataScratch)
-- Two tables: sf_employee holds one row per employee with a salary, a title and
-- a sex; sf_bonus holds bonus payments, keyed by worker_ref_id, and an employee
-- may appear there MORE THAN ONCE. Total compensation for an employee is their
-- salary plus the sum of all their bonuses. Employees with no bonus at all are
-- excluded from the calculation entirely.
-- Output: employee title, sex, and the average total compensation of that group.
--
-- Concept: collapse the many side BEFORE joining it.
-- Why the aggregate runs first: sf_bonus is one-to-many. Joining it raw repeats
--   the employee row once per bonus, which breaks the answer twice over — the
--   salary is counted again in every copy, and the AVG stops being "per employee"
--   and becomes "per bonus row", so employees with more bonuses weigh more.
--   Aggregating first turns the relationship into one-to-one and the rest is
--   arithmetic.
-- Why not the direct join: measured it on a fixture. One employee on 10000 with
--   three bonuses of 100/200/300 has a true compensation of 10600. The direct
--   join returns 10200 — it averages the three rows 10100, 10200, 10300 and
--   never adds the bonuses together at all. Low, plausible, and silent.
-- Why INNER and not LEFT: the prompt says to disregard employees without
--   bonuses. Once the bonuses are aggregated, an INNER join drops exactly those
--   employees on its own — no WHERE clause needed. When the shape of the query
--   enforces a requirement for free, that is usually a sign the shape is right.

SELECT e.employee_title,
       e.sex,
       AVG(e.salary + b.ttl_bonus) AS avg_compensation
FROM sf_employee e
INNER JOIN
  (SELECT worker_ref_id,
          SUM(bonus) AS ttl_bonus
    FROM sf_bonus
    GROUP BY worker_ref_id) b ON e.id = b.worker_ref_id
    GROUP BY employee_title, sex;

-- Gotcha: this query assumes sf_employee.id is unique. It is here, but nothing
-- in the SQL says so — if that table ever carried a duplicate employee, the
-- fan-out returns from the other side and the average inflates silently, with
-- no error. pandas can declare that assumption and enforce it (merge accepts
-- validate='1:1'); SQL has no equivalent, so in SQL the assumption only exists
-- if you write it down. This comment is where it lives.
