ATHENA_DB = "fin_demo"
ATHENA_TABLE_PRICE = "price_json"
ATHENA_TABLE_TRADES = "trades_json"

S3_BUCKET = "s3://rsdg-fin-demo-reference-eu-west-2"
S3_INPUT_DIR = f"{S3_BUCKET}/crime-data/"
S3_OUTPUT_DIR = f"{S3_BUCKET}/query-results/"
DICT_SQL = {
        'PRICE_JSON':       './sql/fin_demo.price_json.sql',
        'TRADE_JSON':       './sql/fin_demo.trade_json.sql',
        'REF_TRADERS':      './sql/fin_demo.ref_traders.sql',
        'REF_BOOKS':        './sql/fin_demo.ref_books.sql',
        'REF_INSTRUMENTS':  './sql/fin_demo.ref_instruments.sql',
        'V_REF_BOOKS':      './sql/fin_demo.v_ref_books.sql',
        'V_REF_INSTRUMENTS':'./sql/fin_demo.v_ref_instruments.sql',
        'V_REF_TRADERS':    './sql/fin_demo.v_ref_traders.sql'
        }
