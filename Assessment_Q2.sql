
-- 2. Transaction Frequency Analysis
WITH monthly_counts AS (
  -- count transactions per customer, per month
  SELECT
    u.id AS customer_id,
    DATE_FORMAT(s.transaction_date, '%Y-%m') AS 'year_month',  -- e.g. '2023-08'
    COUNT(*) AS tx_count                                    -- number of transaction in that month
  FROM adashi_staging.users_customuser AS u
  JOIN adashi_staging.savings_savingsaccount AS s
    ON s.owner_id = u.id
  WHERE
    s.transaction_status = 'success'
  GROUP BY
    u.id,
    DATE_FORMAT(s.transaction_date, '%Y-%m')
),

avg_per_month AS (
  -- compute average monthly transactions per customer
  SELECT
    customer_id,
    AVG(tx_count) AS avg_tx_per_month
  FROM monthly_counts
  GROUP BY customer_id
),

classified AS (
  -- assign frequency segment based on average tx/month
  SELECT
    a.customer_id,
    ROUND(a.avg_tx_per_month, 2) AS avg_tx_per_month,
    CASE
      WHEN a.avg_tx_per_month >= 10 THEN 'High Frequency'
      WHEN a.avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'Low Frequency'
    END AS frequency_category
  FROM avg_per_month AS a
)

-- summary: count of customers and average tx/month per segment
SELECT
  frequency_category,
  COUNT(*)                        AS customer_count,               -- customers in each bucket
  ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month  -- segment’s avg tx/month
FROM classified
GROUP BY frequency_category
ORDER BY 
  FIELD(frequency_category, 'High Frequency','Medium Frequency','Low Frequency');  -- custom ordering

