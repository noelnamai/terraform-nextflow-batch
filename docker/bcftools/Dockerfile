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
        git \
        g++ \
        autoconf \
        automake \
        gcc \
        perl \
        libbz2-dev \
        liblzma-dev \
        libcurl4-gnutls-dev \
        libssl-dev \
        libncurses5-dev \
        make \
        ncurses-dev \
        pkg-config \
        zlib1g-dev \
        cmake \
     && apt-get clean

#install bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/1.15.1/bcftools-1.15.1.tar.bz2 \
    && tar xjf bcftools-1.15.1.tar.bz2 \
    && cd bcftools-1.15.1 \
    && ./configure --prefix=/usr/local/ \
    && make \
    && make install \
    && cd ..

#chmod of /opt/
RUN chmod -R 777 /opt/

#change working directory to /opt/
WORKDIR /opt/

#specify the command executed when the container is started
CMD ["/bin/bash"]
