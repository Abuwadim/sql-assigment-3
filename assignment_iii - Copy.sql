-- =====================================================================
-- ASSIGNMENT III: SQL TABLE MANIPULATION
-- Project   : Pharmacy Management System
-- DBMS      : PostgreSQL (pgAdmin 4)
-- Database  : twin_202512587_pharmacy_system
-- Institution: ULK
-- =====================================================================


-- =====================================================================
-- SECTION 1: DATABASE CREATION
-- =====================================================================
-- Run this statement ALONE while connected to the default "postgres"
-- database. Then in pgAdmin: right-click Databases > Refresh, select
-- the new database, open Query Tool, and run everything below it.
-- (In psql you can use:  \c twin_202512587_pharmacy_system )

CREATE DATABASE twin_202512587_pharmacy_system;


-- =====================================================================
-- SECTION 2: TABLE CREATION AND CONSTRAINTS
-- (parent tables first, child table last)
-- =====================================================================

-- Parent table 1: customers
CREATE TABLE customers (
    customer_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    phone           VARCHAR(15)  NOT NULL UNIQUE,
    email           VARCHAR(100) UNIQUE,
    address         VARCHAR(150),
    registered_date DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- Parent table 2: medicines
CREATE TABLE medicines (
    medicine_id    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    medicine_name  VARCHAR(100)  NOT NULL,
    category       VARCHAR(50)   NOT NULL,
    unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    stock_quantity INT           NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    expiry_date    DATE          NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'Available'
                   CHECK (status IN ('Available', 'Low Stock', 'Discounted', 'Expired'))
);

-- Child table: sales (links customers and medicines)
CREATE TABLE sales (
    sale_id        INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id    INT           NOT NULL,
    medicine_id    INT           NOT NULL,
    quantity       INT           NOT NULL CHECK (quantity > 0),
    total_amount   NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0),
    sale_date      DATE          NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(20)   NOT NULL
                   CHECK (payment_method IN ('Cash', 'Mobile Money', 'Card')),
    CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sales_medicine FOREIGN KEY (medicine_id)
        REFERENCES medicines (medicine_id) ON DELETE RESTRICT
);


-- =====================================================================
-- SECTION 3: INITIAL DATA INSERTION
-- (primary keys are NOT supplied; parents before child)
-- =====================================================================

-- 3.1 customers (6 records)
INSERT INTO customers (first_name, last_name, phone, email, address, registered_date)
VALUES
    ('Jean',    'Mugisha',   '0788123456', 'jean.mugisha@example.com',   'KN 5 Rd, Kigali',      '2026-01-10'),
    ('Aline',   'Uwase',     '0722345678', 'aline.uwase@example.com',    'KG 9 Ave, Kigali',     '2026-02-14'),
    ('Eric',    'Niyonzima', '0733456789', 'eric.niyonzima@example.com', 'Huye, Southern Prov.', '2026-03-03'),
    ('Grace',   'Mukamana',  '0788567890', 'grace.mukamana@example.com', 'Musanze, Northern Prov.', '2026-04-21'),
    ('Patrick', 'Habimana',  '0722678901', 'patrick.habimana@example.com','Rubavu, Western Prov.', '2026-05-30'),
    ('Diane',   'Ingabire',  '0733789012', 'diane.ingabire@example.com', 'Nyamata, Bugesera',   '2026-07-12');

-- 3.2 medicines (8 records)
INSERT INTO medicines (medicine_name, category, unit_price, stock_quantity, expiry_date, status)
VALUES
    ('Paracetamol 500mg',        'Analgesic',     300.00, 200, '2027-08-15', 'Available'),
    ('Amoxicillin 500mg',        'Antibiotic',   1200.00,  80, '2027-03-20', 'Available'),
    ('Ibuprofen 400mg',          'Analgesic',     600.00,  15, '2026-12-31', 'Low Stock'),
    ('Cetirizine 10mg',          'Antihistamine', 450.00, 120, '2027-06-10', 'Available'),
    ('ORS Sachets',              'Rehydration',   250.00, 300, '2028-01-05', 'Available'),
    ('Metformin 500mg',          'Antidiabetic',  800.00,  60, '2027-11-30', 'Available'),
    ('Vitamin C 1000mg',         'Supplement',   1000.00,   8, '2026-12-15', 'Low Stock'),
    ('Artemether-Lumefantrine',  'Antimalarial', 2500.00,  90, '2027-09-25', 'Available');

-- 3.3 sales (8 records) - foreign keys reference existing parent rows
INSERT INTO sales (customer_id, medicine_id, quantity, total_amount, sale_date, payment_method)
VALUES
    (1, 1,  4, 1200.00, '2026-10-01', 'Cash'),
    (2, 2,  2, 2400.00, '2026-10-03', 'Mobile Money'),
    (3, 8,  1, 2500.00, '2026-10-05', 'Cash'),
    (1, 4,  2,  900.00, '2026-10-08', 'Card'),
    (4, 5,  6, 1500.00, '2026-10-12', 'Mobile Money'),
    (5, 3,  3, 1800.00, '2026-10-15', 'Cash'),
    (2, 1, 10, 3000.00, '2026-10-18', 'Mobile Money'),
    (3, 4,  1,  450.00, '2026-10-20', 'Cash');

-- 3.4 Verification: record counts per table
SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers
UNION ALL
SELECT 'medicines', COUNT(*) FROM medicines
UNION ALL
SELECT 'sales', COUNT(*) FROM sales;

-- 3.5 Verification: auto-generated keys and foreign keys work
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM medicines ORDER BY medicine_id;
SELECT * FROM sales     ORDER BY sale_id;


-- =====================================================================
-- >>> STOP HERE AND GENERATE THE ERD (before any ALTER TABLE task) <<<
-- pgAdmin 4: right-click the database > "ERD For Database"
-- then use the Download image button and save it as erd.png
-- =====================================================================


-- =====================================================================
-- SECTION 4: SELECT TASKS
-- =====================================================================

-- Task Q1.1: Basic Data Retrieval
-- Objective: display selected columns from the medicines table.
SELECT medicine_name, category, unit_price, stock_quantity
FROM medicines;

-- Task Q1.2: Conditional Data Retrieval
-- Objective: find medicines whose stock is below 50 units (need restocking).
SELECT medicine_name, stock_quantity, unit_price
FROM medicines
WHERE stock_quantity < 50;

-- Task Q1.3: Sorted Data Retrieval
-- Objective: list medicines from the earliest to the latest expiry date.
SELECT medicine_name, expiry_date, unit_price
FROM medicines
ORDER BY expiry_date ASC;


-- =====================================================================
-- SECTION 5: JOIN TASKS
-- =====================================================================

-- Task Q2.1: INNER JOIN (customers + sales)
-- Objective: show only customers who have made purchases, with their sales.
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       s.sale_id,
       s.quantity,
       s.total_amount,
       s.sale_date
FROM customers c
INNER JOIN sales s ON c.customer_id = s.customer_id
ORDER BY s.sale_id;

-- Task Q2.2: LEFT JOIN (medicines + sales)
-- Objective: show ALL medicines, including those never sold.
SELECT m.medicine_id,
       m.medicine_name,
       COUNT(s.sale_id)               AS times_sold,
       COALESCE(SUM(s.quantity), 0)   AS total_units_sold
FROM medicines m
LEFT JOIN sales s ON m.medicine_id = s.medicine_id
GROUP BY m.medicine_id, m.medicine_name
ORDER BY m.medicine_id;

-- Task Q2.3: Multi-Table JOIN (customers + sales + medicines)
-- Objective: produce a full transaction report.
SELECT s.sale_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       m.medicine_name,
       s.quantity,
       m.unit_price,
       s.total_amount,
       s.sale_date,
       s.payment_method
FROM sales s
INNER JOIN customers c ON s.customer_id = c.customer_id
INNER JOIN medicines m ON s.medicine_id = m.medicine_id
ORDER BY s.sale_date, s.sale_id;


-- =====================================================================
-- SECTION 6: UPDATE TASKS AND VERIFICATION
-- =====================================================================

-- Task Q3.1: Update One Record
-- Objective: change the phone number of customer 2 (Aline Uwase).
-- Step 1 - identify the record (before)
SELECT customer_id, first_name, last_name, phone
FROM customers
WHERE customer_id = 2;
-- Step 2 - update
UPDATE customers
SET phone = '0788999111'
WHERE customer_id = 2;
-- Step 3 - verify (after)
SELECT customer_id, first_name, last_name, phone
FROM customers
WHERE customer_id = 2;

-- Task Q3.2: Update Multiple Records
-- Objective: add 100 units of stock after a delivery of all Analgesics.
-- Step 1 - identify the records (before)
SELECT medicine_id, medicine_name, category, stock_quantity
FROM medicines
WHERE category = 'Analgesic'
ORDER BY medicine_id;
-- Step 2 - update
UPDATE medicines
SET stock_quantity = stock_quantity + 100
WHERE category = 'Analgesic';
-- Step 3 - verify (after)
SELECT medicine_id, medicine_name, category, stock_quantity
FROM medicines
WHERE category = 'Analgesic'
ORDER BY medicine_id;

-- Task Q3.3: Conditional Update
-- Business rule: medicines expiring on or before 31 Jan 2027 get a 10%
-- discount and their status becomes 'Discounted'.
-- Step 1 - identify the records (before)
SELECT medicine_id, medicine_name, unit_price, expiry_date, status
FROM medicines
WHERE expiry_date <= DATE '2027-01-31'
ORDER BY medicine_id;
-- Step 2 - update
UPDATE medicines
SET unit_price = ROUND(unit_price * 0.90, 2),
    status     = 'Discounted'
WHERE expiry_date <= DATE '2027-01-31'
  AND status <> 'Expired';
-- Step 3 - verify (after)
SELECT medicine_id, medicine_name, unit_price, expiry_date, status
FROM medicines
WHERE status = 'Discounted'
ORDER BY medicine_id;


-- =====================================================================
-- SECTION 7: ALTER TABLE TASKS AND VERIFICATION
-- =====================================================================

-- Task Q4.1: Rename a Column
-- Objective: rename customers.phone to phone_number.
-- Before
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;
-- Alter
ALTER TABLE customers
RENAME COLUMN phone TO phone_number;
-- After (structure + data still accessible)
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'customers'
ORDER BY ordinal_position;
SELECT customer_id, first_name, phone_number FROM customers ORDER BY customer_id;

-- Task Q4.2: Change a Column's Data Type
-- Objective: widen phone_number from VARCHAR(15) to VARCHAR(20) so
-- international formats (e.g. +250788123456) fit. Widening is safe:
-- no existing value can be truncated or lost.
-- Before
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'customers' AND column_name = 'phone_number';
-- Alter
ALTER TABLE customers
ALTER COLUMN phone_number TYPE VARCHAR(20);
-- After
SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'customers' AND column_name = 'phone_number';
SELECT customer_id, phone_number FROM customers ORDER BY customer_id;

-- Task Q4.3: Add a Column
-- Objective: store the manufacturer of each medicine.
ALTER TABLE medicines
ADD COLUMN manufacturer VARCHAR(100) DEFAULT 'Unknown';
-- Verify structure
SELECT column_name, data_type, character_maximum_length, is_nullable
FROM information_schema.columns
WHERE table_name = 'medicines'
ORDER BY ordinal_position;
-- Verify data
SELECT medicine_id, medicine_name, manufacturer
FROM medicines
ORDER BY medicine_id;


-- =====================================================================
-- SECTION 8: ADDITIONAL INSERT TASKS AND VERIFICATION
-- =====================================================================

-- Task Q5.1: Insert a Single Record
-- Objective: register a new customer (uses the renamed phone_number column).
INSERT INTO customers (first_name, last_name, phone_number, email, address)
VALUES ('Sandra', 'Uwimana', '0788445566', 'sandra.uwimana@example.com', 'KG 11 Ave, Kigali');
-- Verify
SELECT * FROM customers WHERE phone_number = '0788445566';

-- Task Q5.2: Insert Multiple Records
-- Objective: add three new medicines in a single INSERT statement.
INSERT INTO medicines (medicine_name, category, unit_price, stock_quantity, expiry_date, status, manufacturer)
VALUES
    ('Omeprazole 20mg',    'Antacid',     700.00, 100, '2027-10-10', 'Available', 'Cipla'),
    ('Salbutamol Inhaler', 'Respiratory', 3500.00, 40, '2027-05-18', 'Low Stock', 'GlaxoSmithKline'),
    ('Zinc Sulphate 20mg', 'Supplement',  500.00, 150, '2028-02-28', 'Available', 'Shelys Pharmaceuticals');
-- Verify
SELECT medicine_id, medicine_name, category, unit_price, stock_quantity, manufacturer
FROM medicines
WHERE medicine_id > 8
ORDER BY medicine_id;

-- Task Q5.3: Insert a Related Record (child table)
-- Objective: record a sale for the new customer using valid foreign keys.
-- The subqueries look up the existing parent IDs, so no key is hard-coded.
INSERT INTO sales (customer_id, medicine_id, quantity, total_amount, sale_date, payment_method)
VALUES (
    (SELECT customer_id FROM customers WHERE phone_number = '0788445566'),
    (SELECT medicine_id FROM medicines WHERE medicine_name = 'Omeprazole 20mg'),
    2, 1400.00, '2026-10-25', 'Cash'
);
-- Verify (joined with parents to prove the foreign keys resolve)
SELECT s.sale_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       m.medicine_name,
       s.quantity,
       s.total_amount,
       s.sale_date
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN medicines m ON s.medicine_id = m.medicine_id
WHERE s.sale_id = (SELECT MAX(sale_id) FROM sales);

-- Final record counts
SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers
UNION ALL
SELECT 'medicines', COUNT(*) FROM medicines
UNION ALL
SELECT 'sales', COUNT(*) FROM sales;

-- ---------------------------------------------------------------------
-- OPTIONAL constraint demonstration (run LAST; it is expected to FAIL).
-- A failed INSERT still consumes an identity value, so keep it at the end.
-- ---------------------------------------------------------------------
-- INSERT INTO sales (customer_id, medicine_id, quantity, total_amount, payment_method)
-- VALUES (999, 1, 1, 300.00, 'Cash');
-- Expected: ERROR: insert or update on table "sales" violates foreign key
-- constraint "fk_sales_customer"
-- END OF SCRIPT
