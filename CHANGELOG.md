# Changelog

All notable user-visible changes to the Transmission TOS application package.

## 4.1.3-1 — 2026-11-12

### Added
- First release. Transmission (`linuxserver/transmission:4.1.3`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8100 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/transmissiondocker/`.
