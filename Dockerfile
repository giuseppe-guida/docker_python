# Centos 7 based image with Python 3.5.2 installed from conda
FROM centos:7 as python352_conda

## runs using the root account
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV HOME /opt

RUN yum update -y
RUN yum install -y build-essential \
        curl \
        openssh-server \
        openssl-devel \
        net-tools\
        pkg-config \
        pigz \
        wget \
        xz-utils \
        zlib1g-dev \
        vim \
        bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Install Python
RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh \
    && /bin/bash Miniconda3-4.2.12-Linux-x86_64.sh -b
ENV PYTHON_BIN_PATH=$HOME/miniconda3/bin
ENV PYTHON_EXECUTABLE=$PYTHON_BIN_PATH/python
ENV PIP_EXECUTABLE=$PYTHON_BIN_PATH/pip

# create links
RUN ln -s $PIP_EXECUTABLE /usr/bin/pip3
RUN ln -s $PYTHON_EXECUTABLE /usr/bin/python3

RUN $PIP_EXECUTABLE install --upgrade pip

FROM python352_conda as data_science_utilities
MAINTAINER data-science-core <gl-ai-datascience-core@coolblue.nl>

RUN yum install -y git gcc-gfortran gcc-c++

WORKDIR /tmp
COPY requirements.txt ./requirements.txt
COPY requirements-dev.txt ./requirements-dev.txt

## Install python packages
RUN pip3 install setuptools==39.0.1 --ignore-installed
RUN pip3 install -r ./requirements-dev.txt
RUN rm -r $HOME/.cache/pip

RUN ln -s $PYTHON_BIN_PATH/pytest /usr/bin/pytest

WORKDIR $HOME/project/data-science-utilities/
