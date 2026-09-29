-- ============================================================================
-- CITS1402 Project: Bubble Trouble
-- testData.sql  -  OUR OWN small, hand-checkable test data.
-- NOT part of the submission ZIP. Used for testing and for the demonstration.
--
-- Run order (from a fresh database):
--   sqlite3 BubbleTrouble.db ".read createTables.sql" ".read createTriggers.sql" \
--                            ".read createViews.sql"  ".read testData.sql"
--   sqlite3 BubbleTrouble.db < queries.sql
--
-- Built-in edge cases:
--   * Store S03 has no orders          (Q3 must still show it)
--   * Member 4 (Dana) has no orders    (MemberSummary must still show her)
--   * Ingredient I10 is in no recipe   (Q2 must still show it with 0)
--   * Product P07 is ACTIVE but never ordered (Q5)
--   * Product P08 is DISCONTINUED but has old sales
--   * Alice's 10th drink is a quantity-1 line          -> lineTotal 0
--   * Bob's 10th drink is inside a quantity-3 line     -> only 2 charged
--   * P02 sells exactly 20 drinks      (Q4 "at least 20" boundary)
--   * Store S01: P01 and P02 tie on 16 (Q7 must keep both)
--   * P01 price changes before order 1009 (old lines keep the old price)
-- ============================================================================

PRAGMA foreign_keys = ON;

INSERT INTO Store VALUES
    ('S01', 'Perth CBD',         'Perth',     '2024-03-01'),
    ('S02', 'Freo Wharf',        'Fremantle', '2025-01-15'),
    ('S03', 'Joondalup Central', 'Joondalup', '2026-09-01');

INSERT INTO Member VALUES
    (1, 'Alice Tan', 'alice@example.com', '0830166130', '2025-01-10'),
    (2, 'Bob Singh', 'bob@example.com',   '1860913903', '2025-02-14'),
    (3, 'Chen Wei',  'chen@example.com',  '9960308243', '2025-03-03'),
    (4, 'Dana Lee',  'dana@example.com',  '6281948211', '2026-08-20'),
    (5, 'Eli Novak', 'eli@example.com',   '5264579466', '2025-05-05');

INSERT INTO Product VALUES
    ('P01', 'Pearl Milk Tea',         'Milk Tea',  6.00, 'ACTIVE'),
    ('P02', 'Brown Sugar Milk Tea',   'Milk Tea',  6.50, 'ACTIVE'),
    ('P03', 'Taro Milk Tea',          'Milk Tea',  6.00, 'ACTIVE'),
    ('P04', 'Mango Green Tea',        'Fruit Tea', 5.50, 'ACTIVE'),
    ('P05', 'Passionfruit Green Tea', 'Fruit Tea', 5.50, 'ACTIVE'),
    ('P06', 'Matcha Latte',           'Latte',     6.50, 'ACTIVE'),
    ('P07', 'Lychee Oolong',          'Fruit Tea', 5.00, 'ACTIVE'),
    ('P08', 'Winter Melon Tea',       'Classic',   4.50, 'DISCONTINUED');

INSERT INTO SizeOption VALUES
    ('S', 0.00),
    ('M', 0.50),
    ('L', 1.00);

INSERT INTO Ingredient VALUES
    ('I01', 'Black Tea',          'g',  0.020),
    ('I02', 'Fresh Milk',         'ml', 0.003),
    ('I03', 'Tapioca Pearl',      'g',  0.010),
    ('I04', 'Brown Sugar Syrup',  'ml', 0.015),
    ('I05', 'Green Tea',          'g',  0.030),
    ('I06', 'Mango Syrup',        'ml', 0.020),
    ('I07', 'Matcha Powder',      'g',  0.120),
    ('I08', 'Taro Powder',        'g',  0.050),
    ('I09', 'Passionfruit Syrup', 'ml', 0.020),
    ('I10', 'Cheese Foam',        'ml', 0.040),
    ('I11', 'Oolong Tea',         'g',  0.040),
    ('I12', 'Lychee Syrup',       'ml', 0.025),
    ('I13', 'Winter Melon Syrup', 'ml', 0.020);

INSERT INTO Recipe VALUES
    ('P01', 'I01', 8),   ('P01', 'I02', 150), ('P01', 'I03', 50),
    ('P02', 'I01', 8),   ('P02', 'I02', 150), ('P02', 'I03', 50), ('P02', 'I04', 30),
    ('P03', 'I02', 150), ('P03', 'I03', 50),  ('P03', 'I08', 25),
    ('P04', 'I05', 6),   ('P04', 'I06', 40),
    ('P05', 'I05', 6),   ('P05', 'I09', 40),
    ('P06', 'I02', 200), ('P06', 'I07', 5),
    ('P07', 'I11', 6),   ('P07', 'I12', 40),
    ('P08', 'I01', 5),   ('P08', 'I13', 40);

-- Orders are inserted in date order; lines in increasing lineNo.
-- unitPrice and lineTotal are left NULL so the triggers fill them in,
-- except order 1000, an imported historical sale with its own unitPrice.

-- Chen: imported old sale, historical price 4.00 kept (menu price is now 4.50)
INSERT INTO SalesOrder VALUES (1000, 3, 'S02', '2026-06-20', '12:00');
INSERT INTO OrderItem  VALUES (1000, 1, 'P08', 'S', 2, 4.00, NULL);   -- 8.00

-- Alice: drinks 1-5
INSERT INTO SalesOrder VALUES (1001, 1, 'S01', '2026-07-01', '09:15');
INSERT INTO OrderItem  VALUES (1001, 1, 'P01', 'L', 3, NULL, NULL);   -- 3 x 7.00 = 21.00
INSERT INTO OrderItem  VALUES (1001, 2, 'P04', 'M', 2, NULL, NULL);   -- 2 x 6.00 = 12.00

-- Bob: drinks 1-8
INSERT INTO SalesOrder VALUES (1002, 2, 'S01', '2026-07-03', '16:20');
INSERT INTO OrderItem  VALUES (1002, 1, 'P02', 'M', 8, NULL, NULL);   -- 8 x 7.00 = 56.00

-- Alice: drinks 6-9
INSERT INTO SalesOrder VALUES (1003, 1, 'S02', '2026-07-05', '14:30');
INSERT INTO OrderItem  VALUES (1003, 1, 'P06', 'S', 4, NULL, NULL);   -- 4 x 6.50 = 26.00

-- Alice: drink 10 -> FREE (loyalty boundary, quantity 1)
INSERT INTO SalesOrder VALUES (1004, 1, 'S01', '2026-07-10', '10:00');
INSERT INTO OrderItem  VALUES (1004, 1, 'P01', 'M', 1, NULL, NULL);   -- 0 x 6.50 = 0.00

-- Eli: drinks 1-8
INSERT INTO SalesOrder VALUES (1005, 5, 'S01', '2026-07-20', '12:10');
INSERT INTO OrderItem  VALUES (1005, 1, 'P01', 'M', 6, NULL, NULL);   -- 6 x 6.50 = 39.00
INSERT INTO OrderItem  VALUES (1005, 2, 'P03', 'S', 2, NULL, NULL);   -- 2 x 6.00 = 12.00

-- Alice: drinks 11-13
INSERT INTO SalesOrder VALUES (1006, 1, 'S01', '2026-08-02', '11:45');
INSERT INTO OrderItem  VALUES (1006, 1, 'P02', 'L', 3, NULL, NULL);   -- 3 x 7.50 = 22.50

-- Eli: drinks 9-19 (drink 10 is inside the first line)
INSERT INTO SalesOrder VALUES (1007, 5, 'S02', '2026-08-09', '15:40');
INSERT INTO OrderItem  VALUES (1007, 1, 'P01', 'L', 5, NULL, NULL);   -- 4 x 7.00 = 28.00
INSERT INTO OrderItem  VALUES (1007, 2, 'P02', 'S', 4, NULL, NULL);   -- 4 x 6.50 = 26.00
INSERT INTO OrderItem  VALUES (1007, 3, 'P06', 'M', 2, NULL, NULL);   -- 2 x 7.00 = 14.00

-- Bob: drinks 9-13 (drink 10 is inside a quantity-3 line -> multi-quantity reward)
INSERT INTO SalesOrder VALUES (1008, 2, 'S02', '2026-08-15', '13:05');
INSERT INTO OrderItem  VALUES (1008, 1, 'P04', 'L', 3, NULL, NULL);   -- 2 x 6.50 = 13.00
INSERT INTO OrderItem  VALUES (1008, 2, 'P05', 'S', 2, NULL, NULL);   -- 2 x 5.50 = 11.00

-- Menu price change: Pearl Milk Tea goes from 6.00 to 6.50.
-- Earlier P01 lines must keep their old unitPrice.
UPDATE Product SET basePrice = 6.50 WHERE productId = 'P01';

-- Eli: drinks 20-30 (drink 20 in line 1, drink 30 in line 2)
INSERT INTO SalesOrder VALUES (1009, 5, 'S01', '2026-09-12', '17:25');
INSERT INTO OrderItem  VALUES (1009, 1, 'P01', 'S', 6, NULL, NULL);   -- 5 x 6.50 = 32.50
INSERT INTO OrderItem  VALUES (1009, 2, 'P02', 'L', 5, NULL, NULL);   -- 4 x 7.50 = 30.00
