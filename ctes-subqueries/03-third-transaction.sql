-- Problem: Third Transaction (DataLemur / Uber — Ace the Data Science Interview #11)
-- Obtain the third transaction of every user. Output user id, spend and
-- transaction date.
--
-- Concept: ROW_NUMBER() + PARTITION BY + ORDER BY direction.
-- Why ROW_NUMBER: this is a chronological sequence per user, not a ranking with
-- ties to manage — each transaction gets a unique sequential position.
-- Why ORDER BY ASC: ASC numbers from the start of the timeline, so row 3 is
-- literally "the third transaction that happened". With DESC, row 3 would mean
-- "the third most recent" — and for a user with exactly 3 transactions that is
-- their FIRST one, the opposite of what the problem asks.

WITH ranked_transaction AS (
  SELECT
    user_id,
    spend,
    transaction_date,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY transaction_date ASC
    ) AS third_transaction
  FROM transactions
)
SELECT
  t.user_id,
  t.spend,
  t.transaction_date
FROM ranked_transaction AS t
WHERE third_transaction = 3;
