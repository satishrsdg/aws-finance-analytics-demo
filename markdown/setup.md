# AWS Data Services Demonstrator - Initial Setup

This series of articles demonstrate some of the AWS Data Services capabilities. AWS areas covered as follows:
* **AWS CLI** to interact with AWS services
* **IAM** to set up users and assign policy documents to the users
* **Terraform** for Infrastructure as a Code (IaaC)
* **S3** buckets to store data
* **Firehose** capability to process high throughput and low latency data streams
* **Kinesis Data Gnerator** to produce random data to test Firehose
* **Athena** to define schema and query data uploaded to S3
* **Quicksight** to build dashboards against Athena
* **Sagemaker** to set-up Jupyer Lab, a data science workbench
* **Python** to programatically interact with AWS using packages such as: botos, pandas, numpy
* **Redshift** creating datawaerhouse and loading data from the streams
* **Lambda** transforming stream data using Lambda and Nodejs
* **CI/CD** Combining terraform with Travis CI

## Section-1: AWS CLI

AWS CLI allows users to interact with AWS from a terminal window. In the example below we will:
* create a user for this demo
* create aws credential keys 
* assign policy to access resources

_**Pre-requisites**_: A user with IAM permissions created in AWS console and assigned to a credentials profile, in the demo we use `iam-admin`

**Objectives**
* Create an admin user
* Create access keys for the user
* Create policy from a json document
* Attach policy to user

[File for code](../terraform/setup/create_users.sh)

**Create user**
```console
aws iam create-user --profile iam-admin \
                    --user-name admin \
                    --tags Key=project,Value=aws-fin-demo 
```

**Create access keys** to access AWS. These are usually stored in ~/.aws/credentials file under a profile name

```console
aws iam create-access-key --profile iam-admin --user-name admin
```

**Attach policies** to access AWS resources. Policy below specifies:

* Grant EC2 related actions against all resources. Restrict to micro, small and medium instances
* Grant S3, Sagemaker, Firehose and Athena access
* Stored in [policy.json](/terraform/setup/policy.json)

```json 
{
    "Version": "2012-10-17",
    "Statement": [
        {
             "Effect": "Allow",
            "Action": "ec2:*",
            "Resource": "*"
        },
        {
            "Sid": "DenyCertainInstanceTypesToBeCreated",
            "Effect": "Deny",
            "Action": [
                "ec2:RunInstances"
            ],
            "Resource": [
                "arn:aws:ec2:eu-west-2:account:instance/*"
            ],
            "Condition": {
                "StringNotEquals": {
                    "ec2:InstanceType": [
                        "t2.micro",
                        "t2.small",
                        "t2.medium"
                    ]
                }
            }
        },
        {
            "Sid": "AllowS3",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "sagemaker:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "firehose:*",
            "Resource": "*"
        },
                {
            "Effect": "Allow",
            "Action": "Athena:*",
            "Resource": "*"
        },
        {
         "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::*:role/firehose_role"
        }
    ]
}
```
_**Note:** Replace * (infront of role/firehose_role) with AWS account id_

**Create policy from json file**

```console
aws iam create-policy --profile iam-admin --policy-name admin-policy --policy-document file://../terraform/setup/policy.json
```

The output is as follows (some ids edited)

```json
{
    "Policy": {
        "PolicyName": "admin-policy",
        "PolicyId": "ANPATLYSFAAPUExample",
        "Arn": "arn:aws:iam::11111111111:policy/admin-policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2019-09-12T21:26:14Z",
        "UpdateDate": "2019-09-12T21:26:14Z"
    }
}
```

**Query the policy arn to attach it to a specific user**
```console
policy_arn=`aws iam list-policies --query "Policies[?PolicyName=='admin-policy'].Arn" --output text --profile iam-admin` 
aws iam attach-user-policy --policy-arn $policy_arn --user-name admin --profile iam-admin
```

## Section-2: Terraform

**Objectives**
* Create s3 bucket for equity data
* Create s3 bucket object to upload "aapl" and "ge" data

[Code File](/terraform/setup/main.tf)

```
resource "aws_s3_bucket" "equity_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  region = var.region

  tags   = {
    project = "aws-fin-demo"
    resource_group = var.resource_group
  }
}

locals {
  upload_directory = "${path.module}/data/"
}

#Use for_each loop multiple ipython notebooks into the base_bucket
resource "aws_s3_bucket_object" "equity_data" {
    for_each = fileset(local.upload_directory, "*.txt")
    bucket = aws_s3_bucket.equity_bucket.id
    key = "${each.value}"
    source = "${local.upload_directory}${each.value}"
    acl = "private"
    //etag = filemd5("${local.upload_directory}${each.value}")
    tags = {
        Group       = var.resource_group
    }
}
```

**Check the s3 bucket and if the files are uploaded**
```console
#List the contents of the AWS buckets
aws s3 ls --profile admin
```
## Next Steps

Use python packages to process the equity data

### Related Notebooks
* [00-Setup](/markdown/setup.md) 
* [01-Process S3 using python](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/process_s3_files.ipynb?flush_cache=true)
* [02-Visualization and Analytics](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/Visualization_and_Analytics.ipynb?flush_cache=true)
* [03-Risk Analytics](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/Risk_Analytics.ipynb?flush_cache=true)
* [04-Exploring Firehose,Athena and Quicksight](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/exploring_kinesis_firehose.ipynb?flush_cache=true)
* [05-Athena and Quicksights](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/athena_quicksight.ipynb?flush_cache=true)
* [06-Sagemaker to run the notebooks](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/sagemaker_jupyterlab.ipynb?flush_cache=true)
* [07_Transform stream data using Lambda](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/transform_lambda.ipynb?flush_cache=true)
* [08_Move data to Redshift using Glue](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/glue_redshift.ipynb?flush_cache=true)
* [09_CI/CD Terrform with Travis CI](https://nbviewer.jupyter.org/github/satishrsdg/aws-finance-analytics-demo/blob/master/jupyter-lab/integrating_terraform_travisci.ipynb?flush_cache=true)

