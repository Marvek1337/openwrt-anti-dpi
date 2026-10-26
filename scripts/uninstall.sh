#!/bin/sh
set -eu
[ -r /etc/openwrt_release ] || { echo "OpenWrt required" >&2; exit 1; }
echo "This does not remove any packages or reset firewall automatically."
echo "Use the uninstall script shipped with your installed Zapret2 version."
echo "Check the install directory (often /opt/zapret) and upstream documentation."
[ -f /opt/zapret/uninstall_easy.sh ] || { echo "No standard upstream uninstaller at /opt/zapret/uninstall_easy.sh"; exit 1; }
printf 'Type UNINSTALL to run the upstream uninstaller: '
IFS= read -r answer
[ "$answer" = UNINSTALL ] || { echo "Cancelled"; exit 1; }
cd /opt/zapret
sh ./uninstall_easy.sh
