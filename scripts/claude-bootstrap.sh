#!/bin/bash
# Bootstrap Claude Code plugins from dotfiles config
# Run after stowing dotfiles on a new machine
#
# Reads:
#   ~/.claude/plugins/known_marketplaces.json  - marketplace repos to register
#   ~/.claude/plugins/desired_plugins.json     - plugins to install
#
# Usage: ./scripts/claude-bootstrap.sh

set -e

MARKETPLACES_FILE="$HOME/.claude/plugins/known_marketplaces.json"
PLUGINS_FILE="$HOME/.claude/plugins/desired_plugins.json"

# --- Marketplaces ---

if [ ! -f "$MARKETPLACES_FILE" ]; then
    echo "Error: $MARKETPLACES_FILE not found. Run 'stow .' from your dotfiles first."
    exit 1
fi

echo "==> Registering marketplaces..."
for repo in $(jq -r '.[].source.repo' "$MARKETPLACES_FILE"); do
    echo "  Adding marketplace: $repo"
    claude plugin marketplace add "$repo" 2>/dev/null || true
done

echo "==> Updating marketplace catalogs..."
claude plugin marketplace update

# --- Plugins ---

if [ ! -f "$PLUGINS_FILE" ]; then
    echo "No desired_plugins.json found, skipping plugin installation."
    exit 0
fi

echo ""
echo "==> Checking desired plugins..."

plugin_count=$(jq length "$PLUGINS_FILE")
installed=0
skipped=0

for i in $(seq 0 $((plugin_count - 1))); do
    name=$(jq -r ".[$i].name" "$PLUGINS_FILE")
    marketplace=$(jq -r ".[$i].marketplace" "$PLUGINS_FILE")
    source=$(jq -r ".[$i].source" "$PLUGINS_FILE")
    plugin_id="${name}@${marketplace}"

    # Register the marketplace if it's not already one of the known ones
    if ! jq -e ".[\"$marketplace\"]" "$MARKETPLACES_FILE" > /dev/null 2>&1; then
        echo "  Registering marketplace for $plugin_id: $source"
        claude plugin marketplace add "$source" 2>/dev/null || true
        claude plugin marketplace update 2>/dev/null || true
    fi

    # Check if already installed
    installed_file="$HOME/.claude/plugins/installed_plugins.json"
    if [ -f "$installed_file" ] && jq -e ".plugins[\"$plugin_id\"]" "$installed_file" > /dev/null 2>&1; then
        echo "  [skip] $plugin_id already installed"
        skipped=$((skipped + 1))
    else
        echo "  [install] $plugin_id"
        claude plugin install "$plugin_id"
        installed=$((installed + 1))
    fi
done

echo ""
echo "Done. Installed: $installed, Already present: $skipped"
