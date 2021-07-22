# RVN-Electrumx-docker
Repository for building a docker container from the official [RVN Electrumx Server](https://github.com/Electrum-RVN-SIG/electrumx-ravencoin)

## Docker Hub repository
Updated images can be  found in the Docker Hub Repository [https://hub.docker.com/repository/docker/dramirezrt/ravencoin-electrumx-server](https://hub.docker.com/repository/docker/dramirezrt/ravencoin-electrumx-server)

## Prerequisites
- Have access to a Raven Core Node (user and password, for RPC calls)
- Docker Engine

## Usage

`
docker run  -d \                                      
            -v /electrum-data/:/electrum-data \
            -e DAEMON_URL="http://<user>:<password>@<ip>:<port>" \
            -p 50001:50001 \
            -p 50002:50002 \
            -p 50004:50004 \
            -p 8000:8000 \
            -e SERVICES="tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000" \
            --name rvn-electrumx-server \
            dramirezrt/ravencoin-electrumx-server
`
  
## Example
  
docker run  -d \                                      
            -v /electrum-data/:/electrum-data \
            -e DAEMON_URL="http://username:password@localhost" \
            -p 50002:50002 \
            -e SERVICES="ssl://:50002" \
            --name rvn-electrumx-server \
            dramirezrt/ravencoin-electrumx-server
  
For a full list of environment variables check [https://electrumx-ravencoin.readthedocs.io/en/latest/environment.html](https://electrumx-ravencoin.readthedocs.io/en/latest/environment.html)
