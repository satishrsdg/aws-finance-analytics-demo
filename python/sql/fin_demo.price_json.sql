CREATE EXTERNAL TABLE IF NOT EXISTS fin_demo.price_json(
  instrument_id int , 
  price int , 
  ts string )
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
LOCATION
  's3://rsdg-fin-demo-price-eu-west-2/'
TBLPROPERTIES (
  'has_encrypted_data'='false')