#!/bin/sh
# Read-only OpenWrt diagnostics. No credentials or private config are printed.
set -u
[ -r /etc/openwrt_release ] || { echo "ERROR: OpenWrt is required" >&2; exit 1; }
echo "== OpenWrt =="
cat /etc/openwrt_release
echo
echo "== System =="
uname -m
uname -r
echo
echo "== Flash overlay =="
df -h /overlay
echo
echo "== RAM =="
free -m
echo
echo "== Package manager =="
if command -v apk >/dev/null 2>&1; then echo apk; elif command -v opkg >/dev/null 2>&1; then echo opkg; else echo unknown; fi
echo
echo "== Firewall =="
if command -v fw4 >/dev/null 2>&1; then echo "fw4 available"; else echo "fw4 unavailable"; fi
if command -v nft >/dev/null 2>&1; then echo "nft available"; else echo "nft unavailable"; fi
echo
echo "== Connectivity utilities =="
for x in curl wget tar sha256sum; do command -v "$x" >/dev/null 2>&1 && echo "$x: available" || echo "$x: missing"; done
echo
echo "Diagnostics complete. No settings changed."
