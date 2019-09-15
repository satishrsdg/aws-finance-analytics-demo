import boto3
import sys as sys
from botocore import exceptions

import queries
import config as cfg

def execute_query(athena_client: boto3.client, query: str) -> dict:
    return athena_client.start_query_execution(
        QueryString=query,
        ResultConfiguration={
            "OutputLocation": cfg.S3_OUTPUT_DIR,
            "EncryptionConfiguration": {
                "EncryptionOption": "SSE_S3"
            }
        }
    )

def clean_up(aws_profile):
    print('hello cleanup')
    _session = boto3.Session(profile_name=aws_profile)
    athena_client = _session.client('athena', region_name='eu-west-2')
    try:
        execute_query(athena_client, 'drop view fin_demo.v_ref_book;')
        execute_query(athena_client, 'drop view fin_demo.v_ref_instruments;')
        execute_query(athena_client, 'drop view fin_demo.v_ref_traders;')
        execute_query(athena_client, 'drop table fin_demo.ref_books;')
        execute_query(athena_client, 'drop table fin_demo.ref_traders;')
        execute_query(athena_client, 'drop table fin_demo.ref_instruments;')
        execute_query(athena_client, 'drop table fin_demo.price_json;')
        execute_query(athena_client, 'drop table fin_demo.trade_json;')
        execute_query(athena_client, 'drop database fin_demo;')

        
    except exceptions.ClientError as err:
        print(err.response['Error']['Message'])
        exit(err.response['Error']['Message'])

    exit(0)

def build(aws_profile):
    print("hello world")
    _session = boto3.Session(profile_name=aws_profile)
    athena_client = _session.client('athena', region_name='eu-west-2')

    try:
        execute_query(athena_client, queries.create_database('fin_demo'))

        execute_query(athena_client, queries.create_table('PRICE_JSON'))
        execute_query(athena_client, queries.create_table('TRADE_JSON'))

        execute_query(athena_client, queries.create_table('REF_TRADERS'))
        execute_query(athena_client, queries.create_table('REF_BOOKS'))
        execute_query(athena_client, queries.create_table('REF_INSTRUMENTS'))
        
        execute_query(athena_client, queries.create_table('V_REF_BOOKS'))
        execute_query(athena_client, queries.create_table('V_REF_INSTRUMENTS'))
        execute_query(athena_client, queries.create_table('V_REF_TRADERS'))

    except exceptions.ClientError as err:
        print(err.response['Error']['Message'])
        exit(err.response['Error']['Message'])

    exit(0)

def main(func, aws_profile):
    if func == 'build':
        build(aws_profile)
    elif func == 'clean_up':
        clean_up(aws_profile)
    else:
        print('incorrect function name')
if __name__ == '__main__':
        
    main(*sys.argv[1:])
