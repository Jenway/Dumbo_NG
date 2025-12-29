FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    bison \
    flex \
    wget \
    git \
    libgmp-dev \
    libmpc-dev \
    libssl-dev \
    python3 \
    python3-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN wget https://crypto.stanford.edu/pbc/files/pbc-0.5.14.tar.gz && \
    tar -xvf pbc-0.5.14.tar.gz && \
    cd pbc-0.5.14 && \
    ./configure && \
    make && \
    make install && \
    ldconfig

WORKDIR /opt
RUN git clone https://github.com/JHUISI/charm.git && \
    cd charm && \
    ./configure.sh && \
    make && \
    make install

RUN pip3 install --upgrade pip && \
    pip3 install \
      gevent \
      numpy \
      ecdsa \
      pysocks \
      gmpy2 \
      "zfec<1.6" \
      gipc \
      pycrypto \
      coincurve

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV LIBRARY_PATH=/usr/local/lib

# 6. 放代码
WORKDIR /workspace

