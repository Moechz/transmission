#!/bin/sh
# TOS wrapper: LinuxServer s6 starts as root and su-execs to abc. Run the
# unmodified transmission-daemon directly as uid 1000 and seed a settings file
# that disables the RPC IP/host whitelists (the container is only reachable
# through the published port).
set -u
set -e
mkdir -p /config /downloads
if [ ! -s /config/settings.json ]; then
  cat > /config/settings.json <<'JSON'
{
  "rpc-whitelist-enabled": false,
  "rpc-host-whitelist-enabled": false,
  "rpc-port": 9091,
  "rpc-authentication-required": false,
  "download-dir": "/downloads"
}
JSON
fi
exec /usr/bin/transmission-daemon -g /config -f
