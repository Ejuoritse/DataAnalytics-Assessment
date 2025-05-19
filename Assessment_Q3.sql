
-- 3. Account Inactivity Alert
SELECT
  p.id AS plan_id,               -- plan identifier
  p.owner_id AS owner_id,        -- customer identifier
  CASE 
    WHEN p.plan_type_id = 1 THEN 'Savings'
    WHEN p.plan_type_id = 2 THEN 'Investment'
    ELSE 'Other'
  END AS type,                   -- plan type label
  lt.last_tx_date AS last_transaction_date,  -- date of most recent successful tx
  DATEDIFF(CURDATE(), lt.last_tx_date) AS inactivity_days  -- days since last tx
FROM adashi_staging.plans_plan AS p
LEFT JOIN (
  -- subquery to find each plan’s latest successful transaction date
  SELECT
    s.plan_id,
    MAX(s.transaction_date) AS last_tx_date
  FROM adashi_staging.savings_savingsaccount AS s
  WHERE s.transaction_status = 'success'
  GROUP BY s.plan_id
) AS lt
  ON lt.plan_id = p.id
WHERE
  p.status_id = 1  -- only active plans
  AND (
    lt.last_tx_date IS NULL                      -- never transacted
    OR DATEDIFF(CURDATE(), lt.last_tx_date) > 365  -- or inactive over 1 year
  )
ORDER BY inactivity_days DESC;  -- longest inactivity first

