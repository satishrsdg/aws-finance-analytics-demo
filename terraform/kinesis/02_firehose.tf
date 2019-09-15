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