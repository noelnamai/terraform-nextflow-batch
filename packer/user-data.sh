#!/bin/bash
#update the kernel and install basic packages
sudo yum -y update
sudo yum install -y wget
sudo yum install -y tree
sudo yum install -y bzip2
#install miniconda and awscli
sudo wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sudo bash Miniconda3-latest-Linux-x86_64.sh -b -f -p $HOME/miniconda
sudo $HOME/miniconda/bin/conda install -c conda-forge -y awscli
sudo rm Miniconda3-latest-Linux-x86_64.sh
export PATH=$PATH:/home/ec2-user/miniconda/bin/
#install and add ec2-user in the docker group
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo amazon-linux-extras disable docker
#install java and nextflow
sudo amazon-linux-extras install java-openjdk11
curl -s https://get.nextflow.io | bash
sudo chmod +x nextflow
sudo mv nextflow /usr/bin/
#install amazon ssm agent
sudo yum install -y amazon-ssm-agent
