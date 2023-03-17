# create an s3 buckets to store data and results
resource "aws_s3_bucket" "tf_batch_buckets" {
  for_each      = toset(local.s3_bucket_names)
  bucket        = each.key
  force_destroy = true

  logging {
    target_bucket = "batch-audit-bucket"
  }
}

# disable or enable versioning on s3 bucket objects
resource "aws_s3_bucket_versioning" "tf_batch_buckets_versioning" {
  for_each = aws_s3_bucket.tf_batch_buckets
  bucket   = aws_s3_bucket.tf_batch_buckets[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

# enable server side encryption for entire data bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_batch_buckets_encryption_configuration" {
  for_each = aws_s3_bucket.tf_batch_buckets
  bucket   = aws_s3_bucket.tf_batch_buckets[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# block s3 public access
resource "aws_s3_bucket_public_access_block" "example" {
  for_each = aws_s3_bucket.tf_batch_buckets
  bucket   = aws_s3_bucket.tf_batch_buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
