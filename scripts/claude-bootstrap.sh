#!/bin/bash
# Bootstrap Claude Code plugins from dotfiles
# Reads: ~/.claude/plugins/desired_plugins.json
# Installs any missing plugins and registers their marketplaces as needed.
#
# Usage: ./scripts/claude-bootstrap.sh

set -e

PLUGINS_FILE="$HOME/.claude/plugins/desired_plugins.json"

if [ ! -f "$PLUGINS_FILE" ]; then
    echo "No desired_plugins.json found at $PLUGINS_FILE. Nothing to do."
    exit 0
fi

installed_file="$HOME/.claude/plugins/installed_plugins.json"
plugin_count=$(jq length "$PLUGINS_FILE")
installed=0
skipped=0

for i in $(seq 0 $((plugin_count - 1))); do
    name=$(jq -r ".[$i].name" "$PLUGINS_FILE")
    marketplace=$(jq -r ".[$i].marketplace" "$PLUGINS_FILE")
    source=$(jq -r ".[$i].source" "$PLUGINS_FILE")
    plugin_id="${name}@${marketplace}"

    # Skip if already installed
    if [ -f "$installed_file" ] && jq -e ".plugins[\"$plugin_id\"]" "$installed_file" > /dev/null 2>&1; then
        echo "[skip] $plugin_id already installed"
        skipped=$((skipped + 1))
        continue
    fi

    # Register marketplace if not already registered
    if ! claude plugin marketplace list 2>/dev/null | grep -q "^  ❯ $marketplace$"; then
        echo "[marketplace] registering $marketplace ($source)"
        claude plugin marketplace add "$source" 2>/dev/null || true
    fi

    echo "[install] $plugin_id"
    claude plugin install "$plugin_id"
    installed=$((installed + 1))
done

echo ""
echo "Done. Installed: $installed, already present: $skipped"
