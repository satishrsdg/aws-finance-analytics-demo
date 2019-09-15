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
