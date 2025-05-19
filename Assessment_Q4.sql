
-- 4. Customer Lifetime Value (CLV) Estimation
WITH customer_stats AS (
  SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- customer full name
    -- months since signup, minimum 1 to avoid division by zero
    GREATEST(TIMESTAMPDIFF(MONTH, u.created_on, CURDATE()), 1) AS tenure_months,
    COUNT(*) AS total_transaction,                   -- total successful transactions
    AVG(s.confirmed_amount) * 0.001 AS avg_profit_per_transaction  -- avg profit = 0.1% of tx value
  FROM adashi_staging.users_customuser AS u
  JOIN adashi_staging.savings_savingsaccount AS s
    ON s.owner_id = u.id
  WHERE
    s.transaction_status = 'success'
  GROUP BY
    u.id, u.first_name, u.last_name, u.created_on
)

-- compute annualized CLV and sort
SELECT
  customer_id,
  name,
  tenure_months,
  total_transaction,
  ROUND(
    (total_transaction / tenure_months) * 12 * avg_profit_per_transaction,
    2
  ) AS estimated_clv  -- estimated customer lifetime value
FROM customer_stats
ORDER BY estimated_clv DESC;     -- highest CLV first
