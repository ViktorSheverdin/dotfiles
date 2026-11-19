# dotfiles

use GNU Stow to manage dotfiles
`yay -S stow`
or for Mac
`brew install stow`

To create symlinks, clone dotfiles repo under `~/`
By default stow will move everything to its parent folder
run `stwo .` to create symlinks
Run `stow -D .` to remove symlinks

## Memory protection (Arch)

`./scripts/memory-setup.sh` sets up zram swap, kernel VM tuning, emergency SysRq keys and
earlyoom (it kills the worst memory hog *before* the system freezes). Configs live in `etc/`
and get copied into `/etc`. Re-run the script after editing them.

- `memtop` shows RAM per program. `capped [4G] <cmd>` runs a command under a hard RAM limit.
- nvim stops its LSP servers after 15 min unfocused and restarts them on focus (`lua/viktor/core/lsp-idle.lua`).
- If the system freezes anyway: **Alt+PrtSc+F** kills the biggest process. **Alt+PrtSc+R,E,I,S,U,B** reboots safely.
