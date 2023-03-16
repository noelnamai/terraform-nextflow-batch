# specifying the base image
FROM ubuntu:18.04

# name and email of the person who maintains the file
LABEL maintainer="Noel Namai"

# updating ubuntu and installing other necessary software
RUN apt-get clean all \
	&& apt-get -y update  \
	&& apt-get install -y \
        build-essential \
		wget \
	&& apt-get clean

# install conda 
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda \
    && rm -rf Miniconda3-latest-Linux-x86_64.sh 

# add conda folder to path
ENV PATH=$PATH:/miniconda/condabin:/miniconda/bin

# install bwa
RUN conda install -c bioconda bwa=0.7.17

# chmod of /opt/
RUN chmod -R 777 /opt/

# change working directory to /opt/
WORKDIR /opt/

# specify the command executed when the container is started
CMD ["/bin/bash"]
