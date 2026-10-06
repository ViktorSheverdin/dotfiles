#!/usr/bin/env bash
# Clear a stale SSH_CONNECTION from tmux's session environment.
#
# tmux copies SSH_CONNECTION into the session env on attach (update-environment),
# and tmux-resurrect/continuum can restore a server that still carries an old
# value. A stale SSH_CONNECTION makes tools think they're remote — e.g. Neovim
# switches yanks to OSC 52 and local pbcopy stops working.
#
# Run from a client-attached hook. If the SSH_CONNECTION tmux holds does not
# match a live ESTABLISHED socket, unset it. When you really are over SSH the
# socket exists, the value is kept, and OSC 52 keeps working.
set -euo pipefail

conn=$(tmux show-environment SSH_CONNECTION 2>/dev/null | sed -n 's/^SSH_CONNECTION=//p')
[ -n "${conn:-}" ] || exit 0

# SSH_CONNECTION = "<client_ip> <client_port> <server_ip> <server_port>"
read -r client_ip client_port _server_ip server_port <<<"$conn"
[ -n "${server_port:-}" ] || { tmux set-environment -u SSH_CONNECTION; exit 0; }

# No lsof to verify with → leave the value alone (can't prove it's stale).
command -v lsof >/dev/null 2>&1 || exit 0

if lsof -nP -iTCP:"$server_port" -sTCP:ESTABLISHED 2>/dev/null \
    | grep -q "${client_ip}:${client_port}"; then
    exit 0  # live SSH connection — keep SSH_CONNECTION
fi

tmux set-environment -u SSH_CONNECTION
