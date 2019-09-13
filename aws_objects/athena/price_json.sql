CREATE EXTERNAL TABLE IF NOT EXISTS fin_demo.price_json (
`instrument_id` int,
`price` int,
`ts` string
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
'serialization.format' = '1'
) LOCATION 's3://rsdg-fin-demo-price-eu-west-2/'
TBLPROPERTIES ('has_encrypted_data'='false');