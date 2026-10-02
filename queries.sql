-- ============================================================================
-- CITS1402 Relational Database Management Systems
-- Project: Bubble Trouble
-- Mission 6: Business Queries
-- File: queries.sql
--
-- STUDENT INSTRUCTIONS
-- 1. Do NOT change the task headings, task numbers, or PRINT statements.
-- 2. Write exactly ONE SQLite query in each STUDENT QUERY area.
-- 3. Every query must end with a semicolon (;).
-- 4. Your query must work for ANY valid Bubble Trouble database.
-- 5. Do NOT hard-code answers from sample data.
-- 6. Do NOT create, alter, insert, update, or delete data in this file.
--
-- Recommended execution:
--     sqlite3 BubbleTrouble.db < queries.sql
-- ============================================================================

.headers on
.mode column
.nullvalue NULL

.print ''
.print '======================================================================'
-- IMPORTANT: Replace 12345678 below with your Student Number
.print ' Student ID: 25252848, 24975886'
.print ' CITS1402 - BUBBLE TROUBLE'
.print ' MISSION 6: BUSINESS QUERIES'
.print '======================================================================'
.print ''
.print 'Each task heading is followed by the output of the student query.'
.print ''

-- ============================================================================
-- Q1 - CURRENT MENU                                                        
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q1 - CURRENT MENU'
.print '----------------------------------------------------------------------'
.print 'Task: List productId, productName, category and basePrice for all'
.print '      ACTIVE products. Sort by category, then productName.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q1: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q1
SELECT productId, productName, category, basePrice
FROM Product
WHERE status = 'ACTIVE'
ORDER BY category, productName;
-- <<< END STUDENT QUERY Q1 >>>

.print '------------------------------ END Q1 ---------------------------------'

-- ============================================================================
-- Q2 - INGREDIENT REACH                                                   
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q2 - INGREDIENT REACH'
.print '----------------------------------------------------------------------'
.print 'Task: For each ingredient, display the ingredient name and the number'
.print '      of DISTINCT products whose recipes use it.'
.print '      Include ingredients that are currently used by no product.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q2: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q2
SELECT i.ingredientName,
       COUNT(DISTINCT r.productId) AS numProducts
FROM Ingredient i
LEFT JOIN Recipe r ON r.ingredientId = i.ingredientId
GROUP BY i.ingredientId, i.ingredientName
ORDER BY numProducts DESC, i.ingredientName;
-- <<< END STUDENT QUERY Q2 >>>

.print '------------------------------ END Q2 ---------------------------------'

-- ============================================================================
-- Q3 - STORE PERFORMANCE                                                
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q3 - STORE PERFORMANCE'
.print '----------------------------------------------------------------------'
.print 'Task: For each store, display the store name, number of DISTINCT orders'
.print '      and total revenue from priced OrderItem rows.'
.print '      Include stores that have not yet processed an order.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q3: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q3
SELECT s.storeName,
       COUNT(DISTINCT so.orderId)     AS numOrders,
       COALESCE(SUM(oi.lineTotal), 0) AS totalRevenue
FROM Store s
LEFT JOIN SalesOrder so ON so.storeId = s.storeId
LEFT JOIN OrderItem oi  ON oi.orderId = so.orderId
GROUP BY s.storeId, s.storeName
ORDER BY totalRevenue DESC, s.storeName;
-- <<< END STUDENT QUERY Q3 >>>

.print '------------------------------ END Q3 ---------------------------------'

-- ============================================================================
-- Q4 - POPULAR PRODUCTS                                                
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q4 - POPULAR PRODUCTS'
.print '----------------------------------------------------------------------'
.print 'Task: Display each product whose total quantity sold is at least'
.print '      20 drinks. Show productName and total quantity sold.'
.print '      Display the most popular product first.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q4: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q4
SELECT p.productName,
       SUM(oi.quantity) AS totalQuantity
FROM Product p
JOIN OrderItem oi ON oi.productId = p.productId
GROUP BY p.productId, p.productName
HAVING SUM(oi.quantity) >= 20
ORDER BY totalQuantity DESC, p.productName;
-- <<< END STUDENT QUERY Q4 >>>

.print '------------------------------ END Q4 ---------------------------------'

-- ============================================================================
-- Q5 - ACTIVE PRODUCTS NEVER ORDERED                                   
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q5 - ACTIVE PRODUCTS NEVER ORDERED'
.print '----------------------------------------------------------------------'
.print 'Task: Using a SUBQUERY, find all ACTIVE products that have never'
.print '      appeared in any OrderItem. Return productId and productName.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q5: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q5
SELECT productId, productName
FROM Product
WHERE status = 'ACTIVE'
  AND productId NOT IN (SELECT productId FROM OrderItem)
ORDER BY productId;
-- <<< END STUDENT QUERY Q5 >>>

.print '------------------------------ END Q5 ---------------------------------'

-- ============================================================================
-- Q6 - HIGH-VALUE MEMBERS                                              
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q6 - HIGH-VALUE MEMBERS'
.print '----------------------------------------------------------------------'
.print 'Task: Find members whose total spending is STRICTLY GREATER than the'
.print '      average total spending of members who have spent more than zero.'
.print '      Return memberName and total spending.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q6: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q6
SELECT m.memberName,
       SUM(oi.lineTotal) AS totalSpent
FROM Member m
JOIN SalesOrder so ON so.memberId = m.memberId
JOIN OrderItem oi  ON oi.orderId  = so.orderId
GROUP BY m.memberId, m.memberName
HAVING SUM(oi.lineTotal) > (
    SELECT AVG(memberTotal)
    FROM (SELECT SUM(oi2.lineTotal) AS memberTotal
          FROM SalesOrder so2
          JOIN OrderItem oi2 ON oi2.orderId = so2.orderId
          GROUP BY so2.memberId
          HAVING SUM(oi2.lineTotal) > 0)
)
ORDER BY totalSpent DESC, m.memberName;
-- <<< END STUDENT QUERY Q6 >>>

.print '------------------------------ END Q6 ---------------------------------'

-- ============================================================================
-- Q7 - STORE BEST SELLERS                                              
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q7 - STORE BEST SELLERS'
.print '----------------------------------------------------------------------'
.print 'Task: For EACH store, return the product or products with the greatest'
.print '      total quantity sold at that store. TIES MUST BE RETAINED.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q7: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q7
WITH StoreProductQty AS (
    SELECT so.storeId, oi.productId, SUM(oi.quantity) AS totalQuantity
    FROM SalesOrder so
    JOIN OrderItem oi ON oi.orderId = so.orderId
    GROUP BY so.storeId, oi.productId
)
SELECT s.storeName, p.productName, spq.totalQuantity
FROM StoreProductQty spq
JOIN Store s   ON s.storeId   = spq.storeId
JOIN Product p ON p.productId = spq.productId
WHERE spq.totalQuantity = (SELECT MAX(x.totalQuantity)
                           FROM StoreProductQty x
                           WHERE x.storeId = spq.storeId)
ORDER BY s.storeName, p.productName;
-- <<< END STUDENT QUERY Q7 >>>

.print '------------------------------ END Q7 ---------------------------------'

-- ============================================================================
-- Q8 - ABOVE-CATEGORY PERFORMANCE                                     
-- ============================================================================
.print ''
.print '----------------------------------------------------------------------'
.print 'Q8 - ABOVE-CATEGORY PERFORMANCE'
.print '----------------------------------------------------------------------'
.print 'Task: Using a CORRELATED SUBQUERY, find products whose total quantity'
.print '      sold is STRICTLY GREATER than the average total quantity sold by'
.print '      products in the SAME category.'
.print '      Return productName, category and total quantity sold.'
.print '----------------------------------------------------------------------'

-- >>> STUDENT QUERY Q8: WRITE YOUR SINGLE SQLITE QUERY BELOW >>>
-- Q8
SELECT p.productName,
       p.category,
       SUM(oi.quantity) AS totalQuantity
FROM Product p
JOIN OrderItem oi ON oi.productId = p.productId
GROUP BY p.productId, p.productName, p.category
HAVING SUM(oi.quantity) > (
    SELECT AVG(catProduct.productTotal)
    FROM (SELECT COALESCE(SUM(oi2.quantity), 0) AS productTotal
          FROM Product p2
          LEFT JOIN OrderItem oi2 ON oi2.productId = p2.productId
          WHERE p2.category = p.category
          GROUP BY p2.productId) AS catProduct
)
ORDER BY p.category, totalQuantity DESC;
-- <<< END STUDENT QUERY Q8 >>>

.print '------------------------------ END Q8 ---------------------------------'

.print ''
.print '======================================================================'
.print ' END OF MISSION 6'
.print ' Review the output above carefully before submitting.'
.print '======================================================================'
.print ''
