FROM python:3.11-slim-bookworm

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

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
    export CFLAGS="-Wno-error" && \
    ./configure.sh && \
    make && \
    make install

WORKDIR /workspace
COPY requirements.in .
RUN uv pip install --system -r requirements.in

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV LIBRARY_PATH=/usr/local/lib

CMD ["bash"]