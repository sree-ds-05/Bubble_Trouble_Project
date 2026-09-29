-- ============================================================================
-- CITS1402 Project: Bubble Trouble
-- createViews.sql
--   Mission 5: View A (MonthlySales) and View B (MemberSummary)
-- ============================================================================

DROP VIEW IF EXISTS MonthlySales;
DROP VIEW IF EXISTS MemberSummary;

-- VIEW A: one row per month + store + product, priced lines only.
CREATE VIEW MonthlySales AS
SELECT
    strftime('%Y-%m', so.orderDate) AS orderMonth,
    st.storeName                    AS storeName,
    p.productName                   AS productName,
    SUM(oi.quantity)                AS totalQuantity,
    SUM(oi.lineTotal)               AS totalRevenue
FROM OrderItem oi
JOIN SalesOrder so ON so.orderId   = oi.orderId
JOIN Store st      ON st.storeId   = so.storeId
JOIN Product p     ON p.productId  = oi.productId
WHERE oi.lineTotal IS NOT NULL
GROUP BY orderMonth, st.storeId, st.storeName, p.productId, p.productName;

-- VIEW B: one row per member, including members who have never ordered.
CREATE VIEW MemberSummary AS
SELECT
    m.memberId                      AS memberId,
    m.memberName                    AS memberName,
    COUNT(DISTINCT so.orderId)      AS totalOrders,
    COALESCE(SUM(oi.quantity), 0)   AS totalDrinks,
    COALESCE(SUM(oi.lineTotal), 0)  AS totalSpent
FROM Member m
LEFT JOIN SalesOrder so ON so.memberId = m.memberId
LEFT JOIN OrderItem oi  ON oi.orderId  = so.orderId
GROUP BY m.memberId, m.memberName;
