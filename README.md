# RVN-Electrumx-docker

Repository for building a docker container from the official [RVN Electrumx Server](https://github.com/Electrum-RVN-SIG/electrumx-ravencoin)

## Docker Hub repository

Updated images can be found in the Docker Hub Repository [https://hub.docker.com/repository/docker/dramirezrt/ravencoin-electrumx-server](https://hub.docker.com/repository/docker/dramirezrt/ravencoin-electrumx-server)

## Available Tags

| Tag | ElectrumX Version | Base Image |
|-----|-------------------|------------|
| `latest` | v1.12.1 | Ubuntu 22.04 |
| `v1.12.1` | v1.12.1 | Ubuntu 22.04 |
| `v1.12.0` | v1.12.0 | Ubuntu 22.04 |
| `v1.11.0` | v1.11.0 | Ubuntu 22.04 |
| `v1.10.6` | v1.10.6 | Ubuntu 22.04 |
| `v1.10.5` | v1.10.5 | Ubuntu 22.04 |
| `v1.10.4` | v1.10.4 | Ubuntu 22.04 |
| `v1.10.3` | v1.10.3 | Ubuntu 22.04 |
| `1.10.2` | v1.10.2 | Ubuntu 18.04 (legacy) |
| `1.10.0` | v1.10.0 | Ubuntu 18.04 (legacy) |
| `1.9.3` | v1.9.3 | Ubuntu 18.04 (legacy) |
| `1.9.2` | v1.9.2 | Ubuntu 18.04 (legacy) |
| `1.9.1` | v1.9.1 | Ubuntu 18.04 (legacy) |
| `1.9` | v1.9 | Ubuntu 18.04 (legacy) |

## Prerequisites

- A running Ravencoin full node — see [rvn-core-server-docker](https://github.com/dramirezRT/rvn-core-server-docker)
  - `rpcuser` and `rpcpassword` must be configured in `raven.conf`
  - `rest=1` must be set and **not commented out** in `raven.conf` — ElectrumX uses the REST API for block downloads; without it, block syncing will fail with "Not Found" errors
- Docker Engine installed
- The following directory structure on the host:

```
sudo mkdir -p /electrum-data/db /electrum-data/ssl_cert
```

## Usage

Set your ravend RPC credentials before running:

```bash
export DAEMON_URL="http://<rpcuser>:<rpcpassword>@<host>:<port>"
```

```bash
docker run -d \
  -v /electrum-data/:/electrum-data \
  -e DAEMON_URL="$DAEMON_URL" \
  -p 50001:50001 \
  -p 50002:50002 \
  -p 50004:50004 \
  -p 8000:8000 \
  -e SERVICES="tcp://:50001,ssl://:50002,wss://:50004,rpc://0.0.0.0:8000" \
  --name rvn-electrumx-server \
  dramirezrt/ravencoin-electrumx-server
```

> The `rpcuser` and `rpcpassword` must match what is configured in the ravend instance from [rvn-core-server-docker](https://github.com/dramirezRT/rvn-core-server-docker).

### Running a specific version

```bash
docker run -d \
  -v /electrum-data/:/electrum-data \
  -e DAEMON_URL="$DAEMON_URL" \
  -p 50002:50002 \
  -e SERVICES="ssl://:50002" \
  --name rvn-electrumx-server \
  dramirezrt/ravencoin-electrumx-server:v1.12.1
```

## Building from source

You can build any version of the ElectrumX Ravencoin server using the `TAG` build argument:

```bash
docker build --build-arg TAG=v1.12.1 -t ravencoin-electrumx-server:v1.12.1 .
```

To build the latest release:

```bash
docker build -t ravencoin-electrumx-server:latest .
```

## Logging

ElectrumX logs are written to `/electrum-data/electrumx.log` inside the container — which maps to your host mount path (e.g. `/home/raven/electrum-data/electrumx.log` if you mount `/home/raven/electrum-data:/electrum-data`).

Log output is configured via shell redirection in the container entrypoint, not via an environment variable.

To view logs:
- `docker logs rvn-electrumx-server`
- `tail -f /home/raven/electrum-data/electrumx.log`

> [rvn-node-frontend-docker](https://github.com/dramirezRT/rvn-node-frontend-docker) can stream this log file in real-time in the dashboard. Set `ELECTRUMX_LOG_FILE=/electrum-data/electrumx.log` and mount the same host path into that container.

For a full list of environment variables check [https://electrumx-ravencoin.readthedocs.io/en/latest/environment.html](https://electrumx-ravencoin.readthedocs.io/en/latest/environment.html)

## Related Projects

- [rvn-core-server-docker](https://github.com/dramirezRT/rvn-core-server-docker) — Ravencoin full node (required as ravend backend)
- [rvn-node-frontend-docker](https://github.com/dramirezRT/rvn-node-frontend-docker) — Real-time dashboard that can stream ElectrumX logs

### Donations

RVN address: RWypyDyfiyiVmN5weG1x9xrBHtND9RsGzC
