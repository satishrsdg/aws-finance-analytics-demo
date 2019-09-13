provider "aws" {
   region = "eu-west-2"
   shared_credentials_file = var.credentials_file
   profile = var.aws_profile
}