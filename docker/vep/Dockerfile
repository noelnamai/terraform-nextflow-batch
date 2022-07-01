#specifying the base image
FROM ubuntu:18.04

#use variables for convenient updates and re-usability
ARG DEBIAN_FRONTEND=noninteractive

#name and email of the person who maintains the file
LABEL maintainer="Noel Namai"

# Updating ubuntu and installing other necessary software
RUN apt-get -y update --fix-missing \
    && apt-get install -y \
        unzip \
        curl \
        gcc \
        git \
        perl \
        build-essential \
        liblzma-dev \
        libbz2-dev \
        zlib1g-dev \
        libdbi-perl \
        libncurses5-dev \
        libdbd-mysql-perl \
        libmodule-build-perl \
    && apt-get clean

#install vep 
RUN curl -L -O https://github.com/Ensembl/ensembl-vep/archive/release/106.zip \
    && unzip 106.zip \
    && rm 106.zip \
    && cd ensembl-vep-release-106 \
    && perl INSTALL.pl

#chmod of /opt/
RUN chmod -R 777 /opt/

# change working directory to /opt/
WORKDIR /opt/

#specify the command executed when the container is started
CMD ["/bin/bash"]
