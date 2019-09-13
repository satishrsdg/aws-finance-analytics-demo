CREATE OR REPLACE VIEW fin_demo.v_ref_traders AS 
SELECT
  ref_type,
  trader_id,
  trader_name,
  manager_name
FROM
  fin_demo.ref_traders a
WHERE (ref_type = 'traders')