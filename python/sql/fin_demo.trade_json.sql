CREATE EXTERNAL TABLE IF NOT EXISTS fin_demo.trade_json(
  book_id int , 
  trader_id int , 
  instrument_id int , 
  qty int , 
  price int , 
  ts string )
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
LOCATION
  's3://rsdg-fin-demo-transaction-eu-west-2/'
TBLPROPERTIES (
  'has_encrypted_data'='false')