# print vpc id
output "vpc" {
  value = aws_vpc.tf_aws_batch_vpc.id
}

# print security group id
output "security_group" {
  value = aws_security_group.tf_aws_batch_sg.id
}

# print batch job queue name
output "job_queue" {
  value = aws_batch_job_queue.tf_batch_job_queue.name
}

# print state bucket id
output "s3_bucket" {
  value = aws_s3_bucket.tf_batch_data_bucket.id
}
