-- Conditionally drop tables and sequences.
BEGIN
  FOR i IN (SELECT TABLE_NAME
            FROM   user_tables
            WHERE  TABLE_NAME IN ('KINGDOM','KNIGHT','KINGDOM_KNIGHT_IMPORT')) LOOP 
    EXECUTE IMMEDIATE 'DROP TABLE '||i.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
  FOR i IN (SELECT sequence_name
            FROM   user_sequences
            WHERE  sequence_name IN ('KINGDOM_S1','KNIGHT_S1')) LOOP 
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.sequence_name;
  END LOOP;
END;
/
 
-- Create normalized kingdom table.
CREATE TABLE kingdom
( kingdom_id    NUMBER
, kingdom_name  VARCHAR2(20)
, population    NUMBER);
 
-- Create a sequence for the kingdom table.
CREATE SEQUENCE kingdom_s1;
 
-- Create normalized knight table.
CREATE TABLE knight
( knight_id             NUMBER
, knight_name           VARCHAR2(24)
, kingdom_allegiance_id NUMBER
, allegiance_start_date DATE
, allegiance_end_date   DATE);
 
-- Create a sequence for the knight table.
CREATE SEQUENCE knight_s1;
 
-- Create external import table.
CREATE TABLE kingdom_knight_import
( kingdom_name          VARCHAR2(20)
, population            NUMBER
, knight_name           VARCHAR2(24)
, allegiance_start_date DATE
, allegiance_end_date   DATE)
  ORGANIZATION EXTERNAL
  ( TYPE oracle_loader
    DEFAULT DIRECTORY upload
    ACCESS PARAMETERS
    ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
      PREPROCESSOR upload:'kingdom_import.sh'
      BADFILE      'UPLOAD':'kingdom_import.bad'
      DISCARDFILE 'UPLOAD':'kingdom_import.dis'
      LOGFILE     'UPLOAD':'kingdom_import.log'
      FIELDS TERMINATED BY ','
      OPTIONALLY ENCLOSED BY "'"
      MISSING FIELD VALUES ARE NULL )
    LOCATION ('kingdom_import.sh'))
REJECT LIMIT UNLIMITED;

SET PAGESIZE 99

COL kingdom_name           FORMAT A8        HEADING "Kingdom|Name"
COL population             FORMAT 99999999  HEADING "Population"
COL knight_name            FORMAT A30       HEADING "Knight Name"
COL allegiance_start_date  FORMAT A11       HEADING "Allegiance|Start Date"
COL allegiance_end_date    FORMAT A11       HEADING "Allegiance|End Date"
SELECT   kingdom_name
,        population
,        knight_name
,        TO_CHAR(allegiance_start_date,'DD-MON-YYYY') AS allegiance_start_date
,        TO_CHAR(allegiance_end_date,'DD-MON-YYYY') AS allegiance_end_date
FROM     kingdom_knight_import;
