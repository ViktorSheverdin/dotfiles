# Terminal Power Workflows: yazi, fzf, fd, ripgrep, eza

Your setup already has fzf wired to fd, bat previews, and zoxide. These workflows build on top of that.

---

## YAZI

Yazi is a blazing-fast terminal file manager. Launch it with `y` (your alias keeps the cwd on exit).

---

### 1. Navigate and open files instantly

**What it does:** Browse your filesystem visually and open files without typing paths.

**In yazi:**
| Key | Action |
|-----|--------|
| `h / l` | Go up/down directory |
| `j / k` | Move up/down in list |
| `Enter` | Open file (uses $EDITOR for text files) |
| `q` | Quit and cd into current dir (your `y` alias) |

**Try it:**
1. Type `y` — navigate to `~/dotfiles`, press `Enter` on `.zshrc` to open it in nvim
2. Type `y` — press `l` to enter a folder, `h` to go back up
3. Open `y`, navigate to any image — it previews inline in the terminal

---

### 2. Yazi bulk selection and operations

**What it does:** Select multiple files and act on them at once — copy, move, delete.

| Key | Action |
|-----|--------|
| `Space` | Toggle select current file |
| `v` | Visual select mode (select range) |
| `y` | Yank (copy) selected |
| `d` | Cut selected |
| `p` | Paste |
| `D` | Delete selected |
| `a` | Create new file/dir (end name with `/` for dir) |
| `r` | Rename |

**Try it:**
1. Open `y`, select 3 files with `Space`, press `y`, navigate to another dir, press `p`
2. Select a file, press `r` to rename it in-place
3. Press `a`, type `test/` to create a new directory, then `a` again to create a file inside

---

### 3. Yazi search within current dir

**What it does:** Jump to any file in the current directory instantly.

| Key | Action |
|-----|--------|
| `f` | Find (filter visible files by name) |
| `/` | Search forward in file list |
| `n / N` | Next/prev match |

**Try it:**
1. Open `y` in `~/dotfiles`, press `f`, type `zsh` — watch the list filter live
2. Press `/`, type `lua` — jump through all lua files with `n`
3. Combine: navigate into `.config/nvim`, press `f`, type `plugin` to find plugin files

---

### 4. Yazi tabs and multi-directory work

**What it does:** Work in multiple directories simultaneously without leaving yazi.

| Key | Action |
|-----|--------|
| `t` | New tab |
| `1-9` | Switch to tab N |
| `[` / `]` | Previous/next tab |

**Try it:**
1. Open `y`, press `t` to create a second tab, navigate to a different directory
2. Use `]` and `[` to switch between tabs, copy a file in tab 1, paste in tab 2
3. Open 3 tabs: one for `~/dotfiles`, one for `~/Downloads`, one for a project

---

### 5. Yazi shell commands and previews

**What it does:** Run shell commands on selected files without leaving yazi.

| Key | Action |
|-----|--------|
| `!` | Open shell in current directory |
| `s` | Open a shell with selected files as args |

**Try it:**
1. Navigate to a dir in `y`, press `!` — you get a shell there; type `exit` to return
2. Select a `.zsh` file, press `s`, then type `wc -l` to count lines
3. Navigate to a project, press `!`, run `git status`, then `exit` back to yazi

---

## FZF

fzf is a general-purpose fuzzy finder. You already have it bound to fd and set up with previews.

---

### 6. CTRL+T — fuzzy find any file

**What it does:** Fuzzy search files from your cwd and insert the path into your command.

**Key:** `Ctrl+T`

**Try it:**
1. Type `nvim `, press `Ctrl+T`, fuzzy search for `keymap` — select it, press Enter to open
2. Type `bat `, press `Ctrl+T`, find any config file — preview it with bat right in fzf
3. Type `cp `, press `Ctrl+T` to pick source, add destination, done — no typing paths

---

### 7. ALT+C — fuzzy jump to any directory

**What it does:** Fuzzy find a directory and cd into it. Your config shows a tree preview.

**Key:** `Alt+C`

**Try it:**
1. Press `Alt+C`, type `nvim` — jump straight into `~/.config/nvim`
2. Press `Alt+C`, type `plug` — find your plugins directory
3. From anywhere, press `Alt+C`, type `dotfiles` — instant jump

---

### 8. CTRL+R — fuzzy search shell history

**What it does:** Search your command history with fuzzy matching. Far better than `Ctrl+P`.

**Key:** `Ctrl+R`

**Try it:**
1. Press `Ctrl+R`, type `git push` — find and re-run that exact push command
2. Press `Ctrl+R`, type `docker run` — find complex docker commands you typed before
3. Press `Ctrl+R`, type `fzf` — see all fzf-related commands you've run

---

### 9. fzf tab completion with `**`

**What it does:** Trigger fzf completion for any command by typing `**` then Tab.

**Pattern:** `command path/**<Tab>`

**Try it:**
1. Type `nvim ~/dotfiles/**`, press `Tab` — fuzzy pick any file in dotfiles
2. Type `cd ~/dotfiles/**`, press `Tab` — fuzzy pick a subdirectory
3. Type `cat ~/.config/**`, press `Tab` — browse all config files with bat preview

---

### 10. fzf git workflows (fzf-git.sh — already in your setup)

**What it does:** You have `fzf-git.sh` sourced. These bindings give you fuzzy git superpowers.

| Key | Action |
|-----|--------|
| `Ctrl+G Ctrl+F` | Fuzzy pick changed files |
| `Ctrl+G Ctrl+B` | Fuzzy pick branches |
| `Ctrl+G Ctrl+T` | Fuzzy pick tags |
| `Ctrl+G Ctrl+H` | Fuzzy pick commit hashes |
| `Ctrl+G Ctrl+S` | Fuzzy pick stashes |

**Try it:**
1. In a git repo, press `Ctrl+G Ctrl+B` to fuzzy switch branches — preview shows the diff
2. Press `Ctrl+G Ctrl+H` — pick a commit hash, paste it into `git show <hash>`
3. After editing files, type `git add `, press `Ctrl+G Ctrl+F` to pick exactly which files

---

### 11. fzf as an interactive process killer

**What it does:** Fuzzy find and kill processes without memorizing PIDs.

```zsh
# Add this to your .zshrc
fkill() {
  local pid
  pid=$(ps aux | sed 1d | fzf -m --header='Select process to kill' | awk '{print $2}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}
```

**Try it:**
1. Add `fkill` to `.zshrc`, source it, run `fkill` — fuzzy find and kill any process
2. Start a `sleep 100` in another terminal, run `fkill`, type `sleep`, kill it
3. Run `fkill 15` to send SIGTERM instead of SIGKILL

---

## FD

fd is a fast, user-friendly alternative to `find`. It respects `.gitignore` by default.

---

### 12. fd — find files by name, type, or extension

**What it does:** Find files faster than `find` with a saner syntax.

```zsh
fd <pattern>              # find by name (regex supported)
fd -e lua                 # find by extension
fd -t d                   # find only directories
fd -t f                   # find only files
fd -H                     # include hidden files
fd --no-ignore            # also search .gitignore'd files
```

**Try it:**
1. In `~/dotfiles`, run `fd -e lua` — see all Lua files instantly
2. Run `fd -t d config` — find all directories named "config"
3. Run `fd -H -e zsh` — find all `.zsh` files including hidden ones

---

### 13. fd + xargs — bulk operations on found files

**What it does:** Pipe fd results into commands to act on many files at once.

```zsh
fd -e md | xargs wc -l              # count lines in all markdown files
fd -e lua | xargs grep "require"    # grep inside all lua files
fd -e log -X rm                     # delete all .log files (-X = batch mode)
```

**Try it:**
1. In `~/dotfiles`, run `fd -e lua | xargs wc -l | sort -n` — rank lua files by size
2. Run `fd -e md -X bat` — view all markdown files with bat, one after another
3. Run `fd "test" -t f | xargs rm -i` — interactively delete files matching "test"

---

### 14. fd + fzf — pick from fd results interactively

**What it does:** Use fd to build a custom file list, then filter it with fzf.

```zsh
# Open any lua file from dotfiles in nvim
fd -e lua . ~/dotfiles | fzf --preview 'bat --color=always {}' | xargs nvim

# Jump into any directory under home
fd -t d . ~ | fzf --preview 'eza --tree --color=always {}' | xargs -I{} cd {}
```

**Try it:**
1. Run `fd -e lua . ~/dotfiles | fzf | xargs nvim` — pick and open a lua config
2. Run `fd -t d . ~/dotfiles | fzf --preview 'eza --tree {}'` — browse dirs with tree preview
3. Run `fd -e zsh | fzf | xargs bat` — fuzzy pick a zsh file and preview it

---

## RIPGREP

ripgrep (`rg`) searches file *contents* blazingly fast. It respects `.gitignore`.

---

### 15. rg — search code like a pro

**What it does:** Find any text in any file, instantly, with context.

```zsh
rg "pattern"              # basic search
rg "pattern" -t lua       # search only lua files
rg "pattern" -l           # just filenames, no content
rg "pattern" -C 3         # show 3 lines of context
rg "pattern" -i           # case insensitive
rg "pattern" --no-ignore  # include .gitignore'd files
rg -w "word"              # whole word match only
```

**Try it:**
1. In `~/dotfiles`, run `rg "keymap"` — find every keymap reference across all files
2. Run `rg "require" -t lua -l` — list all lua files that import anything
3. Run `rg "alias" ~/.zshrc -C 2` — find aliases with 2 lines of context

---

### 16. rg + fzf — live interactive code search

**What it does:** Search code interactively with live preview of results.

```zsh
# Interactive code search with preview
rg --color=always --line-number "" | \
  fzf --ansi --delimiter=: \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'right:60%:+{2}-5'
```

**Add this alias to `.zshrc`:**
```zsh
alias rgg='rg --color=always --line-number "" | fzf --ansi --delimiter=: --preview "bat --color=always {1} --highlight-line {2}" --preview-window "right:60%:+{2}-5"'
```

**Try it:**
1. Add `rgg` alias, go to `~/dotfiles`, run `rgg`, type `plugin` — see live matches with preview
2. Run `rgg`, type `bindkey` — jump through all keybinding definitions across files
3. Run `rgg` in a project, type a function name — see every usage with bat-highlighted context

---

### 17. rg — find and replace across files

**What it does:** Use rg to find, then `sed` or other tools to replace. A safe search-replace workflow.

```zsh
# Preview what would change
rg "oldname" -l

# Replace across all matched files
rg "oldname" -l | xargs sed -i 's/oldname/newname/g'

# Safer: review each file first
rg "oldname" -l | fzf | xargs sed -i 's/oldname/newname/g'
```

**Try it:**
1. In a test dir, create 3 files with the word "foo", run `rg "foo" -l | xargs sed -i 's/foo/bar/g'`
2. Run `rg "TODO" -l` in a project — list all files with TODOs
3. Run `rg "console.log" -l | fzf` — interactively pick which files to clean up

---

## EZA

eza is your `ls` replacement. Already aliased. Let's use its power.

---

### 18. eza — directory listings that actually inform you

**What it does:** Get rich, colored, icon-decorated directory info at a glance.

```zsh
eza --icons                        # icons (your default alias)
eza -l --icons                     # long format with icons
eza -la --icons                    # include hidden files
eza --tree --level=2               # tree view, 2 levels deep
eza -l --git --icons               # show git status per file
eza -l --sort=modified --icons     # sort by modification time
eza -l --sort=size --icons         # sort by file size
```

**Try it:**
1. In `~/dotfiles`, run `eza -la --icons` — see all hidden files with permissions
2. Run `eza --tree --level=2 --icons` — get a project overview tree
3. Run `eza -l --git --icons` — see which files are modified, staged, or untracked

---

### 19. Combining everything — the ultimate file-finding workflow

**What it does:** Chain eza + fd + fzf + bat + rg into a smooth multi-step workflow.

**Scenario: You vaguely remember a config but don't know where it is.**

```zsh
# Step 1: search by content
rg "FZF_DEFAULT" ~/dotfiles -l

# Step 2: if you're not sure of content, search by name
fd "zsh" ~/dotfiles | fzf --preview 'bat --color=always {}'

# Step 3: open result in nvim
fd "zsh" ~/dotfiles | fzf --preview 'bat --color=always {}' | xargs nvim

# One-liner: find lua files containing "keymap", pick one, open in nvim
rg "keymap" -l -t lua | fzf --preview 'bat --color=always {}' | xargs nvim
```

**Try it:**
1. Run `rg "FZF" ~/dotfiles -l | fzf | xargs nvim` — find and open the fzf config
2. Run `fd -e lua | fzf --preview 'bat --color=always {}' | xargs nvim` in your nvim config
3. Run `rg "alias" ~/dotfiles -l | fzf --preview 'bat --color=always {}'` — find your aliases

---

### 20. zoxide + yazi + fzf — the daily navigation loop

**What it does:** Combine your smart cd (zoxide), file manager (yazi), and fuzzy finder for a frictionless daily workflow.

```zsh
# Smart jump to any recently visited dir
z dotfiles        # zoxide: jump to ~/dotfiles
z nvim            # jump to ~/.config/nvim

# Then browse from there
y                 # open yazi, navigate, quit back to that dir

# Or: fuzzy pick a past dir
zi                # interactive zoxide — fzf over your frecency list
```

**Full daily loop:**
```
zi → pick a project dir → y → browse files → open in nvim → edit → q back to shell
```

**Try it:**
1. Visit 5 different dirs, then run `zi` — see your frecency list, pick one to jump back
2. Run `z dot`, press Tab — see zoxide autocomplete your jump
3. Start in `~`, run `zi`, pick `dotfiles`, then `y`, open `.zshrc`, quit — you're back in dotfiles

---

## Quick Reference Card

| Tool | Key Workflow | Command |
|------|-------------|---------|
| yazi | Open file manager | `y` |
| yazi | Bulk select | `Space` on files |
| yazi | New tab | `t` |
| fzf | Find file → insert path | `Ctrl+T` |
| fzf | Jump to directory | `Alt+C` |
| fzf | Search history | `Ctrl+R` |
| fzf | Tab completion | `cmd **<Tab>` |
| fzf-git | Fuzzy branches | `Ctrl+G Ctrl+B` |
| fzf-git | Fuzzy commits | `Ctrl+G Ctrl+H` |
| fd | Find by extension | `fd -e lua` |
| fd | Find dirs only | `fd -t d` |
| fd+fzf | Pick and open | `fd -e lua \| fzf \| xargs nvim` |
| rg | Search content | `rg "pattern" -t lua` |
| rg+fzf | Interactive search | `rgg` alias |
| eza | Tree view | `eza --tree --level=2` |
| eza | Git status in ls | `eza -l --git` |
| zoxide | Smart jump | `z <partial-name>` |
| zoxide | Interactive jump | `zi` |

---

## Aliases to add to your `.zshrc`

```zsh
# Interactive ripgrep search with preview
alias rgg='rg --color=always --line-number "" | fzf --ansi --delimiter=: --preview "bat --color=always {1} --highlight-line {2}" --preview-window "right:60%:+{2}-5"'

# Kill processes interactively
fkill() {
  local pid
  pid=$(ps aux | sed 1d | fzf -m --header='Select process to kill' | awk '{print $2}')
  [ -n "$pid" ] && echo "$pid" | xargs kill -${1:-9}
}

# Find file by content and open
fopen() {
  rg "$1" -l | fzf --preview "bat --color=always {}" | xargs -r nvim
}

# Fuzzy cd using fd
fcd() {
  local dir
  dir=$(fd -t d . "${1:-.}" | fzf --preview 'eza --tree --color=always {}')
  [ -n "$dir" ] && cd "$dir"
}
```
