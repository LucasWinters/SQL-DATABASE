EXEC upload_kingdom;

-- Check the kingdom table.
SELECT * FROM kingdom;
 
-- Format Oracle output.
COLUMN knight_id             FORMAT 999 HEADING "Knight|ID #"
COLUMN knight_name           FORMAT A23 HEADING "Knight Name"
COLUMN kingdom_allegiance_id FORMAT 999 HEADING "Kingdom|Allegiance|ID #"
COLUMN allegiance_start_date FORMAT A11 HEADING "Allegiance|Start Date"
COLUMN allegiance_end_date   FORMAT A11 HEADING "Allegiance|End Date"
SET PAGESIZE 999
 
-- Check the knight table.
SELECT   knight_id
,        knight_name
,        kingdom_allegiance_id
,        TO_CHAR(allegiance_start_date,'DD-MON-YYYY') AS allegiance_start_date
,        TO_CHAR(allegiance_end_date,'DD-MON-YYYY') AS allegiance_end_date
FROM     knight;
