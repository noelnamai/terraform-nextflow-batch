# generate subnet addresses under cidr prefix
module "subnet_addrs" {
  source          = "hashicorp/subnets/cidr"
  base_cidr_block = "172.32.0.0/16"

  networks = [
    { name = "us-east-1a", new_bits = 8 },
    { name = "us-east-1b", new_bits = 8 },
    { name = "us-east-1c", new_bits = 8 },
    { name = "us-east-1d", new_bits = 8 },
    { name = "us-east-1e", new_bits = 8 },
    { name = "us-east-1f", new_bits = 8 },
  ]
}

# create a vpc
resource "aws_vpc" "tf_aws_batch_vpc" {
  cidr_block           = module.subnet_addrs.base_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-aws-batch-vpc"
  }
}

# create a public subnets
resource "aws_subnet" "tf_aws_batch_public_subnet" {
  for_each                = module.subnet_addrs.network_cidr_blocks
  vpc_id                  = aws_vpc.tf_aws_batch_vpc.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-aws-batch-public-subnet-${each.key}"
  }
}

#allow vpc flow logs to s3
resource "aws_flow_log" "tf_aws_flow_log" {
  log_destination      = aws_s3_bucket.tf_batch_buckets["batch-work-bucket-virginia"].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.tf_aws_batch_vpc.id
}

# create the internet gateway
resource "aws_internet_gateway" "tf_aws_batch_igw" {
  vpc_id = aws_vpc.tf_aws_batch_vpc.id

  tags = {
    Name = "tf-aws-batch-igw"
  }
}

# create a route table for the vpc and associate with the public subnet
resource "aws_route_table" "tf_aws_batch_public_rt" {
  vpc_id = aws_vpc.tf_aws_batch_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_aws_batch_igw.id
  }

  tags = {
    Name = "tf-aws-batch-public-rt"
  }
}

# create the security group and allow ingress of port 22 and egress of all ports
resource "aws_security_group" "tf_aws_batch_sg" {
  name        = "tf-aws-batch-sg"
  description = "security group for the batch vpc"
  vpc_id      = aws_vpc.tf_aws_batch_vpc.id

  ingress {
    description = "ssh-port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  ingress {
    description = "internet-port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  ingress {
    description = "grafana-port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  ingress {
    description = "mysql-port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  ingress {
    description = "webservers-port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  ingress {
    description = "prometheus-server-port"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  ingress {
    description = "prometheus-node-exporter-port"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [module.subnet_addrs.base_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_vpc.tf_aws_batch_vpc
  ]

  tags = {
    Name = "tf-aws-batch-sg"
  }
}

# associate the route table with the subnets
resource "aws_route_table_association" "tf_aws_batch_public_subnet_rta" {
  for_each       = aws_subnet.tf_aws_batch_public_subnet
  subnet_id      = aws_subnet.tf_aws_batch_public_subnet[each.key].id
  route_table_id = aws_route_table.tf_aws_batch_public_rt.id
}
