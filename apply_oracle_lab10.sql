-- ------------------------------------------------------------------
--  Program Name:   apply_oracle_lab10.sql
--  Lab Assignment: Lab #10
--  Program Author: Michael McLaughlin
--  Creation Date:  02-Mar-2018
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- The two scripts contain spooling commands, which is why there
-- isn't a spooling command in this script. When you run this file
-- you first connect to the Oracle database with this syntax:
--
--   sqlplus student/student@xe
--
-- Then, you call this script with the following syntax:
--
--   sql> @apply_oracle_lab10.sql
--
-- ------------------------------------------------------------------

-- Run the prior lab script.
@/home/student/Data/cit225/oracle/lab9/apply_oracle_lab9.sql

SPOOL apply_oracle_lab10.txt

-- ... insert lab 10 commands here ...

-- ------------------------------------------------------------------
-- Step 1: Check the select statement
-- ------------------------------------------------------------------

SET NULL '<Null>'
COLUMN rental_id        FORMAT 9999 HEADING "Rental|ID #"
COLUMN customer         FORMAT 9999 HEADING "Customer|ID #"
COLUMN check_out_date   FORMAT A9   HEADING "Check Out|Date"
COLUMN return_date      FORMAT A10  HEADING "Return|Date"
COLUMN created_by       FORMAT 9999 HEADING "Created|By"
COLUMN creation_date    FORMAT A10  HEADING "Creation|Date"
COLUMN last_updated_by  FORMAT 9999 HEADING "Last|Update|By"
COLUMN last_update_date FORMAT A10  HEADING "Last|Updated"
SELECT   DISTINCT c.contact_id
FROM     member m INNER JOIN transaction_upload tu
ON       m.account_number = tu.account_number INNER JOIN contact c
ON       m.member_id = c.member_id
WHERE    c.first_name = tu.first_name
AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
AND      c.last_name = tu.last_name
ORDER BY c.contact_id;

-- ------------------------------------------------------------------
-- Step 1b: Check the select statement
-- ------------------------------------------------------------------
SET NULL '<Null>'
COLUMN rental_id        FORMAT 9999 HEADING "Rental|ID #"
COLUMN customer         FORMAT 9999 HEADING "Customer|ID #"
COLUMN check_out_date   FORMAT A9   HEADING "Check Out|Date"
COLUMN return_date      FORMAT A10  HEADING "Return|Date"
COLUMN created_by       FORMAT 9999 HEADING "Created|By"
COLUMN creation_date    FORMAT A10  HEADING "Creation|Date"
COLUMN last_updated_by  FORMAT 9999 HEADING "Last|Update|By"
COLUMN last_update_date FORMAT A10  HEADING "Last|Updated"
SELECT   DISTINCT
         r.rental_id
,        c.contact_id
,        tu.check_out_date AS check_out_date
,        tu.return_date AS return_date
,        1 AS created_by
,        TRUNC(SYSDATE) AS creation_date
,        1 AS last_updated_by
,        TRUNC(SYSDATE) AS last_update_date
FROM    member m INNER JOIN contact c
ON      m.member_id = c.member_id INNER JOIN transaction_upload tu
ON      c.first_name = tu.first_name
AND     NVL(c.middle_name, 'x') = NVL(tu.middle_name, 'x')
AND     c.last_name = tu.last_name 
AND     m.account_number = tu.account_number LEFT JOIN rental r
ON      c.contact_id = r.customer_id
AND     TRUNC(r.check_out_date) = TRUNC(tu.check_out_date)
AND     TRUNC(r.return_date) = TRUNC(tu.return_date);

-- ------------------------------------------------------------------
-- Step 1c: Insert statement into rental
-- ------------------------------------------------------------------
INSERT INTO rental
SELECT   NVL(r.rental_id,rental_s1.NEXTVAL) AS rental_id
,        r.contact_id
,        r.check_out_date
,        r.return_date
,        r.created_by
,        r.creation_date
,        r.last_updated_by
,        r.last_update_date
FROM    (SELECT   DISTINCT
                  r.rental_id
         ,        c.contact_id
         ,        tu.check_out_date AS check_out_date
         ,        tu.return_date AS return_date
         ,        1 AS created_by
         ,        TRUNC(SYSDATE) AS creation_date
         ,        1 AS last_updated_by
         ,        TRUNC(SYSDATE) AS last_update_date
         FROM     member m INNER JOIN contact c
         ON       m.member_id = c.member_id INNER JOIN transaction_upload tu
         ON       c.first_name = tu.first_name
         AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
         AND      c.last_name = tu.last_name 
         AND      m.account_number = tu.account_number Left join rental r
         ON       c.contact_id = r.customer_id
         AND      TRUNC(r.check_out_date) = TRUNC(tu.check_out_date)
         AND      TRUNC(r.return_date) = TRUNC(tu.return_date)) r;
         
COL rental_count FORMAT 999,999 HEADING "Rental|after|Count"
SELECT   COUNT(*) AS rental_count
FROM     rental;


-- ------------------------------------------------------------------
-- Step 2: Check item before count
-- ------------------------------------------------------------------
COL rental_item_count FORMAT 999,999 HEADING "Rental|Item|Before|Count"
SELECT   COUNT(*) AS rental_item_count
FROM     rental_item;

-- ------------------------------------------------------------------
-- Step 2b: Select statement
-- ------------------------------------------------------------------
SET NULL '<Null>'
COLUMN rental_item_id     FORMAT 99999 HEADING "Rental|Item ID #"
COLUMN rental_id          FORMAT 99999 HEADING "Rental|ID #"
COLUMN item_id            FORMAT 99999 HEADING "Item|ID #"
COLUMN rental_item_price  FORMAT 99999 HEADING "Rental|Item|Price"
COLUMN rental_item_type   FORMAT 99999 HEADING "Rental|Item|Type"
COLUMN created_by         FORMAT 9999 HEADING "Created|By"
COLUMN creation_date      FORMAT A10  HEADING "Creation|Date"
COLUMN last_updated_by    FORMAT 9999 HEADING "Last|Update|By"
COLUMN last_update_date   FORMAT A10  HEADING "Last|Updated"
SELECT   ri.rental_item_id
,        r.rental_id
,        tu.item_id
,        TRUNC(r.return_date) - TRUNC(r.check_out_date) AS rental_item_price
,        cl1.common_lookup_id AS rental_item_type
,        1 AS created_by
,        TRUNC(SYSDATE) AS creation_date
,        1 AS last_updated_by
,        TRUNC(SYSDATE) AS last_update_date
FROM     member m INNER JOIN contact c
 ON       m.member_id = c.member_id INNER JOIN transaction_upload tu
 ON       c.first_name = tu.first_name
 AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
 AND      c.last_name = tu.last_name
 AND      tu.account_number = m.account_number
 LEFT JOIN rental r
        ON       c.contact_id = r.customer_id
        AND      TRUNC(r.check_out_date) = TRUNC(tu.check_out_date)
        AND      TRUNC(r.return_date) = TRUNC(tu.return_date)
JOIN common_lookup cl1
        ON      cl1.common_lookup_table = 'RENTAL_ITEM'
        AND     cl1.common_lookup_column = 'RENTAL_ITEM_TYPE'
        AND     cl1.common_lookup_type = tu.rental_item_type
LEFT JOIN rental_item ri
        ON      r.rental_id = ri.rental_id;


-- ------------------------------------------------------------------
-- Step 2c: Insert statement into rental_item
-- ------------------------------------------------------------------
INSERT INTO rental_item
(SELECT   NVL(ri.rental_item_id,rental_item_s1.NEXTVAL) AS RENTAL_ITEM_ID
 ,        r.rental_id
 ,        tu.item_id
 ,        1 AS created_by
 ,        TRUNC(SYSDATE) AS creation_date
 ,        1 AS last_updated_by
 ,        TRUNC(SYSDATE) AS last_update_date
 ,        cl1.common_lookup_id AS rental_item_type
 ,        r.return_date - r.check_out_date AS rental_item_price
 FROM     member m INNER JOIN contact c
 ON       m.member_id = c.member_id INNER JOIN transaction_upload tu
 ON       c.first_name = tu.first_name
 AND      NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
 AND      c.last_name = tu.last_name
 AND      tu.account_number = m.account_number
 LEFT JOIN rental r
        ON       c.contact_id = r.customer_id
        AND      TRUNC(r.check_out_date) = TRUNC(tu.check_out_date)
        AND      TRUNC(r.return_date) = TRUNC(tu.return_date)
JOIN common_lookup cl1
        ON      cl1.common_lookup_table = 'RENTAL_ITEM'
        AND     cl1.common_lookup_column = 'RENTAL_ITEM_TYPE'
        AND     cl1.common_lookup_type = tu.rental_item_type
LEFT JOIN rental_item ri
        ON      r.rental_id = ri.rental_id);
        
COL rental_item_count FORMAT 999,999 HEADING "Rental|Item|After|Count"
SELECT   COUNT(*) AS rental_item_count
FROM     rental_item; 



-- ------------------------------------------------------------------
-- Step 3: Insert statement into transaction table
-- ------------------------------------------------------------------
update common_lookup set common_lookup_type = 'DEBIT' WHERE COMMON_LOOKUP_TYPE = 'DEDIT';

INSERT INTO transaction
SELECT   NVL(t.transaction_id,transaction_s1.NEXTVAL) as transaction_id
,        t.transaction_account
,        t.transaction_type
,        t.transaction_date
,        t.transaction_amount
,        t.rental_id
,        t.payment_method_type
,        t.payment_account_number
,        t.created_by
,        t.creation_date
,        t.last_updated_by
,        t.last_update_date
FROM    (SELECT   t.transaction_id
         ,        tu.payment_account_number AS transaction_account
         ,        cl1.common_lookup_id AS transaction_type
         ,        tu.transaction_date
         ,       (SUM(tu.transaction_amount) / 1.06) AS transaction_amount
         ,        r.rental_id
         ,        cl2.common_lookup_id AS payment_method_type
         ,        m.credit_card_number AS payment_account_number
         ,        1 AS created_by
         ,        TRUNC(SYSDATE) AS creation_date
         ,        1 AS last_updated_by
         ,        TRUNC(SYSDATE) AS last_update_date
         FROM     member m INNER JOIN contact c
            ON   m.member_id = c.member_id INNER JOIN transaction_upload tu
            ON   c.first_name = tu.first_name
            AND  NVL(c.middle_name,'x') = NVL(tu.middle_name,'x')
            AND  c.last_name = tu.last_name
            AND  tu.account_number = m.account_number LEFT JOIN rental r
            ON   c.contact_id = r.customer_id
            AND  TRUNC(tu.check_out_date) = TRUNC(r.check_out_date)
            AND  TRUNC(tu.return_date) = TRUNC(r.return_date) JOIN common_lookup cl1
            ON      cl1.common_lookup_table = 'TRANSACTION'
            AND     cl1.common_lookup_column = 'TRANSACTION_TYPE'
            AND     cl1.common_lookup_type = tu.transaction_type JOIN common_lookup cl2
            ON      cl2.common_lookup_table = 'TRANSACTION'
            AND     cl2.common_lookup_column = 'PAYMENT_METHOD_TYPE'
            AND     cl2.common_lookup_type = tu.payment_method_type LEFT JOIN transaction t
            ON t.TRANSACTION_ACCOUNT = tu.payment_account_number
            AND t.rental_id = r.rental_id
            AND t.TRANSACTION_TYPE = cl1.common_lookup_id
            AND t.TRANSACTION_DATE = tu.transaction_date
            AND t.PAYMENT_METHOD_TYPE = cl2.common_lookup_id
            AND t.PAYMENT_ACCOUNT_NUMBER = m.credit_card_number
         GROUP BY t.transaction_id
         ,        tu.payment_account_number
         ,        cl1.common_lookup_id
         ,        tu.transaction_date
         ,        r.rental_id
         ,        cl2.common_lookup_id
         ,        m.credit_card_number
         ,        1
         ,        TRUNC(SYSDATE)
         ,        1
         ,        TRUNC(SYSDATE)) t;

         
COL transaction_count FORMAT 999,999 HEADING "Transaction|After|Count"
SELECT   COUNT(*) AS transaction_count
FROM     TRANSACTION;         

-- Commit inserted records.
COMMIT;

-- Close log file.
SPOOL OFF
