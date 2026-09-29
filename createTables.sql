-- ============================================================================
-- CITS1402 Project: Bubble Trouble
-- createTables.sql
--   Mission 2: the eight tables, primary keys, foreign keys
--   Mission 3: business-rule CHECK constraints (BR1 - BR5)
-- ============================================================================

-- SQLite ignores foreign keys unless this is switched on (per connection).
PRAGMA foreign_keys = ON;

-- Drop children before parents so a clean re-run never breaks a foreign key.
DROP TABLE IF EXISTS Recipe;
DROP TABLE IF EXISTS OrderItem;
DROP TABLE IF EXISTS SalesOrder;
DROP TABLE IF EXISTS Ingredient;
DROP TABLE IF EXISTS SizeOption;
DROP TABLE IF EXISTS Product;
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS Store;

CREATE TABLE Store (
    storeId     TEXT NOT NULL PRIMARY KEY,
    storeName   TEXT NOT NULL,
    suburb      TEXT NOT NULL,
    openingDate TEXT NOT NULL
);

CREATE TABLE Member (
    memberId    INTEGER PRIMARY KEY,
    memberName  TEXT NOT NULL,
    memberEmail TEXT NOT NULL,
    cardNumber  TEXT NOT NULL,
    joinDate    TEXT NOT NULL,
    -- BR5: exactly 10 digits AND weighted sum 10*d1 + 9*d2 + ... + 1*d10 divisible by 11
    CONSTRAINT BR5_cardChecksum CHECK (
        length(cardNumber) = 10
        AND cardNumber GLOB '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        AND (
              10*CAST(substr(cardNumber,1,1)  AS INTEGER)
            +  9*CAST(substr(cardNumber,2,1)  AS INTEGER)
            +  8*CAST(substr(cardNumber,3,1)  AS INTEGER)
            +  7*CAST(substr(cardNumber,4,1)  AS INTEGER)
            +  6*CAST(substr(cardNumber,5,1)  AS INTEGER)
            +  5*CAST(substr(cardNumber,6,1)  AS INTEGER)
            +  4*CAST(substr(cardNumber,7,1)  AS INTEGER)
            +  3*CAST(substr(cardNumber,8,1)  AS INTEGER)
            +  2*CAST(substr(cardNumber,9,1)  AS INTEGER)
            +  1*CAST(substr(cardNumber,10,1) AS INTEGER)
        ) % 11 = 0
    )
);

CREATE TABLE Product (
    productId   TEXT NOT NULL PRIMARY KEY,
    productName TEXT NOT NULL,
    category    TEXT NOT NULL,
    basePrice   REAL NOT NULL,
    status      TEXT NOT NULL,
    -- BR1: price must be a number strictly greater than zero
    CONSTRAINT BR1_validPrice  CHECK (typeof(basePrice) IN ('integer','real') AND basePrice > 0),
    -- BR2: only two allowed statuses (case-sensitive)
    CONSTRAINT BR2_validStatus CHECK (status IN ('ACTIVE','DISCONTINUED'))
);

CREATE TABLE SizeOption (
    size          TEXT NOT NULL PRIMARY KEY,
    sizeSurcharge REAL NOT NULL
);

CREATE TABLE Ingredient (
    ingredientId   TEXT NOT NULL PRIMARY KEY,
    ingredientName TEXT NOT NULL,
    unit           TEXT NOT NULL,
    unitCost       REAL NOT NULL
);

CREATE TABLE SalesOrder (
    orderId   INTEGER PRIMARY KEY,
    memberId  INTEGER NOT NULL,
    storeId   TEXT NOT NULL,
    orderDate TEXT NOT NULL,
    orderTime TEXT NOT NULL,
    -- RESTRICT: a member/store that still has orders cannot be deleted
    FOREIGN KEY (memberId) REFERENCES Member(memberId)
        ON DELETE RESTRICT,
    FOREIGN KEY (storeId) REFERENCES Store(storeId)
        ON DELETE RESTRICT
);

CREATE TABLE OrderItem (
    orderId   INTEGER NOT NULL,
    lineNo    INTEGER NOT NULL,
    productId TEXT NOT NULL,
    size      TEXT NOT NULL,
    quantity  INTEGER NOT NULL,
    unitPrice REAL,              -- NULL allowed: Trigger A fills it in
    lineTotal REAL,              -- NULL allowed: Trigger B fills it in
    -- BR3: a whole number of drinks from 1 to 10
    CONSTRAINT BR3_validQuantity CHECK (typeof(quantity) = 'integer' AND quantity BETWEEN 1 AND 10),
    -- line numbers restart in every order, so both columns form the key
    PRIMARY KEY (orderId, lineNo),
    -- CASCADE: deleting an order deletes its lines
    FOREIGN KEY (orderId) REFERENCES SalesOrder(orderId)
        ON DELETE CASCADE,
    -- RESTRICT: products and sizes with sales history cannot be deleted
    FOREIGN KEY (productId) REFERENCES Product(productId)
        ON DELETE RESTRICT,
    FOREIGN KEY (size) REFERENCES SizeOption(size)
        ON DELETE RESTRICT
);

CREATE TABLE Recipe (
    productId      TEXT NOT NULL,
    ingredientId   TEXT NOT NULL,
    amountRequired REAL NOT NULL,
    -- BR4: amount must be a number strictly greater than zero
    CONSTRAINT BR4_validAmount CHECK (typeof(amountRequired) IN ('integer','real') AND amountRequired > 0),
    -- one row per (product, ingredient) pair
    PRIMARY KEY (productId, ingredientId),
    FOREIGN KEY (productId) REFERENCES Product(productId)
        ON DELETE RESTRICT,
    FOREIGN KEY (ingredientId) REFERENCES Ingredient(ingredientId)
        ON DELETE RESTRICT
);
