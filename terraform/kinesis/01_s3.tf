#Create the base_bucket for the project
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