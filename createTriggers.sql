-- ============================================================================
-- CITS1402 Project: Bubble Trouble
-- createTriggers.sql
--   Mission 4: Trigger A (automatic historical pricing)
--              Trigger B (Bubble Rewards - every 10th drink is free)
-- ============================================================================

PRAGMA foreign_keys = ON;

DROP TRIGGER IF EXISTS trg_orderitem_price;
DROP TRIGGER IF EXISTS trg_orderitem_loyalty;

-- TRIGGER A: automatic historical pricing.
-- Runs only when the new line arrives WITHOUT a unitPrice and copies today's
-- menu price (basePrice + sizeSurcharge) into that ONE new line.
-- A unitPrice that was supplied is never overwritten.
CREATE TRIGGER trg_orderitem_price
AFTER INSERT ON OrderItem
WHEN NEW.unitPrice IS NULL
BEGIN
    UPDATE OrderItem
    SET unitPrice = (
        SELECT p.basePrice + s.sizeSurcharge
        FROM Product p, SizeOption s
        WHERE p.productId = NEW.productId
          AND s.size = NEW.size
    )
    WHERE orderId = NEW.orderId AND lineNo = NEW.lineNo;
END;

-- TRIGGER B: Bubble Rewards.
-- Runs only when the new line arrives WITHOUT a lineTotal.
-- Counts the member's earlier drinks (all stores, all orders). If this line
-- reaches a 10th/20th/30th... drink, one drink on the line is free.
-- The price used is the supplied unitPrice, otherwise the same menu price
-- Trigger A uses, so the answer is right whichever trigger SQLite runs first.
CREATE TRIGGER trg_orderitem_loyalty
AFTER INSERT ON OrderItem
WHEN NEW.lineTotal IS NULL
BEGIN
    UPDATE OrderItem
    SET lineTotal = (
        SELECT
            CASE
                -- integer division: did we cross a multiple of 10?
                WHEN (prior.priorQty / 10) < ((prior.priorQty + NEW.quantity) / 10)
                    THEN (NEW.quantity - 1) * price.unitPrice
                ELSE NEW.quantity * price.unitPrice
            END
        FROM
            -- drinks this member bought before this line
            (SELECT COALESCE(SUM(oi2.quantity), 0) AS priorQty
             FROM OrderItem oi2
             JOIN SalesOrder so2 ON oi2.orderId = so2.orderId
             WHERE so2.memberId = (SELECT memberId FROM SalesOrder WHERE orderId = NEW.orderId)
               AND NOT (oi2.orderId = NEW.orderId AND oi2.lineNo = NEW.lineNo)
            ) AS prior,
            -- unit price for this line
            (SELECT COALESCE(NEW.unitPrice, p.basePrice + s.sizeSurcharge) AS unitPrice
             FROM Product p, SizeOption s
             WHERE p.productId = NEW.productId
               AND s.size = NEW.size
            ) AS price
    )
    WHERE orderId = NEW.orderId AND lineNo = NEW.lineNo;
END;
