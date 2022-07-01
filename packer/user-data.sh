#!/bin/bash
sudo yum -y update
sudo yum install -y wget
sudo yum install -y tree
sudo yum install -y bzip2
sudo wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
sudo bash Miniconda3-latest-Linux-x86_64.sh -b -f -p $HOME/miniconda
sudo $HOME/miniconda/bin/conda install -c conda-forge -y awscli
rm Miniconda3-latest-Linux-x86_64.sh
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo amazon-linux-extras disable docker
sudo amazon-linux-extras install java-openjdk11
curl -s https://get.nextflow.io | bash
sudo chmod +x nextflow
sudo mv nextflow /usr/bin/
export PATH=$PATH:/home/ec2-user/miniconda/bin/