//https://github.com/aocenas/redshift-data-pipeline-demo
//https://itnext.io/creating-a-blueprint-for-microservices-and-event-sourcing-on-aws-291d4d5a5817
//https://awslabs.github.io/amazon-kinesis-data-generator/web/producer.html?upid=us-west-2_19jm6KFg8&ipid=us-west-2:ba69f569-d766-4a0f-a473-4888b7c1e393&cid=7l2908i9991ofsjvons9tnf0st&r=us-west-2

//https://read.acloud.guru/deep-dive-into-aws-kinesis-at-scale-2e131ffcfa08
provider "aws"{
   region = "eu-west-2"
   shared_credentials_file = var.credentials_file
   profile = var.aws_profile
}

provider "aws"{
   alias = "iam"
   region = "eu-west-2"
   shared_credentials_file = var.credentials_file
   profile = var.aws_iam_profile
}