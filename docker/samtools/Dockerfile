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

#install samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.15.1/samtools-1.15.1.tar.bz2 \
    && tar xjf samtools-1.15.1.tar.bz2 \
    && rm samtools-1.15.1.tar.bz2 \
    && cd samtools-1.15.1 \
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
