CREATE OR REPLACE VIEW fin_demo.v_ref_instruments AS 
SELECT
    ref_type string,
    instrument_id,
    instrument_name,
    instrument_type,
    exchange_name
FROM
  fin_demo.ref_instruments a
WHERE (ref_type = 'instruments')