#FROM python:3.7-alpine3.14
FROM ubuntu:18.04

ENV LANG C.UTF-8

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        python3.8 \
        python3-pip \
        libssl-dev \
        libffi-dev \
        libleveldb-dev \
        gcc \
        build-essential \
        python3.8-dev \
        cmake \
        curl \
        jq \
        wget \
        cron \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /usr/bin/python3.8 /usr/bin/python3

WORKDIR /electrum-rvn-server
COPY ./bin/electrumx_init /usr/local/bin/electrumx_init
RUN chmod +x /usr/local/bin/electrumx_init \
    && /usr/local/bin/electrumx_init install

COPY ./files/electrumx /etc/cron.d/electrumx
RUN chmod 0644 /etc/cron.d/electrumx \
    && touch electrumx_update.log \
    && ln -s /electrum-rvn-server/electrumx_update.log /var/log/electrumx_update.log \
    && crontab /etc/cron.d/electrumx

# For the full list of Environment variables check - https://github.com/Electrum-RVN-SIG/electrumx-ravencoin/blob/master/docs/environment.rst
VOLUME ["/electrum-data"]
ENV ED_DIR              /electrum-data
ENV DB_DIRECTORY        /electrum-data/db
ENV DAEMON_URL          "http://username:password@hostname:port/"
ENV COIN Ravencoin
ENV SERVICES            "tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000"
ENV SSL_CERTFILE        ${ED_DIR}/ssl_cert/electrumx.crt
ENV SSL_KEYFILE         ${ED_DIR}/ssl_cert/electrumx.key
ENV ALLOW_ROOT          1
ENV COST_SOFT_LIMIT     0
ENV COST_HARD_LIMIT     0
ENV BANDWIDTH_UNIT_COST 1000


EXPOSE 50001 50002 50004 8000


CMD ["bash", "-c", "cron", "&&", "electrumx_init", "init"]

