CREATE EXTERNAL TABLE IF NOT EXISTS fin_demo.ref_books (
  ref_type string,
  book_id int,
  name string,
  manager string,
  trading_area string 
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe'
WITH SERDEPROPERTIES (
  'serialization.format' = ',',
  'field.delim' = ','
) LOCATION 's3://rsdg-fin-demo-reference-eu-west-2/'
TBLPROPERTIES ('has_encrypted_data'='false');