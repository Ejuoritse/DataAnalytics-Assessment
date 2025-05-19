Question Explanations
1. High‑Value Customers with Multiple Products
Approach:  
- I did a join with users_customuser on savings_savingsaccount accounts and then on plans_plan  
- Used conditional aggregation ('SUM(CASE)) to count savings vs investments  
- Filtered in 'HAVING' for ≥1 of each and sorted by deposit sum  


2. Transaction Frequency Analysis
Approach:  
- CTE 'monthly_counts': This counted each user’s transaction per calendar month  
- CTE 'avg_per_month': This averaged those monthly counts per user  
- Then Classified users via 'CASE' into High/Medium/Low buckets  
- Aggregated for final summary of counts and averages  


 3. Account Inactivity Alert
Approach:  
- I created a Sub‑query to get each plan’s max successful transaction date  
- I did a Left‑join back to plans and then filtered for active plans with 'last_tx_date IS NULL OR >365 days ago'  
- I calculated 'inactivity_days' with 'DATEDIFF'  



 4. Customer Lifetime Value (CLV) Estimation
Approach:  
- I Computed each user’s tenure in months via TIMESTAMPDIFF and then I floored at 1 to avoid divide‑by‑zero  
- I Counted total successful transaction and computed avg profit per transaction as 0.1% of avg amount  
- I Applied CLV formula annualized over 12 months  
- I Rounded to two decimals place and then ordered by highest CLV  



## Challenges & Resolutions

1. Zero‑month Tenure  
   - Challenge: New users with 'created_on = CURDATE()' yielded zero months, risking division by zero.  
   - Resolution: I Wrapped 'TIMESTAMPDIFF' in 'GREATEST(...,1)' to floor tenure at 1 month.

2. Missing Transactions
   - Challenge: Plans with no transactions needed to show up in “inactivity” list.  
   - Resolution: I made use of a 'LEFT JOIN' and 'WHERE last_tx_date IS NULL' to capture those “never transacted” plans.

3. Custom Bucket Ordering  
   - Challenge: MySQL’s default alphabetical ORDER BY skewed frequency categories.  
   - Resolution: Used 'FIELD(...)' to enforce High → Medium → Low order.

4. Schema Name Mismatches  
   - Challenge: users_customuser was wrongly spelt, Initially joined 'user_customer' instead of 'users_customuser', causing 1146 errors.  
   - Resolution: Ensured all references included the correct schema ('adashi_staging.users_customuser') and did not rename it because in real life other process/report might reference table which would cause a process break.



