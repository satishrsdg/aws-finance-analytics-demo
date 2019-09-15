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