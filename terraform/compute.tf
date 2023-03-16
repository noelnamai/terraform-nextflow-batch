# search for the latest ami that will be used to create the base ami
data "aws_ami" "tf_batch_amazon_linux_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["amzn2-linux-packer-batch-ami-*"]
  }
}

resource "aws_iam_role_policy_attachment" "tf_batch_ecs_instance_role" {
  role       = aws_iam_role.tf_batch_ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "tf_batch_ecs_instance_role" {
  name = "tf-batch-ecs-instance-role"
  role = aws_iam_role.tf_batch_ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "tf_batch_service_role" {
  role       = aws_iam_role.tf_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "tf_batch_ec2_spot_fleet_role" {
  role       = aws_iam_role.tf_batch_ec2_spot_fleet_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
}

#create the aws batch spot compute environment
resource "aws_batch_compute_environment" "tf_batch_compute_environment_spot_1" {
  compute_environment_name = "tf-batch-compute-environment-spot-1"
  service_role             = aws_iam_role.tf_batch_service_role.arn
  type                     = "MANAGED"
  depends_on               = [aws_iam_role_policy_attachment.tf_batch_service_role]

  compute_resources {
    ec2_key_pair        = local.key_name
    image_id            = data.aws_ami.tf_batch_amazon_linux_ami.id
    instance_role       = aws_iam_instance_profile.tf_batch_ecs_instance_role.arn
    spot_iam_fleet_role = aws_iam_role.tf_batch_ec2_spot_fleet_role.arn
    bid_percentage      = 50
    min_vcpus           = 0
    max_vcpus           = 80
    type                = "SPOT"
    instance_type       = ["m5.xlarge", "m5.2xlarge", "m5.4xlarge"]
    allocation_strategy = "BEST_FIT"
    security_group_ids  = [aws_security_group.tf_aws_batch_sg.id]
    subnets             = local.subnets

    tags = {
      Name = "nf-compute-spot-1"
    }
  }
}

#create the aws batch on-demand compute environment
resource "aws_batch_compute_environment" "tf_batch_compute_environment_spot_2" {
  compute_environment_name = "tf-batch-compute-environment-spot-2"
  service_role             = aws_iam_role.tf_batch_service_role.arn
  type                     = "MANAGED"
  depends_on               = [aws_iam_role_policy_attachment.tf_batch_service_role]

  compute_resources {
    ec2_key_pair        = local.key_name
    image_id            = data.aws_ami.tf_batch_amazon_linux_ami.id
    instance_role       = aws_iam_instance_profile.tf_batch_ecs_instance_role.arn
    spot_iam_fleet_role = aws_iam_role.tf_batch_ec2_spot_fleet_role.arn
    bid_percentage      = 50
    min_vcpus           = 0
    max_vcpus           = 80
    type                = "SPOT"
    instance_type       = ["c5.xlarge", "c5.2xlarge", "c5.4xlarge"]
    allocation_strategy = "BEST_FIT"
    security_group_ids  = [aws_security_group.tf_aws_batch_sg.id]
    subnets             = local.subnets

    tags = {
      Name = "nf-compute-spot-2"
    }
  }
}

# create aws batch job queue
resource "aws_batch_job_queue" "tf_batch_job_queue" {
  name     = "tf-batch-job-queue"
  state    = "ENABLED"
  priority = 1

  compute_environments = [
    aws_batch_compute_environment.tf_batch_compute_environment_spot_1.arn,
    aws_batch_compute_environment.tf_batch_compute_environment_spot_2.arn
  ]

  depends_on = [
    aws_batch_compute_environment.tf_batch_compute_environment_spot_1,
    aws_batch_compute_environment.tf_batch_compute_environment_spot_2
  ]

  tags = {
    Name = "tf-batch-job-queue"
  }
}
