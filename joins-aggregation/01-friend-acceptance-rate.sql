-- Problem: Friend Acceptance Rate (StrataScratch / Facebook)
-- Table fb_friend_requests holds one row per event: a sender, a receiver, a
-- date, and an action that is either 'sent' or 'accepted'. For every date on
-- which requests were sent, return the fraction of those requests that were
-- eventually accepted. A request is identified by the (sender, receiver) pair,
-- and its acceptance almost always lands on a LATER date than the send.
-- Output: the send date and its acceptance rate. A date on which requests were
-- sent and none were accepted is a rate of 0, not a missing row.
-- Sort by date.
--
-- Concept: aggregation vs existence in a filter.
-- Why COUNT of the nullable side: after the LEFT JOIN, an unaccepted request
--   carries NULL in every accepted_cte column. COUNT(column) skips NULLs, so
--   COUNT(a.user_id_sender) is the accepted count and COUNT(s.user_id_sender)
--   is the sent count — one pass, two counts, no correlated subquery.
-- Why not EXISTS: EXISTS answers "was this one accepted?", a per-row yes/no.
--   The question here is "what share of them were accepted?", which is a ratio
--   over a group. Existence cannot produce a denominator.
-- Why the join carries no date predicate: the two events are separated in
--   time (a1 -> b1 is sent on the 1st and accepted on the 5th). Joining on
--   s.date = a.date would match almost nothing and quietly return all zeros.
-- Why GROUP BY the send date: the denominator is "requests sent that day", so
--   every row must be attributed to when it was sent, never to when it was
--   accepted.

WITH sent_cte AS (
    SELECT date, user_id_sender, user_id_receiver
    FROM fb_friend_requests
    WHERE action = 'sent'
),
accepted_cte AS (
    SELECT user_id_sender, user_id_receiver
    FROM fb_friend_requests
    WHERE action = 'accepted'
)
SELECT
    s.date,
    COUNT(a.user_id_sender) * 1.0 / COUNT(s.user_id_sender) AS acceptance_rate
FROM sent_cte s
LEFT JOIN accepted_cte a
       ON s.user_id_sender   = a.user_id_sender
      AND s.user_id_receiver = a.user_id_receiver
GROUP BY s.date
ORDER BY s.date;

-- Gotcha 1: * 1.0 is not cosmetic. Both COUNTs are integers, and integer
-- division in Postgres truncates — without it every rate collapses to 0.
--
-- Gotcha 2: the first version ended in HAVING COUNT(a.user_id_sender) > 0, and
-- it passed the grader. It was still wrong. That clause drops any date where
-- nothing was accepted — a genuine 0% rate, and usually the most interesting
-- day in the report. It also contradicts the LEFT JOIN directly: the join is
-- there to keep unmatched sends, and the HAVING then throws them away. A LEFT
-- JOIN followed by a filter that demands a match is an INNER JOIN written in
-- two steps.
--
-- It passed because the grader's dataset has no date with sends and zero
-- acceptances, so the clause never fired. A local fixture with that exact day
-- caught it immediately: 3 rows without the HAVING, 2 with it. Passing a
-- grader means your output matched its data — not that the query is correct.
