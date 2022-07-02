# create an s3 bucket to store raw data and results
resource "aws_s3_bucket" "tf_batch_data_bucket" {
  bucket        = "batch-data-bucket"
  force_destroy = false
}

# create an s3 bucket to use as work directory
resource "aws_s3_bucket" "tf_batch_work_bucket" {
  bucket        = "batch-work-bucket"
  force_destroy = true
}

# enable versioning on s3 bucket objects
resource "aws_s3_bucket_versioning" "tf_batch_data_bucket_versioning" {
  bucket = aws_s3_bucket.tf_batch_data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# enable versioning on s3 bucket objects
resource "aws_s3_bucket_versioning" "tf_batch_work_bucket_versioning" {
  bucket = aws_s3_bucket.tf_batch_work_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}

# add intelligent tiering configuration for entire data bucket
resource "aws_s3_bucket_intelligent_tiering_configuration" "tf_batch_bucket_tiering" {
  bucket = aws_s3_bucket.tf_batch_data_bucket.bucket
  name   = "tf-batch-bucket-tiering"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }
}

# enable server side encryption for entire data bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_batch_encryption_configuration" {
  bucket = aws_s3_bucket.tf_batch_data_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# make the raw data s3 bucket objects private
resource "aws_s3_bucket_public_access_block" "tf_batch_data_bucket_private" {
  bucket                  = aws_s3_bucket.tf_batch_data_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# make the work directory s3 bucket objects private
resource "aws_s3_bucket_public_access_block" "tf_batch_work_bucket_private" {
  bucket                  = aws_s3_bucket.tf_batch_work_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
