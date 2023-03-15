# define the aws key name
locals {
  key_name = data.vault_generic_secret.tf_secret_vault_development.data["AWS_KEY_NAME"]
}

# specify the aws region to deploy the compute environment
locals {
  region = data.vault_generic_secret.tf_secret_vault_development.data["AWS_DEFAULT_REGION"]
}

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
  s3_bucket_names = ["batch-data-bucket-virginia", "batch-work-bucket-virginia"]
}
