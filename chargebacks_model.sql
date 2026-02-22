-- Objective: Identify high-probability winnable disputes to prioritize manual review
-- Impact: Supports a 15% reduction in net losses by automating low-value concessions

WITH DisputeSummary AS (
    SELECT 
        transaction_id,
        customer_id,
        order_amount,
        reason_code,
        -- Creating a flag for disputes with verifiable tracking info
        CASE 
            WHEN tracking_number IS NOT NULL AND shipping_status = 'Delivered' THEN 1 
            ELSE 0 
        END AS has_strong_evidence
    FROM raw_dispute_data
),
WinRateByReason AS (
    SELECT 
        reason_code,
        AVG(CASE WHEN status = 'Won' THEN 1.0 ELSE 0.0 END) AS historical_win_rate
    FROM historical_disputes
    GROUP BY reason_code
)

SELECT 
    d.transaction_id,
    d.order_amount,
    d.reason_code,
    w.historical_win_rate,
    -- Business Logic: Prioritize if evidence is strong AND the reason code is winnable
    CASE 
        WHEN d.has_strong_evidence = 1 AND w.historical_win_rate > 0.6 THEN 'High Priority'
        WHEN d.order_amount > 500 THEN 'Manual Review Required'
        ELSE 'Auto-Concede / Low Priority'
    END AS dispute_strategy
FROM DisputeSummary d
JOIN WinRateByReason w ON d.reason_code = w.reason_code
ORDER BY d.order_amount DESC;
