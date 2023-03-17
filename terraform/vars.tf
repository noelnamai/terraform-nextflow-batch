variable "aws_key_name" {}

variable "aws_iam_user_id" {}

# get all the docker repository names
locals {
  dockerfiles = [
    for file in fileset("../${path.module}", "docker/**") : split("/", file)[1]
  ]
}

# list all the subnets
locals {
  subnets = [for subnet in aws_subnet.tf_aws_batch_public_subnet : "${subnet}".id]
}

# names for s3 buckets
locals {
  s3_bucket_names = [
    "batch-audit-bucket", "batch-data-bucket-virginia", "batch-work-bucket-virginia",
  ]
}
