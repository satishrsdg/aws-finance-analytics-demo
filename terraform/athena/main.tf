//https://binx.io/blog/2018/01/09/generate-temporary-aws-credentials/
variable "aws_iam_profile"  {}
variable "credentials_file" {}
variable "region" {}

provider "aws"{
   alias = "iam"
   region = "eu-west-2"
   shared_credentials_file = var.credentials_file
   profile = var.aws_iam_profile
}

resource "aws_iam_user" "athena_admin" {
  name = "athena_admin"
  provider = "aws.iam"
}

resource "aws_iam_access_key" "athena_access_key" {
  user = "${aws_iam_user.athena_admin.name}"
  provider = "aws.iam"
  //pgp_key = "keybase:${var.keybase}"
}

resource "aws_iam_user_policy" "admin_policy" {
  name = "admin_policy"
  user = "${aws_iam_user.athena_admin.name}"
    provider = "aws.iam"
  policy = <<EOF
{   "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "athena:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "glue:*",
            "Resource": "*"
        }
    ]
}
EOF
}

