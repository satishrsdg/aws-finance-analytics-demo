CREATE EXTERNAL TABLE  IF NOT EXISTS fin_demo.ref_instruments(
  ref_type string,
  instrument_id int,
  instrument_name int,
  instrument_type string,
  exchange_name string
)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://rsdg-fin-demo-reference-eu-west-2/'
TBLPROPERTIES (
  'has_encrypted_data'='false')