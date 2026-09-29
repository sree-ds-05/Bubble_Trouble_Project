PRAGMA foreign_keys = ON;

DROP TRIGGER IF EXISTS trg_orderitem_price;
DROP TRIGGER IF EXISTS trg_orderitem_loyalty;

-- TRIGGER B: loyalty reward (every 10th drink is free).
-- Created FIRST so that it FIRES SECOND (SQLite fires same-event
-- triggers in reverse creation order).
CREATE TRIGGER trg_orderitem_loyalty
AFTER INSERT ON OrderItem
WHEN NEW.lineTotal IS NULL
BEGIN
    UPDATE OrderItem
    SET lineTotal = (
        SELECT
            CASE
                WHEN (prior.priorQty / 10) < ((prior.priorQty + NEW.quantity) / 10)
                    THEN (NEW.quantity - 1) * oi.unitPrice
                ELSE NEW.quantity * oi.unitPrice
            END
        FROM
            (SELECT COALESCE(SUM(oi2.quantity), 0) AS priorQty
             FROM OrderItem oi2
             JOIN SalesOrder so2 ON oi2.orderId = so2.orderId
             WHERE so2.memberId = (SELECT memberId FROM SalesOrder WHERE orderId = NEW.orderId)
               AND NOT (oi2.orderId = NEW.orderId AND oi2.lineNo = NEW.lineNo)
            ) AS prior,
            (SELECT unitPrice FROM OrderItem WHERE orderId = NEW.orderId AND lineNo = NEW.lineNo) AS oi
    )
    WHERE orderId = NEW.orderId AND lineNo = NEW.lineNo;
END;

-- TRIGGER A: automatic historical pricing.
-- Created SECOND so that it FIRES FIRST.
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