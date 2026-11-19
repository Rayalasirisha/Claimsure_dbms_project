USE claimsure;

-- 1. Claim ratio by policy type (claim count / policy count)
SELECT pt.type_name,
       COUNT(DISTINCT c.claim_id) AS total_claims,
       COUNT(DISTINCT p.policy_id) AS total_policies,
       ROUND(COUNT(DISTINCT c.claim_id) / COUNT(DISTINCT p.policy_id) * 100, 2) AS claim_ratio_pct
FROM policy_types pt
JOIN policies p ON p.policy_type_id = pt.policy_type_id
LEFT JOIN claims c ON c.policy_id = p.policy_id
GROUP BY pt.policy_type_id, pt.type_name
ORDER BY claim_ratio_pct DESC;

-- 2. Average settlement time in days
SELECT ROUND(AVG(DATEDIFF(s.settlement_date, c.filed_date)), 1) AS avg_settlement_days
FROM claims c JOIN settlements s ON s.claim_id = c.claim_id;

-- 3. Claims by status and total claimed amount
SELECT claim_status, COUNT(*) AS claim_count,
       ROUND(SUM(claim_amount),2) AS total_claim_amount
FROM claims GROUP BY claim_status ORDER BY claim_count DESC;

-- 4. Agent performance
SELECT a.agent_name, COUNT(DISTINCT p.policy_id) AS policies_sold,
       COUNT(DISTINCT c.claim_id) AS claims_handled,
       ROUND(SUM(COALESCE(s.settlement_amount,0)),2) AS settlement_value
FROM agents a
LEFT JOIN policies p ON p.agent_id=a.agent_id
LEFT JOIN claims c ON c.policy_id=p.policy_id
LEFT JOIN settlements s ON s.claim_id=c.claim_id
GROUP BY a.agent_id,a.agent_name ORDER BY policies_sold DESC;

-- 5. Lapsed policies by policy type
SELECT pt.type_name, COUNT(*) AS lapsed_policies
FROM policies p JOIN policy_types pt ON p.policy_type_id=pt.policy_type_id
WHERE p.policy_status='Lapsed'
GROUP BY pt.type_name ORDER BY lapsed_policies DESC;

-- 6. Monthly claim volume
SELECT DATE_FORMAT(filed_date,'%Y-%m') AS claim_month, COUNT(*) AS claims_filed
FROM claims GROUP BY DATE_FORMAT(filed_date,'%Y-%m')
ORDER BY claim_month;

-- 7. Demonstrate trigger: update one claim status, then inspect audit
UPDATE claims SET claim_status='Under Review' WHERE claim_id=1;
SELECT * FROM claim_status_audit WHERE claim_id=1;

-- 8. Query the view
SELECT * FROM vw_claim_summary LIMIT 10;
