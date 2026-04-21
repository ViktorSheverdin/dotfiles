#!/bin/bash
# Bootstrap Claude Code plugins from known_marketplaces.json
# Run after stowing dotfiles on a new machine

set -e

MARKETPLACES_FILE="$HOME/.claude/plugins/known_marketplaces.json"

if [ ! -f "$MARKETPLACES_FILE" ]; then
    echo "Error: $MARKETPLACES_FILE not found. Run 'stow .' from your dotfiles first."
    exit 1
fi

echo "Updating marketplaces..."
for repo in $(jq -r '.[].source.repo' "$MARKETPLACES_FILE"); do
    echo "  Adding marketplace: $repo"
    claude plugin marketplace add "$repo" 2>/dev/null || true
done

echo "Updating marketplace catalogs..."
claude plugin marketplace update

echo ""
echo "Done. Available plugins:"
claude plugin list
echo ""
echo "Install plugins with: claude plugin install <plugin>@<marketplace>"
