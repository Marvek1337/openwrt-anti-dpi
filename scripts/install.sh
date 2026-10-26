#!/bin/sh
# Safe wrapper around upstream Zapret2 installer.
set -eu
[ -r /etc/openwrt_release ] || { echo "ERROR: This script requires OpenWrt" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "tar required" >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo "sha256sum required" >&2; exit 1; }
[ "$(id -u)" = 0 ] || { echo "Run as root" >&2; exit 1; }
avail="$(df -Pk /overlay | awk 'NR==2 {print $4}')"
case "$avail" in ''|*[!0-9]*) echo "Cannot measure free flash"; exit 1;; esac
[ "$avail" -ge 4096 ] || { echo "Less than 4 MiB free in /overlay. Aborting; examine storage first." >&2; exit 1; }
echo "This helper will fetch and execute official Zapret2 release scripts."
echo "Check upstream release notes for compatibility and required storage."
echo "Obtain the correct OpenWrt embedded .tar.gz URL from:"
echo "https://github.com/bol-van/zapret2/releases"
printf 'Official release URL: '
IFS= read -r url
case "$url" in
  https://github.com/bol-van/zapret2/releases/download/*/*.tar.gz) ;;
  *) echo "Refusing a URL outside official Zapret2 releases" >&2; exit 1 ;;
esac
printf 'Expected SHA256 (from a trusted release/source): '
IFS= read -r expected
case "$expected" in
  *[!0-9a-fA-F]*|'') echo "Invalid SHA256" >&2; exit 1 ;;
esac
[ "${#expected}" -eq 64 ] || { echo "SHA256 must be 64 hex chars" >&2; exit 1; }
echo "This installs software and may modify firewall/package settings."
printf 'Type INSTALL to continue: '
IFS= read -r confirm
[ "$confirm" = INSTALL ] || { echo "Cancelled"; exit 1; }
tmp="$(mktemp -d /tmp/zapret2.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
if command -v curl >/dev/null 2>&1; then curl -fL --retry 2 -o "$tmp/release.tar.gz" "$url"
elif command -v wget >/dev/null 2>&1; then wget -O "$tmp/release.tar.gz" "$url"
else echo "Install curl or wget first"; exit 1; fi
actual="$(sha256sum "$tmp/release.tar.gz" | awk '{print $1}')"
[ "$actual" = "$expected" ] || { echo "SHA256 mismatch; refusing installation" >&2; exit 1; }
tar -tzf "$tmp/release.tar.gz" | awk '
/^\// || /(^|\/)\.\.($|\/)/ {bad=1}
END {exit bad}
' || { echo "Archive contains unsafe paths"; exit 1; }
mkdir "$tmp/src"
tar -xzf "$tmp/release.tar.gz" -C "$tmp/src"
script="$(find "$tmp/src" -name install_easy.sh -type f | head -n 1)"
[ -n "$script" ] || { echo "Upstream install_easy.sh not found. Check release layout."; exit 1; }
echo "Invoking upstream installer in: $(dirname "$script")"
cd "$(dirname "$script")"
sh ./install_easy.sh
