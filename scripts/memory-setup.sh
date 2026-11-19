#!/bin/bash
# Memory protection setup for Arch Linux.
#
# Installs:
#   1. zram swap (compressed swap in RAM)        etc/systemd/zram-generator.conf
#   2. kernel VM tuning + emergency SysRq keys   etc/sysctl.d/99-memory.conf
#   3. zswap disabled (redundant with zram)      etc/tmpfiles.d/zswap-off.conf
#   4. earlyoom (kill hog early, never freeze)   etc/default/earlyoom
#   5. systembus-notify (desktop popup when earlyoom kills something)
#
# Files are COPIED (not symlinked) into /etc: system configs must be root-owned,
# and stow only manages ~. Re-run this script after editing anything in etc/.
#
# Usage:  ./scripts/memory-setup.sh            (safe to re-run)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f /etc/arch-release ]]; then
    echo "This script targets Arch Linux only." >&2
    exit 1
fi

echo "==> Installing packages"
sudo pacman -S --needed --noconfirm zram-generator earlyoom systembus-notify

echo "==> Copying configs into /etc"
sudo install -Dm644 "$DOTFILES/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf
sudo install -Dm644 "$DOTFILES/etc/sysctl.d/99-memory.conf"     /etc/sysctl.d/99-memory.conf
sudo install -Dm644 "$DOTFILES/etc/tmpfiles.d/zswap-off.conf"   /etc/tmpfiles.d/zswap-off.conf
sudo install -Dm644 "$DOTFILES/etc/default/earlyoom"            /etc/default/earlyoom

echo "==> Applying now (no reboot needed)"
sudo sysctl --system >/dev/null
sudo systemd-tmpfiles --create /etc/tmpfiles.d/zswap-off.conf
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service

# Two userspace OOM killers would fight each other.
if systemctl is-enabled --quiet systemd-oomd 2>/dev/null; then
    echo "==> Disabling systemd-oomd (earlyoom replaces it)"
    sudo systemctl disable --now systemd-oomd
fi
sudo systemctl enable earlyoom
sudo systemctl restart earlyoom

echo
echo "==> Result"
swapon --show
echo "zswap enabled: $(cat /sys/module/zswap/parameters/enabled)"
sysctl vm.swappiness vm.page-cluster kernel.sysrq
systemctl --no-pager --lines=0 status earlyoom | head -3
journalctl -u earlyoom -b --no-pager | grep -iE 'prefer|avoid|min' | tail -4
echo
echo "systembus-notify autostarts at next login (popup when earlyoom kills)."
echo "Start it now without re-login:  systembus-notify & disown"
