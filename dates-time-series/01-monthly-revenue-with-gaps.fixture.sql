-- Fixture for 01-monthly-revenue-with-gaps.sql
--
-- This problem is not from a practice platform, so the data ships with it.
-- A solution to a self-made problem is unverifiable without the rows it ran
-- against — including for me, six months from now.
--
--   createdb sqlgym && psql -d sqlgym -f 01-monthly-revenue-with-gaps.fixture.sql
--
-- The data is shaped to make three different kinds of empty month appear, so a
-- query that drops any of them fails visibly:
--   March     — orders exist, but every one is cancelled or refunded
--   July      — no orders at all
--   October   — a single refunded order
-- Plus one row in Dec 2024 and one in Jan 2026, to catch a year filter that
-- leaks at the boundaries.

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
  id          serial PRIMARY KEY,
  customer_id int           NOT NULL,
  ordered_at  date          NOT NULL,
  amount      numeric(10,2) NOT NULL,
  status      text          NOT NULL  -- 'completed' | 'refunded' | 'cancelled'
);

INSERT INTO orders (customer_id, ordered_at, amount, status) VALUES
 (1,'2025-01-08', 120.00,'completed'),(2,'2025-01-19',  80.50,'completed'),
 (3,'2025-01-25',  60.00,'cancelled'),
 (1,'2025-02-03', 200.00,'completed'),(4,'2025-02-14',  45.25,'completed'),
 (2,'2025-02-27',  90.00,'refunded'),
 (5,'2025-03-11', 300.00,'cancelled'),(3,'2025-03-22', 150.00,'refunded'),
 (1,'2025-04-02',  75.00,'completed'),
 (6,'2025-05-09', 410.00,'completed'),(2,'2025-05-15', 130.00,'completed'),
 (4,'2025-05-30',  20.00,'cancelled'),
 (3,'2025-06-18',  95.50,'completed'),
 (7,'2025-08-04', 260.00,'completed'),(1,'2025-08-21',  40.00,'completed'),
 (5,'2025-09-12', 180.00,'completed'),
 (2,'2025-10-07',  55.00,'refunded'),
 (6,'2025-11-11', 320.00,'completed'),(3,'2025-11-29', 210.75,'completed'),
 (4,'2025-12-24', 500.00,'completed'),
 (8,'2024-12-30', 999.00,'completed'),
 (9,'2026-01-02', 888.00,'completed');

-- Expected output — 12 rows:
--   2025-01-01 | 200.50 |
--   2025-02-01 | 245.25 | 200.50
--   2025-03-01 |      0 | 245.25
--   2025-04-01 |  75.00 |      0
--   2025-05-01 | 540.00 |  75.00
--   2025-06-01 |  95.50 | 540.00
--   2025-07-01 |      0 |  95.50
--   2025-08-01 | 300.00 |      0
--   2025-09-01 | 180.00 | 300.00
--   2025-10-01 |      0 | 180.00
--   2025-11-01 | 530.75 |      0
--   2025-12-01 | 500.00 | 530.75
