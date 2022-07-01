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
        wget \
        liblzma-dev \
        libbz2-dev \
        zlib1g-dev \
        libncurses5-dev \
        openjdk-8-jdk \
    && apt-get clean

#install Trimmomatic
RUN wget https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip \
    && unzip Trimmomatic-0.39.zip \
    && mv Trimmomatic-0.39/* /opt/ \
    && rm Trimmomatic-0.39.zip

#chmod of /opt/
RUN chmod -R 777 /opt/

# change working directory to /opt/
WORKDIR /opt/

#specify the command executed when the container is started
CMD ["/bin/bash"]
