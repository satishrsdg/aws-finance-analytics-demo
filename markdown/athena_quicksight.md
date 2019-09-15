# Athena and Quicksight

Amazon Athena is an interactive query service to analyze data in Amazon S3 using standard SQL. Athena is serverless and is out-of-the-box integrated with AWS Glue Data Catalog. Amazon Athena uses Presto with full standard SQL support and works with a variety of standard data formats, including CSV, JSON, ORC, Avro, and Parquet. Presto is an open source distributed SQL query engine for running interactive analytic queries against data sources of all sizes ranging from gigabytes to petabytes.

Amazon QuickSight is a fast, cloud-powered business intelligence service that makes it easy to deliver insights to everyone in your organization.

As a fully managed service, QuickSight lets you easily create and publish interactive dashboards that include ML Insights. Dashboards can then be accessed from any device, and embedded into your applications, portals, and websites.

## Objective
* Create a table against price and transaction offloaded from kinsesis streams and stored in s3
* Create a reference table for books, traders and instruments. 
* All of the reference data is stored in the same s3 bucket, hence three views are created to filter in only the appropirate reference data
* Create datasets within Quicksight
* Build a dashboard

## Setup

Create a user `athena_admin` using Terraform. Obtain the corresponding ssh_keys and store it in the `.aws/credentials` file

### Create user
[Code File](/terraform/athena/main.tf)

```

```
1.Create user, access key and assign policy
2.Decrypt the secret and load it to credentials file
3. use the profile as paramater in the python program   

## Table Structures

| Table Name | Source | Fields | Source  Storage Format |
|---------------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|------------------------|
| price_json | s3://rsdg-fin-demo-price-eu-west-2 | * instrument_id int <br> * price int <br> * ts string <br> | json |
| trade_json | s3://rsdg-fin-demo-transaction-eu-west-2 | * book_id int <br> * trader_id int <br> * instrument_id int <br> * qty int <br> * price int <br> * ts string <br> | json |
| books | s3://rsdg-fin-demo-reference-eu-west-2 | * ref_type string <br> * book_id int <br> * name string <br> * manager string <br> * trading_area string <br> | csv |
| instruments | s3://rsdg-fin-demo-reference-eu-west-2 | * ref_type string <br> * instrument_id int <br> * instrument_name int <br> *  instrument_type string * exchange_name string | csv |
| traders | s3://rsdg-fin-demo-reference-eu-west-2 | * ref_type string <br> * trader_id int <br> * trader_name string <br> * manager_name string <br> | csv |
| v_books | books | books.* where ref_type = 'books' | table rows |
| v_instruments | instruments | books.* where ref_type = 'instruments' | table rows |
| v_trades | traders | books.* where ref_type = 'traders' | table rows |

## Approach

Previous examples used `Terraform` which has a [declarative programming model](!https://tylermcginnis.com/imperative-vs-declarative-programming/). In declrative programming model, the end state is specified and the programming model achieves it by making the required changes. The programming model deduces the required path to achieve the end state. 

This section uses imperative programming model, where the programming model is explicitly told the path and the logic to achieve the end state. This section uses [python boto3](!https://realpython.com/python-boto3-aws-s3/) package to build the Athen database and tables. Terraform does not have full support for Athena yet, hence this route



## Code blocks

[Code File](/python/build_athena.py)
Executing query using boto3 package `boto3.client.start_query_execution` is the heart of this approach.It executes queries against the athena database. Since the queries are executed in AWS progaramatically, the results and errors are stored in `AWS S3 buckets` itself. 

```python
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
# Result configuration above specifies a S3 bucket to store the results
```

The above function is repeatedly exectued to construct the database and the tables

```python
    execute_query(athena_client, queries.create_database('fin_demo'))

    execute_query(athena_client, queries.create_table('PRICE_JSON'))
    execute_query(athena_client, queries.create_table('TRADE_JSON'))
    
    execute_query(athena_client, queries.create_table('REF_TRADERS'))
    execute_query(athena_client, queries.create_table('REF_BOOKS'))
    execute_query(athena_client, queries.create_table('REF_INSTRUMENTS'))
    
    execute_query(athena_client, queries.create_table('V_REF_BOOKS'))
    execute_query(athena_client, queries.create_table('V_REF_INSTRUMENTS'))
    execute_query(athena_client, queries.create_table('V_REF_TRADERS'))
```
## Connecting SQlworkbench to Athena

We can use [sqlworkbench to connect to Athena](https://aws.amazon.com/blogs/big-data/connect-to-amazon-athena-with-federated-identities-using-temporary-credentials/)

**Note:** Implementing a simpler access mechanism to one described in the link above
1. Download the Athena jar files as per the above link
2. Use the credentials in **Athena set-up section** above to configure sqlworkebench
3. Use the credentials in sqlworkbench

## Running queries


