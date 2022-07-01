# create a vpc
resource "aws_vpc" "tf_aws_batch_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tf-aws-batch-vpc"
  }
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

# create a public subnet-1
resource "aws_subnet" "tf_aws_batch_public_subnet_1" {
  vpc_id                  = aws_vpc.tf_aws_batch_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_1

  tags = {
    Name = "tf-aws-batch-public-subnet-1"
  }
}

# create a public subnet-2
resource "aws_subnet" "tf_aws_batch_public_subnet_2" {
  vpc_id                  = aws_vpc.tf_aws_batch_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_2

  tags = {
    Name = "tf-aws-batch-public-subnet-2"
  }
}

# create a public subnet-3
resource "aws_subnet" "tf_aws_batch_public_subnet_3" {
  vpc_id                  = aws_vpc.tf_aws_batch_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_3

  tags = {
    Name = "tf-aws-batch-public-subnet-3"
  }
}

# create a public subnet-4
resource "aws_subnet" "tf_aws_batch_public_subnet_4" {
  vpc_id                  = aws_vpc.tf_aws_batch_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone_4

  tags = {
    Name = "tf-aws-batch-public-subnet-4"
  }
}

# associate the route table with the subnet-1
resource "aws_route_table_association" "tf_aws_batch_public_subnet_rta_1" {
  subnet_id      = aws_subnet.tf_aws_batch_public_subnet_1.id
  route_table_id = aws_route_table.tf_aws_batch_public_rt.id
}

# associate the route table with the subnet-2
resource "aws_route_table_association" "tf_aws_batch_public_subnet_rta_2" {
  subnet_id      = aws_subnet.tf_aws_batch_public_subnet_2.id
  route_table_id = aws_route_table.tf_aws_batch_public_rt.id
}

# associate the route table with the subnet-3
resource "aws_route_table_association" "tf_aws_batch_public_subnet_rta_3" {
  subnet_id      = aws_subnet.tf_aws_batch_public_subnet_3.id
  route_table_id = aws_route_table.tf_aws_batch_public_rt.id
}

# associate the route table with the subnet-4
resource "aws_route_table_association" "tf_aws_batch_public_subnet_rta_4" {
  subnet_id      = aws_subnet.tf_aws_batch_public_subnet_4.id
  route_table_id = aws_route_table.tf_aws_batch_public_rt.id
}

# create the security group and allow ingress of port 22 and egress of all ports
resource "aws_security_group" "tf_aws_batch_sg" {
  vpc_id = aws_vpc.tf_aws_batch_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
