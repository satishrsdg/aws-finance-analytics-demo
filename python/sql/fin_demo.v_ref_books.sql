CREATE OR REPLACE VIEW fin_demo.v_ref_book AS 
SELECT
  book_id,
  name,
  manager,
  trading_area
FROM
  fin_demo.ref_books a
WHERE (ref_type = 'books')