# PowerDNS (PDNS) Containers

[![](https://img.shields.io/github/license/muhlba91/pdns-container?style=for-the-badge)](LICENSE)
[![](https://img.shields.io/github/workflow/status/muhlba91/pdns-container/Container?style=for-the-badge)](https://github.com/muhlba91/pdns-container/actions)
[![](https://img.shields.io/github/workflow/status/muhlba91/pdns-container/Helm?style=for-the-badge)](https://github.com/muhlba91/pdns-container/actions)
[![](https://img.shields.io/github/release-date/muhlba91/pdns-container?style=for-the-badge)](https://github.com/muhlba91/pdns-container/releases)
[![](https://quay.io/repository/muhlba91/pdns-auth/status)](https://quay.io/repository/muhlba91/pdns-auth)
[![](https://quay.io/repository/muhlba91/pdns-recursor/status)](https://quay.io/repository/muhlba91/pdns-recursor)
[![](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/pdns)](https://artifacthub.io/packages/search?repo=pdns)
<a href="https://www.buymeacoffee.com/muhlba91" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="28" width="150"></a>

An containerized version of [PowerDNS (PDNS)](http://powerdns.com).

---

## Installation Notes

Create your PDNS configuration files locally and start the container:

```shell
$ docker run --name pdns-auth \
  --network host \
  -v ${PWD}/config:/etc/pdns \
  quay.io/muhlba91/pdns-auth:<TAG>

$ docker run --name pdns-recursor \
  --network host \
  -v ${PWD}/config:/etc/pdns \
  quay.io/muhlba91/pdns-recursor:<TAG>
```

### Container Tags

The container images are tagged according to:

1. the PDNS version (`quay.io/muhlba91/pdns-auth:<PDNS_VERSION>` / `quay.io/muhlba91/pdns-recursor:<PDNS_VERSION>`) - **Note:** this tag will be re-used on every release with the same PDNS version!
2. the PDNS version and current release (`quay.io/muhlba91/pdns-auth:<PDNS_VERSION>-<RELEASE>` / `quay.io/muhlba91/pdns-recursor:<PDNS_VERSION>-<RELEASE>`)
3. the Git Commit SHA (`quay.io/muhlba91/pdns-auth:<GIT_COMMIT_SHA>` / `quay.io/muhlba91/pdns-recursor:<GIT_COMMIT_SHA>`)

### Helm Charts

For your convencience, Helm charts are provided. Please take a look at the [`auth/values.yaml`](charts/auth/values.yaml) and [`recursor/values.yaml`](charts/recursor/values.yaml) files for customization.

You can install the chart with Helm like this:

```bash
helm repo add pdns https://muhlba91.github.io/pdns-container
helm install pdns-auth pdns/auth -f values.auth.yaml
helm install pdns-auth pdns/recursor -f values-recursor.yaml
```

---

## Configuration

### Sockets Directory

The sockets directory of PDNS processes must be `/run/pdns`.

### Logging

You can either direct PDNS processes to log to stdout or use the directory `/var/log/pdns` to store log files.

### Auth

The SQLITE3 database must be located in `/var/lib/pdns` and is `/var/lib/pdns/pdns.sqlite` by default.
Please set `PDNS_CONF_GSQLITE3_DATABASE` if you choose to use a different path.

- Mount your PDNS configuration files in `/etc/pdns` or `/etc/pdns/conf.d` when running the container.
- Use environment variables prefixed with `PDNS_CONF_`. (see [`pdns-prepare-config.sh`](containers/auth/assets/pdns-prepare-config.sh))

### Recursor

- Mount your PDNS configuration files in `/etc/pdns` or `/etc/pdns/conf.d` when running the container.
- Mount `forward_zones.conf` to `/etc/pdns` when running the container.

---

## Contributing

We welcome community contributions to this project.

## Supporting

If you enjoy the application and want to support my efforts, please feel free to buy me a coffe. :)

<a href="https://www.buymeacoffee.com/muhlba91" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="75" width="300"></a>
