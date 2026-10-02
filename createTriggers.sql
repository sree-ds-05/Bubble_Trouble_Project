PRAGMA foreign_keys = ON;

DROP TRIGGER IF EXISTS trg_orderitem_price;
DROP TRIGGER IF EXISTS trg_orderitem_loyalty;

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

CREATE TRIGGER trg_orderitem_loyalty
AFTER INSERT ON OrderItem
WHEN NEW.lineTotal IS NULL
BEGIN
    UPDATE OrderItem
    SET lineTotal = (
        SELECT
            CASE
                WHEN (prior.priorQty / 10) < ((prior.priorQty + NEW.quantity) / 10)
                    THEN (NEW.quantity - 1) * price.unitPrice
                ELSE NEW.quantity * price.unitPrice
            END
        FROM
            (SELECT COALESCE(SUM(oi2.quantity), 0) AS priorQty
             FROM OrderItem oi2
             JOIN SalesOrder so2 ON oi2.orderId = so2.orderId
             WHERE so2.memberId = (SELECT memberId FROM SalesOrder WHERE orderId = NEW.orderId)
               AND NOT (oi2.orderId = NEW.orderId AND oi2.lineNo = NEW.lineNo)
            ) AS prior,
            (SELECT COALESCE(NEW.unitPrice, p.basePrice + s.sizeSurcharge) AS unitPrice
             FROM Product p, SizeOption s
             WHERE p.productId = NEW.productId
               AND s.size = NEW.size
            ) AS price
    )
    WHERE orderId = NEW.orderId AND lineNo = NEW.lineNo;
END;
