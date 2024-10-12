-- TASK 1.1
-- Drop the table if it exists to avoid errors on rerun
DROP TABLE A2ERROREVENT CASCADE CONSTRAINTS;

-- Drop the sequence if it exists
DROP SEQUENCE A2ERROREVENT_SEQ;

-- Create the table as per the provided schema
CREATE TABLE A2ERROREVENT (
    ERRORID INTEGER,
    SOURCE_ROWID ROWID,
    SOURCE_TABLE VARCHAR2(30),
    ERRORCODE INTEGER,
    FILTERID INTEGER,
    DATETIME DATE,
    ACTION VARCHAR2(6),
    CONSTRAINT ERROREVENTACTION CHECK (ACTION IN ('SKIP','MODIFY'))
);

-- Create a sequence to for A2ERROREVENT table
CREATE SEQUENCE A2ERROREVENT_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- Commit the transaction to save changes
-- COMMIT;

-- TASK 1.2
-- Drop Tables if they exist
DROP TABLE DWPROD CASCADE CONSTRAINTS;
DROP TABLE DWCUST CASCADE CONSTRAINTS;
DROP TABLE DWSALE CASCADE CONSTRAINTS;

-- Drop Sequences if they exist
DROP SEQUENCE DWPROD_SEQ;
DROP SEQUENCE DWCUST_SEQ;
DROP SEQUENCE DWSALE_SEQ;

-- Create Sequence for DWPROD
CREATE SEQUENCE DWPROD_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- Create Sequence for DWCUST
CREATE SEQUENCE DWCUST_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- Create Sequence for DWSALE
CREATE SEQUENCE DWSALE_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

-- Create DWPROD Table
CREATE TABLE DWPROD (
    DWPRODID INTEGER PRIMARY KEY,
    DWSOURCETABLE VARCHAR2(25),
    DWSOURCEID NUMBER(38),
    PRODNAME VARCHAR2(100),
    PRODCATNAME NUMBER(38),
    PRODMANUNAME VARCHAR2(30),
    PRODSHIPNAME VARCHAR2(30)
);

-- Create DWCUST Table
CREATE TABLE DWCUST (
    DWCUSTID INTEGER PRIMARY KEY,
    DWSOURCEIDBRIS INTEGER,
    DWSOURCEIDMELB INTEGER,
    FIRSTNAME VARCHAR2(30),
    SURNAME VARCHAR2(30),
    GENDER CHAR(1),
    PHONE VARCHAR2(12),
    POSTCODE VARCHAR2(4),
    CITY VARCHAR2(50),
    STATE VARCHAR2(20),
    CUSTCATNAME VARCHAR2(50)
);

-- Create DWSALE Table
CREATE TABLE DWSALE (
    DWSALEID INTEGER PRIMARY KEY,
    DWCUSTID INTEGER,
    DWPRODID INTEGER,
    DWSOURCEIDBRIS INTEGER,
    DWSOURCEIDMELB INTEGER,
    QTY INTEGER,
    SALE_DWDATEID INTEGER,
    SHIP_DWDATEID INTEGER,
    SALEPRICE NUMBER(10, 2),
    CONSTRAINT FK_DWCUSTID FOREIGN KEY (DWCUSTID) REFERENCES DWCUST(DWCUSTID),
    CONSTRAINT FK_DWPRODID FOREIGN KEY (DWPRODID) REFERENCES DWPROD(DWPRODID)
);
-- Considering if the constraint within the dwsale is needed or not

-- TASK 1.3
-- Create GENDERSPELLING Table
DROP TABLE GENDERSPELLING;

CREATE TABLE GENDERSPELLING (
    INVALID_VALUE VARCHAR2(20) PRIMARY KEY,
    NEW_VALUE CHAR(1)
);

-- Insert data into GENDERSPELLING Table
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('MAIL', 'M');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('WOMAN', 'F');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('FEM', 'F');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('FEMALE', 'F');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('MALE', 'M');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('GENTLEMAN', 'M');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('MM', 'M');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('FF', 'F');
INSERT INTO GENDERSPELLING (INVALID_VALUE, NEW_VALUE) VALUES ('FEMAIL', 'F');

-- PART 2
-- TASK 2.1
-- Insert rows into A2ERROREVENT where A2PRODUCT.PRODNAME is NULL
INSERT INTO A2ERROREVENT (
    ERRORID, 
    SOURCE_ROWID, 
    SOURCE_TABLE, 
    ERRORCODE, 
    FILTERID, 
    DATETIME, 
    ACTION
)
SELECT 
    A2ERROREVENT_SEQ.NEXTVAL,
    ROWID,
    'A2PRODUCT',
    116,
    1,
    SYSDATE,
    'SKIP'
FROM 
    A2PRODUCT
WHERE 
    PRODNAME IS NULL;

-- Check if the A2ERROREVENT table was updated correctly
SELECT *
FROM A2ERROREVENT
WHERE SOURCE_TABLE = 'A2PRODUCT'
AND ERRORCODE = 116
AND ACTION = 'SKIP';

-- Count rows have NULL product names in A2PRODUCT
SELECT COUNT(*)
FROM A2PRODUCT
WHERE PRODNAME IS NULL;

-- Count rows in A2ERROREVENT to ensure the same amount of error rows are returned
SELECT COUNT(*)
FROM A2ERROREVENT
WHERE SOURCE_TABLE = 'A2PRODUCT'
AND ERRORCODE = 116
AND ACTION = 'SKIP';

-- TASK 2.2
-- Insert rows into Ass2ErrorEvent where A2Product.MANUFACTURERCODE is NULL
INSERT INTO A2ERROREVENT (
    ERRORID,
    SOURCE_ROWID,
    SOURCE_TABLE,
    ERRORCODE,
    FILTERID,
    DATETIME,
    ACTION
)
SELECT 
    A2ERROREVENT_SEQ.NEXTVAL,
    ROWID,
    'A2PRODUCT',
    129,
    2,
    SYSDATE,
    'MODIFY'
FROM 
    A2PRODUCT
WHERE 
    MANUFACTURERCODE IS NULL;

-- Count rows in A2Product having NULL manufacturer codes
SELECT COUNT(*)
FROM A2PRODUCT
WHERE MANUFACTURERCODE IS NULL;

-- Count rows in Ass2ErrorEvent to ensure the exact number is returned
SELECT COUNT(*)
FROM A2ERROREVENT
WHERE SOURCE_TABLE = 'A2Product'
AND ERRORCODE = 129
AND ACTION = 'MODIFY';

-- TASK 2.3
-- Insert rows into A2ErrorEvent if A2Product.PRODCATEGORY is NULL or doesn't exist in A2PRODCATEGORY
INSERT INTO A2ERROREVENT (
    ERRORID, 
    SOURCE_ROWID, 
    SOURCE_TABLE, 
    ERRORCODE, 
    FILTERID, 
    DATETIME, 
    ACTION
)
SELECT 
    A2ERROREVENT_SEQ.NEXTVAL,
    ROWID,
    'A2PRODUCT',
    141,
    3,
    SYSDATE,
    'MODIFY'
FROM 
    A2PRODUCT p
WHERE p.PRODCATEGORY IS NULL
OR p.PRODCATEGORY NOT IN (
    SELECT PRODUCTCATEGORY
    FROM A2PRODCATEGORY
);

-- Count rows in A2Product with NULL or invalid PRODCATEGORYID
SELECT COUNT(*)
FROM A2PRODUCT p
WHERE p.PRODCATEGORY IS NULL
OR p.PRODCATEGORY NOT IN (
    SELECT PRODUCTCATEGORY
    FROM A2PRODCATEGORY
);

-- Double check with the invalid rows in Ass2ErrorEvent
SELECT COUNT(*)
FROM A2ERROREVENT
WHERE SOURCE_TABLE = 'A2PRODUCT'
AND ERRORCODE = 141
AND ACTION = 'MODIFY';

-- TASK 2.4
-- Select rows from A2Product that do not have a corresponding source_rowid in Ass2ErrorEvent
-- SELECT ROWID
-- FROM A2Product a
-- WHERE ROWID NOT IN (
--     SELECT SOURCE_ROWID
--     FROM A2ERROREVENT
-- );

-- TASK 2.4.2
-- Select rows from A2Product that do not have a matching row in Ass2ErrorEvent
 SELECT p.PRODUCTID, p.PRODNAME, cat.CATEGORYNAME, manu.MANUFACTURERNAME, ship.DESCRIPTION AS SHIPPINGDESCRIPTION
 FROM A2Product p
 JOIN A2PRODCATEGORY cat ON p.CATEGORYID = cat.PRODUCTCATEGORY
 JOIN A2Manufacturer manu ON p.MANUFACTURERCODE = manu.MANUFACTURERCODE
 JOIN A2Shipping ship ON p.SHIPPINGCODE = ship.SHIPPINGCODE
 LEFT JOIN A2ERROREVENT e ON p.ROWID = e.SOURCE_ROWID
 WHERE e.SOURCE_ROWID IS NULL;
