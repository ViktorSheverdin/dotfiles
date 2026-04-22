---
allowed-tools: Bash(claude plugin:*), Read, Edit, Write
description: Install a Claude Code plugin and track it in dotfiles
---

Install a Claude Code plugin and add it to the desired_plugins.json manifest so it can be reproduced on other machines.

The user will provide a plugin name as an argument (e.g. `/add-plugin caveman`). If no argument is given, ask which plugin to add.

Follow these steps:

1. Read `~/.claude/plugins/desired_plugins.json` to check if the plugin is already tracked.

2. Find which marketplace has the plugin:
   - Run `claude plugin marketplace list` to see registered marketplaces.
   - Search for the plugin in `~/.claude/plugins/marketplaces/*/plugins/<plugin-name>` and `~/.claude/plugins/marketplaces/*/<plugin-name>` directories.
   - If found, note the marketplace name and its git remote (`git -C <marketplace-path> remote get-url origin`) to get the source repo (extract `owner/repo` from the URL).
   - If not found in any marketplace, ask the user for the GitHub repo (e.g. `JuliusBrussee/caveman`).

3. Register the marketplace if needed:
   - Check if the marketplace from step 2 appears in `claude plugin marketplace list`.
   - If not registered, run `claude plugin marketplace add <owner/repo>` to register it. This also updates `known_marketplaces.json` automatically.

4. Install the plugin:
   - Run `claude plugin install <name>@<marketplace>`.
   - If it's already installed, that's fine — continue to step 5.

5. Update `~/.claude/plugins/desired_plugins.json`:
   - If the plugin is already in the file, report that and stop.
   - Otherwise, add an entry with `name`, `marketplace`, and `source` (the GitHub `owner/repo`).
   - Keep the JSON formatted with 2-space indentation.

6. Report what was done: installed (or already installed) and tracked (or already tracked).
