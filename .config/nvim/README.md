# Neovim Configuration

Personal Neovim configuration built on **Lazy.nvim** plugin manager with the **Tokyo Night** color scheme.

**Leader key:** `Space`
**Local leader:** `\`

---

## Plugins Overview

### UI & Theme
| Plugin | Purpose |
|--------|---------|
| **tokyonight.nvim** | Tokyo Night color scheme (night variant) |
| **snacks.nvim** | All-in-one QoL: dashboard, explorer, picker, notifications, zen mode, terminal, toggles, and more |
| **lualine.nvim** | Custom status line with mode colors |
| **bufferline.nvim** | Tab-like buffer bar at the top |
| **which-key.nvim** | Keybinding help popup (shows after 500ms) |
| **nvim-web-devicons** | File type icons throughout the UI |

### Navigation & Search
| Plugin | Purpose |
|--------|---------|
| **snacks.nvim (picker)** | Fuzzy finder for files, grep, LSP symbols, git, keymaps, and more (replaces Telescope) |
| **snacks.nvim (explorer)** | File explorer sidebar (replaces nvim-tree) |
| **vim-tmux-navigator** | Seamless `Ctrl+h/j/k/l` navigation between Neovim and tmux panes |
| **trouble.nvim** | Better diagnostics, quickfix, and location list UI |
| **todo-comments.nvim** | Highlights and lets you search TODO/FIXME/HACK comments |

### Code Editing & Completion
| Plugin | Purpose |
|--------|---------|
| **nvim-treesitter** | Syntax highlighting and code understanding via tree-sitter parsers |
| **nvim-autopairs** | Auto-close brackets, quotes, and parentheses |
| **nvim-ts-autotag** | Auto-close and auto-rename HTML/JSX tags |
| **nvim-cmp** | Completion engine with multiple sources (LSP, buffer, path, snippets) |
| **LuaSnip** + **friendly-snippets** | Snippet engine with a large VSCode-style snippet library |
| **lspkind.nvim** | VSCode-like icons in the completion menu |
| **conform.nvim** | Code formatter (prettier, stylua, black, isort) |
| **nvim-surround** | Add, delete, and change surrounding pairs (brackets, quotes, tags) |

### LSP (Language Server Protocol)
| Plugin | Purpose |
|--------|---------|
| **nvim-lspconfig** | LSP client configuration |
| **mason.nvim** | Installs and manages LSP servers and tools |
| **mason-lspconfig.nvim** | Bridges Mason with nvim-lspconfig |
| **mason-tool-installer.nvim** | Auto-installs formatters and linters |
| **nvim-lsp-file-operations** | LSP-aware file rename/delete |
| **lazydev.nvim** | Lua development support with type hints |

**Configured LSP servers:** TypeScript, HTML, CSS, Tailwind CSS, Lua, GraphQL, Prisma, Python (pyright), ESLint

### Git & Productivity
| Plugin | Purpose |
|--------|---------|
| **vim-fugitive** | Git commands via `:Git` (blame, commit, diff) |
| **auto-session** | Auto save/restore editing sessions per directory |

---

## All Keybindings

### Top-Level Quick Access

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader><space>` | Smart find files | Space = quick access | Fast file switching — the most common action |
| `<leader>,` | Open buffers list | Comma = pause and pick | You have several files open and want to switch between them |
| `<leader>/` | Grep across project | Slash = search (like `/` in Vim) | You want to search for a string across all files |
| `<leader>:` | Command history | Colon = command mode | You want to re-run a previous `:` command |
| `<leader>e` | Toggle file explorer | **E**xplorer | You want to browse the project tree |
| `<leader>.` | Toggle scratch buffer | Dot = scratchpad | You need a quick throwaway buffer for notes or calculations |
| `<leader>S` | Select scratch buffer | Capital **S**cratch | You have multiple scratch buffers and want to pick one |
| `<leader>n` | Notification history | **N**otifications | You want to review past notifications |
| `<leader>N` | Neovim news | **N**ews (capital) | You want to read the latest Neovim changelog |

### Core Editing

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>+` | Increment number under cursor | Plus = bigger | You're editing a CSS `z-index: 10` and want to bump it to 11 |
| `<leader>-` | Decrement number under cursor | Minus = smaller | You have `margin: 5px` and want to reduce it to 4 |
| `<leader>bd` | Delete buffer | **B**uffer **D**elete | Close a buffer without messing up your window layout |

### Window Splits

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>wv` | Split window vertically | **W**indow **V**ertical | You want to see two files side by side |
| `<leader>wh` | Split window horizontally | **W**indow **H**orizontal | You want a test file below and source above |
| `<leader>we` | Make all splits equal size | **W**indow **E**qual | Reset splits to even proportions |
| `<leader>wx` | Close current split | **W**indow e**X**it | Done comparing, go back to single pane |

### Tabs

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>to` | Open new tab | **T**ab **O**pen | Separate workspace for a different feature |
| `<leader>tx` | Close current tab | **T**ab e**X**it | Finished a side task, close its tab |
| `<leader>tn` | Go to next tab | **T**ab **N**ext | Switch to the next tab |
| `<leader>tp` | Go to previous tab | **T**ab **P**revious | Switch to the previous tab |
| `<leader>tf` | Open current buffer in new tab | **T**ab **F**ile | Focus on one file fullscreen without losing split layout |

### Find (Snacks Picker)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>ff` | Find files | **F**ind **F**iles | Find a file by name |
| `<leader>fr` | Find recent files | **F**ind **R**ecent | Jump back to a file you edited earlier |
| `<leader>fb` | Find open buffers | **F**ind **B**uffers | Switch between open files |
| `<leader>fc` | Find config files | **F**ind **C**onfig | Quickly edit your Neovim config files |
| `<leader>fg` | Find git files | **F**ind **G**it files | Find files tracked by git (ignores untracked) |
| `<leader>fp` | Find projects | **F**ind **P**rojects | Switch between recent projects |

### Search (In-File)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `/searchterm` + `Enter` | Search forward in file | `/` = search (like in browser) | Find a string below the cursor |
| `?searchterm` + `Enter` | Search backward in file | `?` = search in reverse | Find a string above the cursor |
| `n` | Jump to next match | **N**ext | Cycle through matches forward |
| `N` | Jump to previous match | Shift = reverse direction | Cycle through matches backward |
| `:noh` | Clear search highlight | **No** **H**ighlight | Remove yellow highlights after you're done |
| `*` | Search word under cursor (forward) | Star = highlight this word | Instantly find all occurrences of the current word |
| `#` | Search word under cursor (backward) | Hash = highlight backward | Same but searches upward first |

### Search (Snacks Picker)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>sg` | Grep across project | **S**earch **G**rep | Find all occurrences of a string in the codebase |
| `<leader>sw` | Grep word under cursor / selection | **S**earch **W**ord | Cursor on `handleClick`, instantly see all usages |
| `<leader>sb` | Search buffer lines | **S**earch **B**uffer lines | Fuzzy-find a line in the current file |
| `<leader>sB` | Grep across open buffers | **S**earch open **B**uffers | Search text only in files you have open |
| `<leader>sd` | Search diagnostics (workspace) | **S**earch **D**iagnostics | See all errors/warnings across the project |
| `<leader>sD` | Search diagnostics (buffer) | **S**earch buffer **D**iagnostics | See errors/warnings in just the current file |
| `<leader>sk` | Search keymaps | **S**earch **K**eymaps | Forgot a keybinding? Search by description |
| `<leader>sh` | Search help pages | **S**earch **H**elp | Look up Neovim help documentation |
| `<leader>sH` | Search highlights | **S**earch **H**ighlights (capital) | Inspect highlight groups for theme tweaking |
| `<leader>si` | Search icons | **S**earch **I**cons | Find a Nerd Font icon by name |
| `<leader>sj` | Search jump list | **S**earch **J**umps | Navigate your jump history |
| `<leader>sl` | Search location list | **S**earch **L**ocation list | Browse the location list with fuzzy search |
| `<leader>sm` | Search marks | **S**earch **M**arks | Find a mark you set earlier |
| `<leader>sM` | Search man pages | **S**earch **M**an pages | Look up system documentation |
| `<leader>sp` | Search plugin specs | **S**earch **P**lugin | Inspect your installed Lazy.nvim plugins |
| `<leader>sq` | Search quickfix list | **S**earch **Q**uickfix | Browse the quickfix list |
| `<leader>sR` | Resume last search | **S**earch **R**esume | Re-open the last picker with previous results |
| `<leader>su` | Search undo history | **S**earch **U**ndo | Browse and restore from undo history |
| `<leader>s"` | Search registers | **S**earch registers (`"`) | See what's in your yank/paste registers |
| `<leader>s/` | Search history | **S**earch `/` history | Browse your previous search patterns |
| `<leader>sa` | Search autocmds | **S**earch **A**utocmds | Inspect active autocommands |
| `<leader>sc` | Search command history | **S**earch **C**ommand history | Browse previous `:` commands |
| `<leader>sC` | Search commands | **S**earch **C**ommands (capital) | Fuzzy-find any available command |
| `<leader>ss` | Search LSP symbols | **S**earch **S**ymbols | Find functions, classes, variables in current file |
| `<leader>sS` | Search workspace symbols | **S**earch workspace **S**ymbols | Find symbols across the entire project |

### Git (Snacks Picker + Lazygit)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>gg` | Open Lazygit | **G**it **G**o (full TUI) | Full interactive git UI for staging, committing, rebasing |
| `<leader>gs` | Git status | **G**it **S**tatus | Quick view of changed/staged files |
| `<leader>gb` | Git branches | **G**it **B**ranches | Switch between or search branches |
| `<leader>gl` | Git log | **G**it **L**og | Browse commit history for the entire repo |
| `<leader>gL` | Git log (line) | **G**it **L**og line (capital) | See commit history for the current line |
| `<leader>gf` | Git log (file) | **G**it log **F**ile | See commit history for the current file |
| `<leader>gd` | Git diff (hunks) | **G**it **D**iff | Browse changed hunks across the repo |
| `<leader>gS` | Git stash | **G**it **S**tash (capital) | Browse and apply stashed changes |
| `<leader>gB` | Git browse (open on GitHub) | **G**it **B**rowse (capital) | Open current file/line on GitHub in your browser |
| `<leader>gi` | GitHub issues (open) | **G**it **I**ssues | Browse open issues for the repo |
| `<leader>gI` | GitHub issues (all) | **G**it **I**ssues (capital = all) | Browse all issues including closed |
| `<leader>gp` | GitHub PRs (open) | **G**it **P**ull requests | Browse open pull requests |
| `<leader>gP` | GitHub PRs (all) | **G**it **P**ull requests (capital = all) | Browse all PRs including merged/closed |

### LSP (Language Server)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `gd` | Go to definition | **G**o to **D**efinition | Jump to where a function is defined |
| `gD` | Go to declaration | **G**o to **D**eclaration (capital) | See where a variable or type is declared |
| `gr` | Show all references | **G**o to **R**eferences | Find every place that calls a function |
| `gI` | Show implementations | **G**o to **I**mplementation (capital) | See all classes implementing an interface |
| `gy` | Show type definitions | **G**o to t**Y**pe | See the type/interface a variable uses |
| `gai` | Incoming calls | **G**o **A**nalysis **I**ncoming | See what calls this function |
| `gao` | Outgoing calls | **G**o **A**nalysis **O**utgoing | See what this function calls |
| `K` | Hover documentation | **K** = look up (Vim convention) | Read function signature and docs inline |
| `<leader>ca` | Code actions | **C**ode **A**ction | Auto-fix, auto-import, refactor suggestions |
| `<leader>cR` | Rename file (LSP-aware) | **C**ode **R**ename file | Rename a file and auto-update all imports |
| `<leader>rn` | Rename symbol | **R**e**N**ame | Rename a variable/function across all files |
| `<leader>d` | Line diagnostics (float) | **d**iagnostics | Read the full error message on the current line |
| `[d` | Previous diagnostic | **[** = backward | Jump to the previous error/warning |
| `]d` | Next diagnostic | **]** = forward | Jump to the next error/warning |
| `<leader>rs` | Restart LSP | **R**estart **S**erver | Fix a stuck LSP |

### Completion (Insert Mode)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `Ctrl+j` | Select next completion item | **j** = down | Scroll to the next suggestion |
| `Ctrl+k` | Select previous completion item | **k** = up | Go back to the previous suggestion |
| `Ctrl+b` | Scroll docs up | **B**ack | Scroll up in the documentation popup |
| `Ctrl+f` | Scroll docs down | **F**orward | Scroll down in the documentation popup |
| `Ctrl+Space` | Trigger completion manually | Space = summon | Force the completion menu open |
| `Ctrl+e` | Close completion menu | **E**xit | Dismiss the completion popup |
| `Enter` | Confirm selection | Enter = accept | Insert the highlighted suggestion |

### Formatting

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>mp` | Format file or selection | **M**ake **P**retty | Fix indentation and formatting |

### Surround (nvim-surround)

Three core operators: **y**ou **s**urround (add), **d**elete **s**urround (delete), **c**hange **s**urround (change).

#### Adding Surroundings (`ys` — **Y**ou **S**urround)

| Keys | Example Before | Example After | Mnemonic | Use Case |
|------|---------------|---------------|----------|----------|
| `ysiw)` | `hello` | `(hello)` | **Y**ou **S**urround **I**nner **W**ord with `)` | Wrapping a variable in a function call |
| `ysiw(` | `hello` | `( hello )` | `)` = tight, `(` = spaced | Padded parens for readability |
| `ysiw]` | `hello` | `[hello]` | Closing bracket = no spaces | Making an array index |
| `ysiw[` | `hello` | `[ hello ]` | Opening bracket = with spaces | Spaced brackets for templates |
| `ysiw"` | `hello` | `"hello"` | Surround with double quotes | Turn a bare word into a string |
| `ysiw'` | `hello` | `'hello'` | Surround with single quotes | Wrap a dictionary key |
| `ysiw}` | `hello` | `{hello}` | Closing brace = tight | Wrap in JSX expression |
| `ysiw{` | `hello` | `{ hello }` | Opening brace = spaced | JS object destructure |
| `ys$"` | `make strings` | `"make strings"` | Cursor to end of line | Quote everything to EOL |
| `ysiw<tag>` | `hello` | `<tag>hello</tag>` | Surround with HTML tag | Wrap text in `<span>` |
| `yssb` or `yss)` | `hello world` | `(hello world)` | Whole line with brackets | Wrap entire line in parens |

> **Tip:** Closing bracket `)`/`]`/`}` = tight (no spaces). Opening bracket `(`/`[`/`{` = padded (with spaces).

#### Deleting Surroundings (`ds` — **D**elete **S**urround)

| Keys | Example Before | Example After | Mnemonic | Use Case |
|------|---------------|---------------|----------|----------|
| `ds"` | `"hello"` | `hello` | **D**elete **S**urround `"` | Remove quotes from a string |
| `ds'` | `'hello'` | `hello` | **D**elete **S**urround `'` | Remove single quotes |
| `ds)` | `(hello)` | `hello` | **D**elete **S**urround `)` | Unwrap from a function call |
| `ds]` | `[hello]` | `hello` | **D**elete **S**urround `]` | Remove array brackets |
| `ds}` | `{hello}` | `hello` | **D**elete **S**urround `}` | Remove braces |
| `dst` | `<b>hello</b>` | `hello` | **D**elete **S**urround **T**ag | Strip an HTML tag, keep content |
| `dsf` | `print(hello)` | `hello` | **D**elete **S**urround **F**unction | Remove function call, keep argument |

#### Changing Surroundings (`cs` — **C**hange **S**urround)

| Keys | Example Before | Example After | Mnemonic | Use Case |
|------|---------------|---------------|----------|----------|
| `cs'"` | `'hello'` | `"hello"` | **C**hange `'` to `"` | Switch quote style |
| `cs"'` | `"hello"` | `'hello'` | **C**hange `"` to `'` | Switch to single quotes |
| `cs)]` | `(hello)` | `[hello]` | **C**hange `)` to `]` | Parens to brackets |
| `cs)}` | `(hello)` | `{hello}` | **C**hange `)` to `}` | Parens to braces |
| `cs)>` | `(hello)` | `<hello>` | **C**hange `)` to `>` | Parens to angle brackets |
| `csth1` | `<b>hello</b>` | `<h1>hello</h1>` | **C**hange **T**ag to `h1` | Change HTML tag type |
| `cs"f` | `"hello"` | `func("hello")` | **C**hange `"` to **F**unction | Wrap quoted string in function call |

#### Visual Mode Surround (`S`)

| Keys | Description | Use Case |
|------|-------------|----------|
| `v` + select + `S"` | Surround selection with `"` | Wrap multi-word expression in quotes |
| `v` + select + `S)` | Surround selection with `()` | Wrap expression in parentheses |
| `v` + select + `S<tag>` | Surround selection with HTML tag | Wrap text in `<div>...</div>` |
| `V` + select + `S{` | Surround selected lines with `{ }` | Wrap a code block in braces |

### Trouble (Diagnostics UI)

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>xx` | Toggle all diagnostics | e**X**amine e**X**pand | See all errors across the project in a persistent panel |
| `<leader>xX` | Toggle buffer diagnostics | e**X**amine buffer | See errors in just the current file |
| `<leader>cs` | Toggle symbols | **C**ode **S**ymbols | Browse all symbols in the file via Trouble |
| `<leader>cl` | LSP defs/refs | **C**ode **L**SP | See definitions and references in a side panel |
| `<leader>xL` | Toggle location list | e**X**amine **L**ocation | Browse location list |
| `<leader>xQ` | Toggle quickfix list | e**X**amine **Q**uickfix | Browse quickfix results |

### Toggles

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>us` | Toggle spelling | toggle **S**pelling | Enable spell-check while writing docs/comments |
| `<leader>uw` | Toggle word wrap | toggle **W**rap | Toggle line wrapping for long lines |
| `<leader>ul` | Toggle line numbers | toggle **L**ine numbers | Show/hide line numbers |
| `<leader>uL` | Toggle relative numbers | toggle re**L**ative (capital) | Switch between absolute and relative numbers |
| `<leader>ud` | Toggle diagnostics | toggle **D**iagnostics | Temporarily hide all squiggly error lines |
| `<leader>uc` | Toggle conceal level | toggle **C**onceal | Show/hide concealed characters (e.g., in markdown) |
| `<leader>uT` | Toggle treesitter | toggle **T**reesitter | Disable syntax highlighting for troubleshooting |
| `<leader>ub` | Toggle dark/light background | toggle **B**ackground | Switch between dark and light mode |
| `<leader>uh` | Toggle inlay hints | toggle **H**ints | Show/hide LSP inlay type hints |
| `<leader>ug` | Toggle indent guides | toggle indent **G**uides | Show/hide indentation guide lines |
| `<leader>uD` | Toggle dim mode | toggle **D**im (capital) | Dim inactive code scopes to focus on current function |
| `<leader>uC` | Colorscheme picker | toggle **C**olorscheme | Try different color schemes |
| `<leader>un` | Dismiss all notifications | **U**ndo **N**otifications | Clear notification popups |

### Zen & Focus

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>z` | Toggle Zen mode | **Z**en | Distraction-free coding — hides UI chrome |
| `<leader>Z` | Toggle Zoom | **Z**oom (capital) | Maximize current window temporarily |

### Terminal & Navigation

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `Ctrl+/` | Toggle terminal | Slash = terminal prompt | Quick terminal access without leaving Neovim |
| `]]` | Next word reference | Forward jump | Jump to next occurrence of the word under cursor |
| `[[` | Previous word reference | Backward jump | Jump to previous occurrence of the word under cursor |
| `Ctrl+h` | Move to left pane (Neovim or tmux) | **h** = left | Navigate between splits and tmux panes |
| `Ctrl+j` | Move to pane below | **j** = down | Navigate between splits and tmux panes |
| `Ctrl+k` | Move to pane above | **k** = up | Navigate between splits and tmux panes |
| `Ctrl+l` | Move to right pane | **l** = right | Navigate between splits and tmux panes |

### Sessions

| Keys | Description | Mnemonic | Use Case |
|------|-------------|----------|----------|
| `<leader>ws` | Save current session | **W**orkspace **S**ave (note: `w` now = workspace, not window) | Save all open files, splits, and tabs |
| `<leader>wr` | Restore last session | **W**orkspace **R**estore | Pick up exactly where you left off |

---

## Mnemonic Cheat Sheet

The keybindings follow a consistent **`<leader>` + prefix + action** pattern:

| Prefix | Domain | Think of it as... |
|--------|--------|-------------------|
| `w` | **W**indow splits | "I want to manage **W**indows" |
| `t` | **T**abs | "I want to manage **T**abs" |
| `e` | **E**xplorer | "Open the file **E**xplorer" |
| `f` | **F**ind | "I want to **F**ind a file" |
| `s` | **S**earch | "I want to **S**earch for something" |
| `g` | **G**it | "I want **G**it stuff" |
| `x` | e**X**amine | "I want to e**X**amine diagnostics (Trouble)" |
| `c` | **C**ode | "I want a **C**ode action" |
| `r` | **R**ename / **R**estart | "I want to **R**ename or **R**estart" |
| `u` | **U**I toggles | "I want to toggle a **U**I option" |
| `b` | **B**uffer | "I want to manage **B**uffers" |
| `m` | **M**ake | "**M**ake it pretty (format)" |
| `z` | **Z**en | "I want **Z**en / focus mode" |

**Surround operators (no leader key):**

| Operator | Meaning | Remember as... |
|----------|---------|----------------|
| `ys` | Add surround | "**Y**ou **S**urround" — adding something around text |
| `ds` | Delete surround | "**D**elete **S**urround" — removing the wrapper |
| `cs` | Change surround | "**C**hange **S**urround" — swapping one wrapper for another |
| `S` (visual) | Surround selection | Capital **S** = **S**urround what I selected |

> **Bracket rule:** Closing `)` `]` `}` = tight, opening `(` `[` `{` = with spaces. Think: "closing is closer (tight), opening makes room (spaced)."

**LSP navigation (no leader key):**

| Prefix | Meaning | Examples |
|--------|---------|---------|
| `g` + lowercase | Go to primary target | `gd` = definition, `gr` = references |
| `g` + uppercase | Go to secondary target | `gD` = declaration, `gI` = implementation |
| `gy` | Go to t**y**pe | Type definition of symbol under cursor |
| `ga` + `i`/`o` | Go **a**nalyze calls | `gai` = incoming calls, `gao` = outgoing calls |

---

## Common Workflows

### Workflow 1: "I just opened a project and need to find my way around"

1. `<leader>e` - Open the file explorer to see the project structure
2. `<leader>ff` - Fuzzy find a file by name if you know what you're looking for
3. `<leader>/` - Grep across all files for a string
4. `<leader>wr` - Restore your previous session if you worked on this project before

### Workflow 2: "I'm reading unfamiliar code and need to understand it"

1. `gd` - Jump to a function's definition to see what it does
2. `K` - Hover over a symbol to read its documentation and signature
3. `gr` - See everywhere this function is called to understand usage patterns
4. `gI` - Check what classes implement an interface
5. `gy` - Look up what type a variable is
6. `gai` - See what calls this function (incoming calls)

### Workflow 3: "I'm writing new code"

1. `<leader>wv` - Split vertically to have a reference file open beside your new code
2. Start typing and use `Ctrl+Space` to trigger completion if it doesn't appear
3. `Ctrl+j`/`Ctrl+k` - Navigate completion suggestions
4. `Enter` - Accept the right suggestion
5. `Ctrl+f`/`Ctrl+b` - Scroll through documentation in the completion popup
6. `<leader>mp` - Format your code when you're done writing

### Workflow 4: "I need to fix bugs and errors"

1. `<leader>sd` - Search workspace diagnostics to see all errors across the project
2. `]d` - Jump to the next diagnostic in the current file
3. `<leader>d` - Read the full error message on the current line
4. `<leader>ca` - Open code actions to see if there's an auto-fix available
5. `gd` - Go to the definition of the problematic function
6. `<leader>rn` - Rename a symbol if the fix involves renaming
7. `<leader>mp` - Format after fixing

### Workflow 5: "I'm committing my changes"

1. `<leader>gs` - Open Git status to see changed files
2. `<leader>gg` - Open Lazygit for full staging, committing, and pushing
3. `<leader>gl` - Browse git log to review recent commits
4. `<leader>gd` - Review diff hunks before committing

### Workflow 6: "I want to compare or work on two things at once"

1. `<leader>wv` - Split vertically for side-by-side files
2. `<leader>wh` - Split horizontally for top/bottom layout
3. `Ctrl+h/j/k/l` - Move between splits (works across tmux panes too)
4. `<leader>we` - Equalize split sizes if they get uneven
5. `<leader>tf` - Pop the current file into its own tab for focused work
6. `<leader>tn`/`<leader>tp` - Switch between tabs
7. `<leader>wx` - Close a split when done comparing

### Workflow 7: "I made a mess and need to undo carefully"

1. `<leader>su` - Open undo history to browse and search past states
2. Select the state you want to restore
3. Confirm to jump back to that point

### Workflow 8: "I need to refactor surroundings (quotes, brackets, tags)"

1. `cs'"` - Change single quotes to double quotes
2. `dst` - Strip an unnecessary HTML wrapper tag but keep its content
3. `ysiw)` - Wrap a variable name in parentheses for a function call
4. `dsf` - Remove a function wrapper like `String(value)` to just `value`
5. Visually select a block with `V`, then `S{` to wrap it in braces
6. `csth1` - Change a `<div>` to an `<h1>` tag
7. `ysiw"` - Wrap a bare word in quotes to turn it into a string literal

### Workflow 9: "I need to focus and minimize distractions"

1. `<leader>z` - Enter Zen mode for distraction-free coding
2. `<leader>Z` - Zoom the current window to full screen
3. `<leader>uD` - Dim inactive code to focus on the current function
4. `<leader>ud` - Temporarily disable diagnostics if they're noisy
5. `<leader>z` - Exit Zen mode when done

### Workflow 10: "End of day wrap-up"

1. `<leader>sd` - Check that no diagnostics are left unresolved
2. `<leader>gs` - Review git status
3. `<leader>gg` - Open Lazygit to stage and commit remaining changes
4. `<leader>ws` - Save your session so you can restore it tomorrow

---

## Vim Motions & Editing Cheat Sheet

### Scrolling & Navigation

| Action | Command | Mnemonic |
|---|---|---|
| Half page down | `Ctrl+d` | **D**own |
| Half page up | `Ctrl+u` | **U**p |
| Full page down | `Ctrl+f` | **F**orward |
| Full page up | `Ctrl+b` | **B**ackward |
| Scroll down (keep cursor) | `Ctrl+e` | **E**xpose next line below |
| Scroll up (keep cursor) | `Ctrl+y` | **Y** is above U on keyboard — "up" |
| Go to top of file | `gg` | **G**o **G**o — double tap = go to start |
| Go to bottom of file | `G` | **G**o to the end (single = bottom) |
| Go to line 42 | `42G` or `:42` | **G**o to line number |
| Center current line on screen | `zz` | **z** = reposition screen; **z** again = center (middle of the alphabet ≈ middle of screen) |
| Current line to top of screen | `zt` | **z** reposition + **t**op |
| Current line to bottom of screen | `zb` | **z** reposition + **b**ottom |

### Registers (the key to copy/paste in Vim)

Vim has multiple "registers" (clipboards). By default, when you delete or yank text, it goes into the unnamed register `"`. This is why deleting something overwrites what you previously copied.

**The fix: use named registers.** Prefix any yank/delete/paste with `"x` where `x` is any letter a-z.

| Scenario | Command | What it does |
|---|---|---|
| Copy a line and keep it safe | `"ayy` | Yank current line into register `a` |
| Paste from that register | `"ap` | Paste contents of register `a` |
| Delete without overwriting your clipboard | `"_dd` | Delete line into the **black hole register** (thrown away) |
| Delete a word without overwriting clipboard | `"_dw` | Same idea — delete word, clipboard untouched |

**Tip:** `"_` (black hole register) is your best friend. Use it whenever you want to delete something without losing what you copied.

### Copying (Yanking)

| Scenario | Command | What it does |
|---|---|---|
| Copy current line | `yy` | Yank entire line |
| Copy 3 lines | `3yy` | Yank current line + 2 below |
| Copy a word | `yw` | Yank from cursor to end of word |
| Copy to end of line | `y$` or `Y` | Yank from cursor to end of line |
| Copy inside quotes | `yi"` | Yank text inside `"..."` |
| Copy inside parentheses | `yi(` | Yank text inside `(...)` |
| Copy inside tags | `yit` | Yank text inside HTML/JSX tags |
| Copy inside curly braces | `yi{` | Yank text inside `{...}` |

### Pasting

| Scenario | Command | What it does |
|---|---|---|
| Paste after cursor | `p` | Paste after cursor (or below for lines) |
| Paste before cursor | `P` | Paste before cursor (or above for lines) |
| Paste and indent correctly | `]p` | Paste with auto-indent matching |

### Replace Text with Pasted Content

This is the "paste over" workflow — you have something copied and want to replace other text with it.

**Method 1: Visual mode select + paste**
1. Yank what you need: `yy` or `yiw` (copy line or word)
2. Move to the text you want to replace
3. Select it visually: `V` (line), `viw` (word), `vi"` (inside quotes), etc.
4. Paste over it: `p`

**Problem:** after step 4, the replaced (deleted) text is now in your register, so you can't repeat.

**Method 2: Visual mode + black hole delete + paste (repeatable)**
1. Yank what you need: `"ayy` (into register `a`)
2. Move to target text
3. Select it visually
4. Paste from register: `"ap`

**Method 3: Using `P` in visual mode**
1. Yank what you need: `yiw`
2. Select the word to replace: `viw`
3. `P` — pastes over selection (in some configs this preserves the original yank)

**Scenario: Replace an entire line**
- You have `"replace"` copied. You want to replace `"need to replace entire line"`.
  1. `"ayy` — yank the line with "replace" into register `a`
  2. Go to the target line
  3. `V` — select the entire line
  4. `"ap` — paste register `a` over it

### Deleting

| Scenario | Command | What it does |
|---|---|---|
| Delete current line | `dd` | Delete entire line |
| Delete 3 lines | `3dd` | Delete current + 2 below |
| Delete word | `dw` | Delete from cursor to start of next word |
| Delete word (cleaner) | `diw` | Delete entire word cursor is on |
| Delete 3 words | `d3w` or `3dw` | Delete next 3 words |
| Delete inside double quotes | `di"` | Delete text inside `"..."` |
| Delete inside single quotes | `di'` | Delete text inside `'...'` |
| Delete inside parentheses | `di(` or `dib` | Delete text inside `(...)` |
| Delete inside curly braces | `di{` or `diB` | Delete text inside `{...}` |
| Delete inside square brackets | `di[` | Delete text inside `[...]` |
| Delete inside HTML/JSX tags | `dit` | Delete text inside `<tag>...</tag>` |
| Delete including quotes | `da"` | Delete text AND the quotes themselves |
| Delete including tags | `dat` | Delete text AND the surrounding tags |
| Delete including parentheses | `da(` | Delete text AND the parens |
| Delete to end of line | `D` or `d$` | Delete from cursor to end of line |
| Delete character under cursor | `x` | Delete single char |
| Delete character before cursor | `X` | Backspace equivalent |

### Visual Mode

Visual mode lets you select text, then operate on it.

**Entering visual mode:**

| Command | What it does |
|---|---|
| `v` | Character-wise visual mode (select characters) |
| `V` | Line-wise visual mode (select whole lines) |
| `Ctrl+v` | Block (column) visual mode (select a rectangle) |

**Selecting chunks of text:**

| Scenario | Command sequence | What it does |
|---|---|---|
| Select current word | `viw` | Visual-select inner word |
| Select current word + surrounding space | `vaw` | Visual-select "a word" (includes space) |
| Select inside quotes | `vi"` | Select text inside `"..."` |
| Select inside parens | `vi(` | Select text inside `(...)` |
| Select inside tags | `vit` | Select text inside HTML/JSX tags |
| Select inside braces | `vi{` | Select text inside `{...}` |
| Select a paragraph | `vip` | Select inner paragraph (block of text) |
| Select 5 lines down | `V4j` | Line-visual, then move down 4 lines |
| Select to end of line | `v$` | From cursor to end of line |
| Select entire file | `ggVG` | Go to top, line-visual, go to bottom |

**After selecting, you can:**

| Key | Action |
|---|---|
| `y` | Yank (copy) the selection |
| `d` | Delete the selection |
| `c` | Change (delete + enter insert mode) |
| `p` | Paste over the selection |
| `>` / `<` | Indent / un-indent |
| `~` | Toggle case |
| `u` / `U` | Lowercase / uppercase |
| `:` | Enter command mode for the selection |

### Copy/Paste Chunks of Code

**Copy a function/block:**
1. Place cursor on the opening `{`
2. `V%` — line-visual select from `{` to matching `}`
3. `y` — yank it

**Copy 20 lines starting from current line:**
1. `V19j` — visual-line select 20 lines
2. `y` — yank

**Move a block of code:**
1. Select with `V` + motion
2. `d` — cut it
3. Move to destination
4. `p` — paste

**Duplicate a line:**
- `yyp` — yank line, paste below

**Duplicate a block:**
1. `V` + select lines
2. `y`
3. `p` — paste below selection

### Motions Quick Reference

| I want to... | Do this |
|---|---|
| Copy a line and paste it elsewhere | `yy` → move → `p` |
| Delete without losing my clipboard | `"_dd` (black hole register) |
| Replace a word with copied text | `yiw` → move → `viw` → `p` |
| Replace an entire line with copied text | `"ayy` → move → `V"ap` |
| Delete everything inside quotes | `di"` |
| Change text inside tags | `cit` (deletes + enters insert mode) |
| Copy inside braces and paste elsewhere | `yi{` → move → `p` |
| Select and copy a block | `V` → select lines → `y` |
| Swap two words | `yiw` → move to other word → `viwp` → move back → `viwp` |

---

## LazyGit

LazyGit is a terminal UI for git that runs inside Neovim via `<leader>gg`. It has several panes you navigate between with `Tab` or number keys.

### Panes Overview

| Key | Pane | What it shows |
|---|---|---|
| `1` | Status | Repo info, upstream |
| `2` | Files | Changed/staged files (this is where you start) |
| `3` | Branches | Local and remote branches |
| `4` | Commits | Commit log for current branch |
| `5` | Stash | Stashed changes |

### Navigating from the Files Pane

**Opening a file from the changed files pane:**

| Key | What it does |
|---|---|
| `e` | **Edit file** — opens the file in your editor (Neovim) and closes LazyGit |
| `o` | **Open file** — opens the file in your system default app |
| `Enter` | Expand the file to show individual diff hunks (does NOT open the file) |

So to go from the files pane to the actual file: press `e` on the highlighted file. LazyGit will close and Neovim will open that file.

### Staging & Committing

| Key | What it does |
|---|---|
| `Space` | Stage/unstage the highlighted file |
| `a` | Stage/unstage ALL files |
| `Enter` | Expand file to see hunks, then `Space` to stage individual hunks |
| `c` | Open commit message editor (type message, then `Enter` to confirm) |
| `A` | Amend the last commit |
| `S` | Squash — select commits then squash them |

### Git Blame & History

**Blame for the current file:**

| Key / Action | What it does |
|---|---|
| In Neovim: `:Git blame` | Opens fugitive's blame view — shows who last changed every line, the commit hash, and date |
| In blame view: `Enter` on a line | Opens the commit that last changed that line |
| In blame view: `o` on a line | Opens the commit in a split |
| In Neovim: `<leader>gL` | Git log for the current line — see all commits that touched this specific line |
| In Neovim: `<leader>gf` | Git log for the current file — see all commits that touched this file |

**Inside LazyGit — viewing blame and history:**

| Key / Action | What it does |
|---|---|
| Go to Commits pane (`4`) | See full commit log for the branch |
| `Enter` on a commit | Show the full diff of that commit |
| `/` in commits pane | Search commits by message |
| In Files pane: `Enter` on a file | See the diff; then navigate commits pane to see older versions |

### Drilling Back Through File History (Previous Versions)

**Method 1: From Neovim (recommended for single-file history)**
1. `<leader>gf` — opens the file's commit log via Snacks picker
2. Select a commit to see the diff at that point
3. You can keep scrolling back through older commits

**Method 2: From LazyGit**
1. `<leader>gg` to open LazyGit
2. Press `4` to go to the Commits pane
3. Navigate to the commit you're interested in with `j`/`k`
4. Press `Enter` to see what files changed in that commit and the diffs
5. To see the file at that exact point in time, highlight the file and press `o` or `e`

**Method 3: Using fugitive for full blame drill-down**
1. `:Git blame` — see blame annotations for every line
2. Press `Enter` on any line to open the commit that last changed it
3. In that commit view, you can run `:Git blame` again to see the state *before* that commit
4. Repeat to keep drilling back through time — each `Enter` takes you one layer deeper

**Method 4: Line-level history**
1. `<leader>gL` — shows all commits that touched the current line
2. Select any commit to see the diff

### Browsing PRs and Issues

| Key | What it does |
|---|---|
| `<leader>gp` | Browse open PRs for the repo (via Snacks GitHub picker) |
| `<leader>gP` | Browse ALL PRs (including merged/closed) |
| `<leader>gi` | Browse open issues |
| `<leader>gI` | Browse all issues (including closed) |
| `<leader>gB` | Open current file/line on GitHub in browser (great for sharing links) |

### LazyGit Common Workflows

**"I want to see who wrote this code and why"**
1. `:Git blame` → find the line → `Enter` → read the commit message and diff

**"I want to see what this file looked like 5 commits ago"**
1. `<leader>gf` → scroll back 5 commits → select to see the diff

**"I want to find which PR introduced a change"**
1. `:Git blame` on the line → note the commit hash
2. `<leader>gP` → search for that commit hash or related keywords in PR titles

**"I want to see all recent changes to a file"**
1. `<leader>gf` — gives you the complete commit history for that file with diffs
