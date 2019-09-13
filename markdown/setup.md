# AWS Data Services Demonstrator - Initial Setup

This series of articles demonstrate some of the AWS Data Services capabilities. AWS areas are covered as follows:
* **AWS CLI** to interact with AWS services
* **IAM** to set up users and assign policy documents to the users
* **Terraform** for Infrastructure as a Code (IaaC)
* **S3** buckets to store data
* **Firehose** capability to process high velocity data streams
* **Kinesis Data Gnerator** to produce random data to test Firehose
* **Athena** to define schema and query data uploaded to S3
* **Quicksight** to build dashboards against Athena
* **Sagemaker** to set-up Jupyer Lab a data science workbench
* **Python** to programatically interact with AWS using packages: botos, pandas, numpy
* **Redshift** creating datawaerhouse and loading data from the streams
* **Lambda** transforming stream Lambda and Nodejs
* **CI/CD** Combining terraform with Travis CI

## Section-1: AWS CLI

AWS CLI allows to interact with AWS from a terminal window. In Jupyter Lab, aws cli can be invoked by setting the code cell to bash environment. In the example below we will create a user for this demo, create aws credential keys and assign policy to access resources.

_**Pre-requisites**_: A user with IAM permissions created in AWS console and assigned to a credentials profile iam-admin

**Objectives**
* Create an admin user
* Create access keys for the user
* Create policy from a json document
* Attach policy to user

[Code](../terraform/setup/create_users.sh)

**Create user**
```console
aws iam create-user --profile iam-admin \
                    --user-name admin \
                    --tags Key=project,Value=aws-fin-demo 
```

**Create the keys** that would be used to access AWS. These are usually stored in ~/.aws/credentials file with a profile name

```console
# create credentials
aws iam create-access-key --profile iam-admin --user-name admin
```

**Attach policies to access AWS resources. Below policy specifies**

* Grant EC2 related actions against all resources. Restrict to micro, small and medium instances
* Grant S3, Sagemaker, Firehose and Athena access
* Stored in policy.json
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
_**Note:**_ Replace * (infront of role/firehose_role) with AWS account id

**Create the policy from json file**

```console
aws iam create-policy --profile iam-admin --policy-name admin-policy --policy-document file://../terraform/setup/policy.json
```

The above command works from terminal window and not from jupyter. The output is as follows (some ids edited)

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
policy_arn=`aws iam list-policies --query "Policies[?PolicyName=='admin-policy'].Arn" --output text --profile iam-admin` && \
aws iam attach-user-policy --policy-arn $policy_arn --user-name admin --profile iam-admin
```

## Section-2: Terraform

**Objectives**
* Create s3 bucket for equity data
* Create s3 bucket object to upload "aapl" and "ge" data

[Code](../terraform/setup/main.tf)

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
* [00-Setup](./00_setup.ipynb) 
* [01-Process S3 using python](./01_Process_s3_files.ipynb)
* [02-Visualization and Analytics](./02_Visualization_and_Analytics.ipynb)
* [03-Risk Analytics](./03_Risk_Analytics.ipynb)
* [04-Exploring Firehose,Athena and Quicksight](./04_Exploring_Kinesis_Firehose.ipynb)
* [05-Athena and Quicksights](./05_Athena_Quicksight.ipynb)
* [06-Sagemaker to run the notebooks](./06_Sagemaker_jupyterlab.ipynb)
* [07_Transform stream data using Lambda](./07_Transform_lambda.ipynb)
* [08_Move data to Redshift using Glue](./08_Glue_Redshift.ipynb)
* [09_CI/CD Terrform with Travis CI](./09_Integrating_terraform_travisci.ipynb)

