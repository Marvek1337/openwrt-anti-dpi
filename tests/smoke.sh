#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
for script in scripts/*.sh; do
  echo "Checking $script"
  sh -n "$script"
  dash -n "$script"
  if command -v busybox >/dev/null 2>&1; then busybox ash -n "$script"; fi
done
for script in scripts/install.sh scripts/backup.sh scripts/diagnostics.sh scripts/uninstall.sh; do
  echo "Expecting OpenWrt guard: $script"
  if sh "$script" >/dev/null 2>&1; then
    echo "FAIL: $script unexpectedly passed the OS guard on the CI runner" >&2
    exit 1
  fi
done
echo "PASS: syntax and off-target guards"
