PRAGMA foreign_keys = ON;

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
    CONSTRAINT BR1_validPrice  CHECK (typeof(basePrice) IN ('integer','real') AND basePrice > 0),
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
    unitPrice REAL,
    lineTotal REAL,
    CONSTRAINT BR3_validQuantity CHECK (typeof(quantity) = 'integer' AND quantity BETWEEN 1 AND 10),
    PRIMARY KEY (orderId, lineNo),
    FOREIGN KEY (orderId) REFERENCES SalesOrder(orderId)
        ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES Product(productId)
        ON DELETE RESTRICT,
    FOREIGN KEY (size) REFERENCES SizeOption(size)
        ON DELETE RESTRICT
);

CREATE TABLE Recipe (
    productId      TEXT NOT NULL,
    ingredientId   TEXT NOT NULL,
    amountRequired REAL NOT NULL,
    CONSTRAINT BR4_validAmount CHECK (typeof(amountRequired) IN ('integer','real') AND amountRequired > 0),
    PRIMARY KEY (productId, ingredientId),
    FOREIGN KEY (productId) REFERENCES Product(productId)
        ON DELETE RESTRICT,
    FOREIGN KEY (ingredientId) REFERENCES Ingredient(ingredientId)
        ON DELETE RESTRICT
);
