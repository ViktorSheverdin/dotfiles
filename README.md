# dotfiles

use GNU Stow to manage dotfiles
`yay -S stow`
or for Mac
`brew install stow`

To create symlinks, clone dotfiles repo under `~/`
By default stow will move everything to its parent folder
run `stwo .` to create symlinks
Run `stow -D .` to remove symlinks
