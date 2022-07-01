# define the aws profile to use
variable "profile" {
  default = "noelnamai"
}

# define the aws key name
variable "key_name" {
  default = "noelnamai"
}

# specify the aws region to deploy the compute environment
variable "region" {
  default = "us-east-1"
}

# specify availability zone-1
variable "availability_zone_1" {
  default = "us-east-1a"
}

# specify availability zone-2
variable "availability_zone_2" {
  default = "us-east-1b"
}

# specify availability zone-3
variable "availability_zone_3" {
  default = "us-east-1c"
}

# specify availability zone-4
variable "availability_zone_4" {
  default = "us-east-1d"
}
