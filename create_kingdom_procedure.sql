-- Create a procedure to wrap the transaction.
CREATE OR REPLACE PROCEDURE upload_kingdom IS 
BEGIN
  -- Set save point for an all or nothing transaction.
  SAVEPOINT starting_point;
 
  -- Insert or update the table, which makes this rerunnable when the file hasn't been updated.  
  MERGE INTO kingdom target
  USING (SELECT   DISTINCT
                  k.kingdom_id
         ,        kki.kingdom_name
         ,        kki.population
         FROM     kingdom_knight_import kki LEFT JOIN kingdom k
         ON       kki.kingdom_name = k.kingdom_name
         AND      kki.population = k.population) SOURCE
  ON (target.kingdom_id = SOURCE.kingdom_id)
  WHEN MATCHED THEN
  UPDATE SET kingdom_name = SOURCE.kingdom_name
  WHEN NOT MATCHED THEN
  INSERT VALUES
  ( kingdom_s1.nextval
  , SOURCE.kingdom_name
  , SOURCE.population);
 
  -- Insert or update the table, which makes this rerunnable when the file hasn't been updated.  
  MERGE INTO knight target
  USING (SELECT   kn.knight_id
         ,        kki.knight_name
         ,        k.kingdom_id
         ,        kki.allegiance_start_date AS start_date
         ,        kki.allegiance_end_date AS end_date
         FROM     kingdom_knight_import kki INNER JOIN kingdom k
         ON       kki.kingdom_name = k.kingdom_name
         AND      kki.population = k.population LEFT JOIN knight kn 
         ON       k.kingdom_id = kn.kingdom_allegiance_id
         AND      kki.knight_name = kn.knight_name
         AND      kki.allegiance_start_date = kn.allegiance_start_date
         AND      kki.allegiance_end_date = kn.allegiance_end_date) SOURCE
  ON (target.kingdom_allegiance_id = SOURCE.kingdom_id)
  WHEN MATCHED THEN
  UPDATE SET allegiance_start_date = SOURCE.start_date
  ,          allegiance_end_date = SOURCE.end_date
  WHEN NOT MATCHED THEN
  INSERT VALUES
  ( knight_s1.nextval
  , SOURCE.knight_name
  , SOURCE.kingdom_id
  , SOURCE.start_date
  , SOURCE.end_date);
 
  -- Save the changes.
  COMMIT;
 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    RETURN;
END;
/

DESC upload_kingdom
