# Explore AWS Streams 

This section demonstrates AWS streaming using Kinesis Firehose which is a version of plain Kinesis enhanced with delivery to a S3 bucket or Redshift baked along with basic Kinesis basic

### Objectives
* Set-up `Kinesis Firehose` streams (Terraform) for price and trade data
* Use AWS CLI and python to demonstrate data loaded to S3
* Generate random data using `Kinesis Data Generator` for price and trade data
* Validate data loaded to S3

## Section-1: Set-up Kinesis Firehose streams

### Set-up Roles and Role Policy

Services such as Kinesis Firehose work without human intervention. Yet, an identity is required to run theses servics. In AWS, roles (service principals) are the identities to run such applications. Roles are associated with policies granting relevant permissions to the roles

**kinesis_role can be used to run three services: Firehose, Redshift and Glue**
[Code File](/terraform/kinesis/01_iam_role.tf)

Role and role policies use a different provider which is associated with an user who has `IAMFullAccesss` permissons.

```json
resource "aws_iam_role" "kinesis_role" {
    name = "firehose_role"
    provider = "aws.iam"
    #Ensure the opening braces is the first character of new line
    #Json does not like white spaces before curly braces
    assume_role_policy = <<EOF
{
            "Version": "2012-10-17",
            "Statement": [{
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": [
                        "firehose.amazonaws.com", 
                        "redshift.amazonaws.com",
                        "glue.amazonaws.com"
                    ]
                },
                "Effect": "Allow"
            }]
        }
    EOF
    tags = {
     Group     = "${var.resource_group}"
    }
}
```

**kinesis_role_policy grants access to perform operations on s3 bucket**

[Code File](/terraform/kinesis/01_iam_role_policy.tf)

```json
resource "aws_iam_role_policy" "kinesis_role_policy" {
    name = "kinesis_role_policy"
    provider = "aws.iam"
    role = "${aws_iam_role.kinesis_role.id}"
    #Ensure the opening braces is the first character of new line
    #Json does not like white spaces before curly braces
    policy = <<EOF
{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.price_bucket.arn}",
                "${aws_s3_bucket.price_bucket.arn}/*",
                "${aws_s3_bucket.transaction_bucket.arn}",
                "${aws_s3_bucket.transaction_bucket.arn}/*"
            ]
        }]  
    }
    EOF
  
}
```
_**Note**:_ Policy makes reference to s3 bucket. Terraform deteremines the order in which to execute code blocks spread across multiple files based on dependencies. The code block for s3 bucket would get executed before the policy

### Set-up S3 bucket to dump data from Kinesis Firehose streams

[Code File](../terraform/kinesis/01_s3.tf)

**Bucket for unloading data from price stream**

```json
resource "aws_s3_bucket" "price_bucket" {
  bucket        = "${var.bucket_name}-price-${var.region}"
  acl           = "private"
  
  # delete all data from this bucket before destroy
  force_destroy = true   

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Description = "Bucket for storing price data"
    Group       = var.resource_group
    }
}

**Bucket for unloading data from transaction stream**

```json
resource "aws_s3_bucket" "transaction_bucket" {
  bucket        = "${var.bucket_name}-transaction-${var.region}"
  acl           = "private"
  
  # delete all data from this bucket before destroy
  force_destroy = true   

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Description = "Bucket for storing transaction data"
    Group       = var.resource_group
    }
}
```

**Bucket for uploading data for reference data**

```json
resource "aws_s3_bucket" "reference_bucket" {
  bucket        = "${var.bucket_name}-reference-${var.region}"
  acl           = "private"
  
  # delete all data from this bucket before destroy
  force_destroy = true   

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Description = "Bucket for storing transaction data"
    Group       = var.resource_group
    }
}
```

**Bucket objects for copying data from local machine to S3 bucket**
```json
locals {
  upload_directory = "${path.module}/data/"
}

#Use for_each loop multiple ipython notebooks into the base_bucket
resource "aws_s3_bucket_object" "reference_data" {
    for_each = fileset(local.upload_directory, "*.csv")
    bucket = aws_s3_bucket.reference_bucket.id
    key = "${each.value}"
    source = "${local.upload_directory}${each.value}"
    acl = "private"
    //etag = filemd5("${local.upload_directory}${each.value}")
    tags = {
        Group       = var.resource_group
        modfied = "v0.0.002"
    }
}
```
### Set-up Kinesis Firehose streams
[Code](/terraform/kinesis/02_firehose.tf)

**Firehose stream for Price**

```json
resource "aws_kinesis_firehose_delivery_stream" "price_hose" {
    name        = "price_hose"
    tags = {
        Group     = "${var.resource_group}"
    }
    
    destination = "s3"
    s3_configuration {
        role_arn   = "${aws_iam_role.kinesis_role.arn}"
        bucket_arn = "${aws_s3_bucket.price_bucket.arn}"
        buffer_interval = 60
  
    }
}
```

**Firehose stream for Transactions**

```json
resource "aws_kinesis_firehose_delivery_stream" "transaction_hose" {
    name        = "transaction_hose"
    tags = {
        Group     = "${var.resource_group}"
    }
    
    destination = "s3"

    s3_configuration {
        role_arn   = "${aws_iam_role.kinesis_role.arn}"
        bucket_arn = "${aws_s3_bucket.transaction_bucket.arn}"
        buffer_interval = 60
  
    }

}
```
## Section-2: Test the Kinesis streams (AWS CLI)

* Use command line to put a dummy record to firehose
* Display contents of  S3 files where FireHose has unloaded content

[Refer Notebook](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-labexploring_kinesis_firehose.ipynb?flush_cache=true)

In another terminal run the this python code block

## Section-3: Load data with Kinesis Data Generator

[Kinesis Data Generator (KDG)](https://awslabs.github.io/amazon-kinesis-data-generator)

The KDG extends faker.js, an open source random data generator. For full documentation of the items that can be "faked" by faker.js, see the [faker.js documentation.](https://github.com/Marak/faker.js/blob/master/Readme.md)

### Script for generating Price
```json
{
    "instrument_id": {{random.number(50)}},
    "price": {{random.number(
        {
            "min":1,
            "max":15
        }
    )}},
    "ts": "{{date.now}}"
}
```
[KDG Screenshot - Price](./images/price_hose.png)

### Script for generating Transactions
```json
{
    "book_id": {{random.number(
        {
            "min":1,
            "max":10
        })}},
    "trader_id": {{random.number(
        {
            "min":1,
            "max":20
        })}},
    "instrument_id": {{random.number(
        {
            "min":1,
            "max":50
        })}},
    "qty": {{random.number(
        {
            "min":1000,
            "max":5000
        })}},
    "price": {{random.number(
        {
            "min":1,
            "max":15
        })}},
    "ts": "{{date.now}}"
}
```
[KDG Screenshot - Transactions](./images/price_hose.png)

## Section-4: Testing the S3 buckets

Let the KDG run for about 10 seconds. 
* Configure Price to run at 1000 records per second, choose the script to run against `price_hose` stream
* Transactions to run at 100 records per second against `transaction_hose` stream

[Refer Notebook](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-labexploring_kinesis_firehose.ipynb?flush_cache=true)

## Next Steps
* Configure the data to be loaded into AWS Athena
* Build quicksight dashboard


### Related Notebooks
* [00-Setup](/markdown/setup.md) 
* [01-Process S3 using python](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/process_s3_files.ipynb?flush_cache=true)
* [02-Visualization and Analytics](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/visualization_and_analytics.ipynb?flush_cache=true)
* [03-Risk Analytics](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/risk_analytics.ipynb?flush_cache=true)
* [04-Exploring Firehose,Athena and Quicksight](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/exploring_kinesis_firehose.ipynb?flush_cache=true)
* [05-Athena and Quicksights](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/athena_quicksight.ipynb?flush_cache=true)
* [06-Sagemaker to run the notebooks](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/sagemaker_jupyterlab.ipynb?flush_cache=true)
* [07_Transform stream data using Lambda](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/transform_lambda.ipynb?flush_cache=true)
* [08_Move data to Redshift using Glue](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/glue_redshift.ipynb?flush_cache=true)
* [09_CI/CD Terrform with Travis CI](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/integrating_terraform_travisci.ipynb?flush_cache=true)