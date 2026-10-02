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

-- Chen: imported sale, supplied price 4.00 kept
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

-- Alice: drink 10 (free)
INSERT INTO SalesOrder VALUES (1004, 1, 'S01', '2026-07-10', '10:00');
INSERT INTO OrderItem  VALUES (1004, 1, 'P01', 'M', 1, NULL, NULL);   -- 0 x 6.50 = 0.00

-- Eli: drinks 1-8
INSERT INTO SalesOrder VALUES (1005, 5, 'S01', '2026-07-20', '12:10');
INSERT INTO OrderItem  VALUES (1005, 1, 'P01', 'M', 6, NULL, NULL);   -- 6 x 6.50 = 39.00
INSERT INTO OrderItem  VALUES (1005, 2, 'P03', 'S', 2, NULL, NULL);   -- 2 x 6.00 = 12.00

-- Alice: drinks 11-13
INSERT INTO SalesOrder VALUES (1006, 1, 'S01', '2026-08-02', '11:45');
INSERT INTO OrderItem  VALUES (1006, 1, 'P02', 'L', 3, NULL, NULL);   -- 3 x 7.50 = 22.50

-- Eli: drinks 9-19 (drink 10 free)
INSERT INTO SalesOrder VALUES (1007, 5, 'S02', '2026-08-09', '15:40');
INSERT INTO OrderItem  VALUES (1007, 1, 'P01', 'L', 5, NULL, NULL);   -- 4 x 7.00 = 28.00
INSERT INTO OrderItem  VALUES (1007, 2, 'P02', 'S', 4, NULL, NULL);   -- 4 x 6.50 = 26.00
INSERT INTO OrderItem  VALUES (1007, 3, 'P06', 'M', 2, NULL, NULL);   -- 2 x 7.00 = 14.00

-- Bob: drinks 9-13 (drink 10 free)
INSERT INTO SalesOrder VALUES (1008, 2, 'S02', '2026-08-15', '13:05');
INSERT INTO OrderItem  VALUES (1008, 1, 'P04', 'L', 3, NULL, NULL);   -- 2 x 6.50 = 13.00
INSERT INTO OrderItem  VALUES (1008, 2, 'P05', 'S', 2, NULL, NULL);   -- 2 x 5.50 = 11.00

-- Price change: P01 6.00 -> 6.50
UPDATE Product SET basePrice = 6.50 WHERE productId = 'P01';

-- Eli: drinks 20-30 (drinks 20 and 30 free)
INSERT INTO SalesOrder VALUES (1009, 5, 'S01', '2026-09-12', '17:25');
INSERT INTO OrderItem  VALUES (1009, 1, 'P01', 'S', 6, NULL, NULL);   -- 5 x 6.50 = 32.50
INSERT INTO OrderItem  VALUES (1009, 2, 'P02', 'L', 5, NULL, NULL);   -- 4 x 7.50 = 30.00
