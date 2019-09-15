
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