CREATE EXTERNAL TABLE IF NOT EXISTS fin_demo.ref_traders(
  ref_type string,
  trader_id int, 
  trader_name string, 
  manager_name string)
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