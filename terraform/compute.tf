# search for the latest ami that will be used to create the base ami
data "aws_ami" "tf_batch_amazon_linux_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["amzn2-packer-batch-ami"]
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

#create the aws batch compute environment
resource "aws_batch_compute_environment" "tf_batch_compute_environment" {
  compute_environment_name = "tf-batch-compute-environment"
  service_role             = aws_iam_role.tf_batch_service_role.arn
  type                     = "MANAGED"
  depends_on               = [aws_iam_role_policy_attachment.tf_batch_service_role]

  compute_resources {
    ec2_key_pair        = var.key_name
    image_id            = data.aws_ami.tf_batch_amazon_linux_ami.id
    instance_role       = aws_iam_instance_profile.tf_batch_ecs_instance_role.arn
    spot_iam_fleet_role = aws_iam_role.tf_batch_ec2_spot_fleet_role.arn
    bid_percentage      = 100
    min_vcpus           = 0
    max_vcpus           = 80
    type                = "EC2"
    instance_type       = ["c5", "m5"]
    allocation_strategy = "BEST_FIT_PROGRESSIVE"
    security_group_ids  = [aws_security_group.tf_aws_batch_sg.id]
    subnets = [
      aws_subnet.tf_aws_batch_public_subnet_1.id,
      aws_subnet.tf_aws_batch_public_subnet_2.id,
      aws_subnet.tf_aws_batch_public_subnet_3.id,
      aws_subnet.tf_aws_batch_public_subnet_4.id
    ]

    tags = {
      Name = "nextflow-compute"
    }
  }
}

# create aws batch job queue
resource "aws_batch_job_queue" "tf_batch_job_queue" {
  name                 = "tf-batch-job-queue"
  state                = "ENABLED"
  priority             = 1
  compute_environments = [aws_batch_compute_environment.tf_batch_compute_environment.arn]
  depends_on           = [aws_batch_compute_environment.tf_batch_compute_environment]

  tags = {
    Name = "tf-batch-job-queue"
  }
}
