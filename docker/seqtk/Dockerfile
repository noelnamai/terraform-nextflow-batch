#specifying the base image
FROM ubuntu:18.04

#name and email of the person who maintains the file
LABEL maintainer="Noel Namai"

# Updating ubuntu and installing other necessary software
RUN apt-get -y update --fix-missing \
    && apt-get install -y \
        unzip \
        git \
        build-essential \
        zlib1g-dev \
        libncurses5-dev \
    && apt-get clean

#install seqtk 1.3
RUN git clone https://github.com/lh3/seqtk.git \
    && cd seqtk \
    && make 

#add seqtk to path
ENV PATH="/seqtk:${PATH}"

#chmod of /usr/bin/
RUN chmod -R 777 /usr/bin/

# change working directory to /opt/
WORKDIR /opt/

#specify the command executed when the container is started
CMD ["/bin/bash"]
