packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amzn2-ami" {
  ami_name      = "amzn2-packer-batch-ami"
  profile       = "noelnamai"
  region        = "us-east-1"
  instance_type = "m5.xlarge"
  ssh_username  = "ec2-user"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }

    most_recent = true
    owners      = ["591542846629"]
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 100
    delete_on_termination = true
  }

  force_deregister      = "true"
  force_delete_snapshot = "true"
}

build {
  name = "amzn2-packer-batch-ami"

  sources = [
    "source.amazon-ebs.amzn2-ami"
  ]

  provisioner "file" {
    source      = "user-data.sh"
    destination = "/tmp/user-data.sh"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp/ && chmod 755 user-data.sh && ./user-data.sh"
    ]
  }
}
