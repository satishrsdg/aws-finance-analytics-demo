import boto3
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


def main():
    print("hello world")
    _session = boto3.Session(profile_name='fin-demo')
    athena_client = _session.client('athena', region_name='eu-west-2')

    try:
        # execute_query(athena_client, queries.create_database('fin_demo'))

        # execute_query(athena_client, queries.create_table('PRICE_JSON'))
        # execute_query(athena_client, queries.create_table('TRADE_JSON'))
        
        # execute_query(athena_client, queries.create_table('REF_TRADERS'))
        # execute_query(athena_client, queries.create_table('REF_BOOKS'))
        #execute_query(athena_client, queries.create_table('REF_INSTRUMENTS'))
        
        execute_query(athena_client, queries.create_table('V_REF_BOOKS'))
        execute_query(athena_client, queries.create_table('V_REF_INSTRUMENTS'))
        execute_query(athena_client, queries.create_table('V_REF_TRADERS'))

    except exceptions.ClientError as err:
        print(err.response['Error']['Message'])
        exit(err.response['Error']['Message'])

    exit(0)


if __name__ == '__main__':
    main()
