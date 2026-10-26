#!/bin/sh
set -eu
[ -r /etc/openwrt_release ] || { echo "OpenWrt required" >&2; exit 1; }
command -v sysupgrade >/dev/null 2>&1 || { echo "sysupgrade missing" >&2; exit 1; }
dest="${1:-/tmp/openwrt-settings-$(date +%Y%m%d-%H%M%S).tar.gz}"
case "$dest" in /tmp/*) ;; *) echo "Please save the backup to /tmp then copy it off the router" >&2; exit 1;; esac
umask 077
sysupgrade -b "$dest"
echo "Backup saved: $dest"
echo "Copy it off the router immediately: /tmp is erased after reboot."
echo "WARNING: the archive may contain Wi-Fi keys and other secrets. Never commit it to Git."
