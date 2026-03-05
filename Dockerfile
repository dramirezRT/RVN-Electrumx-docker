FROM ubuntu:22.04

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-dev \
        libssl-dev \
        libffi-dev \
        libleveldb-dev \
        gcc \
        g++ \
        build-essential \
        cmake \
        curl \
        jq \
        wget \
        git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /electrum-rvn-server

COPY ./bin/electrumx_init /usr/local/bin/electrumx_init
COPY ./patches/ /tmp/patches/

ARG TAG=latest
ENV TAG=${TAG}

RUN chmod +x /usr/local/bin/electrumx_init \
    && /usr/local/bin/electrumx_init install \
    && python3 /tmp/patches/fix-aiohttp-basic-auth.py /electrum-rvn-server/electrumx/server/daemon.py \
    && python3 setup.py install --force --record installed_files.txt \
    && rm -rf /tmp/patches

# For the full list of Environment variables check:
# https://electrumx-ravencoin.readthedocs.io/en/latest/environment.html
VOLUME ["/electrum-data"]
ENV ED_DIR=/electrum-data
ENV DB_DIRECTORY=/electrum-data/db
ENV DAEMON_URL="http://username:password@hostname:port/"
ENV COIN=Ravencoin
ENV SERVICES="tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000"
ENV SSL_CERTFILE=${ED_DIR}/ssl_cert/electrumx.crt
ENV SSL_KEYFILE=${ED_DIR}/ssl_cert/electrumx.key
ENV ALLOW_ROOT=1
ENV COST_SOFT_LIMIT=0
ENV COST_HARD_LIMIT=0
ENV BANDWIDTH_UNIT_COST=1000

EXPOSE 50001 50002 50004 8000

CMD ["/bin/bash", "-c", "electrumx_init init"]
