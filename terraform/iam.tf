# create batch ecs instance role
resource "aws_iam_role" "tf_batch_ecs_instance_role" {
  name = "tf-batch-ecs-instance-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# create an iam role policy to grant s3 full access
resource "aws_iam_role_policy" "tf_s3_full_access_policy" {
  name = "tf-s3-full-access-policy"
  role = aws_iam_role.tf_batch_ecs_instance_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3FullAccess",
        "Effect" : "Allow",
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "tf_batch_service_role" {
  name = "tf-batch-service-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "batch.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "tf_batch_ec2_spot_fleet_role" {
  name = "tf-batch-ec2-spot-fleet-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "spotfleet.amazonaws.com"
        }
      }
    ]
  })
}
