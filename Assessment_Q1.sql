-- 1. High‑Value Customers with Multiple Products
SELECT 
    u.id AS owner_id,  -- customer identifier
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- customer full name
    -- count of savings plans per customer
    SUM(CASE WHEN p.plan_type_id = 1 THEN 1 ELSE 0 END) AS savings_count,
    -- count of investment plans per customer
    SUM(CASE WHEN p.plan_type_id = 2 THEN 1 ELSE 0 END) AS investment_count,
    -- total amount deposited across all plans
    SUM(s.confirmed_amount) AS total_deposits
FROM adashi_staging.users_customuser AS u
JOIN adashi_staging.savings_savingsaccount AS s 
  ON s.owner_id = u.id
JOIN adashi_staging.plans_plan AS p 
  ON p.id = s.plan_id
WHERE
    s.transaction_status = 'success'  -- only include successful (funded) transactions
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    savings_count >= 1                -- at least one savings plan
    AND investment_count >= 1         -- at least one investment plan
ORDER BY 
    total_deposits DESC;              -- highest depositors first
