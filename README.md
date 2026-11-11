# transmission-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [Transmission](https://github.com/transmission/transmission).

## What this is

A four-file TOS Docker application archive (`transmissiondocker.tar.gz`) that installs
Transmission on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `transmissiondocker`)
- `transmissiondocker.lang` — 23-language superset (TOS requires 14)
- `transmissiondocker.svg` — application icon (764 bytes, 3 SVG elements)
- `docker-compose.yml` — one service, image `linuxserver/transmission:4.1.3`

## How it works

| | |
|---|---|
| Container image | `linuxserver/transmission:4.1.3` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8100/` (container port 9091) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/config` → `/Volume1/DockerAppData/transmissiondocker/config`, `/downloads` → `/Volume1/DockerAppData/transmissiondocker/downloads` |
| Logs | `docker logs transmissiondocker` (stdout/stderr) |



## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Entrypoint wrapper**: the upstream image is built to run as root and keeps state in root-owned paths, so the compose file replaces the entrypoint with `src/entrypoint.sh`, which makes the service run as an unprivileged user. See that file for the details.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 9091.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/transmissiondocker/config` | Transmission application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |
| `/Volume1/DockerAppData/transmissiondocker/downloads` | Transmission application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/transmissiondocker.tar.gz + .sha256
scripts/build.sh 4.1.3-2   # packaging iteration bump
scripts/build.sh 4.1.3-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/transmissiondocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v4.1.3-1`**, assets `transmissiondocker.tar.gz` +
   `transmissiondocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `transmissiondocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `4.1.3-1` → automated validation → review.

## License / branding

Transmission is distributed by its upstream authors under **GPL-3.0**. The container image is the official image from Docker Hub (`linuxserver/transmission:4.1.3`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

- The application runs inside a container; data lives in the application data directory (`/Volume1/DockerAppData/transmissiondocker/`) as described above.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
