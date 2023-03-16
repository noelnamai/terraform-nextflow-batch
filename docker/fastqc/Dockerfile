# specifying the base image
FROM ubuntu:18.04

# name and email of the person who maintains the file
LABEL maintainer="Noel Namai"

# updating ubuntu and installing other necessary software
RUN apt-get -y update --fix-missing \
    && apt-get install -y \
        unzip \
        wget \
        build-essential \
        zlib1g-dev \
        libncurses5-dev \
        openjdk-8-jdk \
    && apt-get clean

# install Fastqc-0.11.9
RUN wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip \
    && unzip fastqc_v0.11.9.zip \
    && mv FastQC/* /usr/bin/ \
    && rm -rf FastQC fastqc_v0.11.9.zip

# chmod of /usr/bin/
RUN chmod -R 777 /usr/bin/

# change working directory to /opt/
WORKDIR /opt/

# specify the command executed when the container is started
CMD ["/bin/bash"]
