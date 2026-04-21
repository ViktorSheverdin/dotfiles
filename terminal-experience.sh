#!/bin/bash

# Detect OS
if [[ "$(uname)" == "Darwin" ]]; then
    OS="mac"
    FONT_DIR="$HOME/Library/Fonts"
else
    OS="linux"
    FONT_DIR="$HOME/.local/share/fonts"
fi

mkdir -p "$FONT_DIR"

# Install packages
if [[ "$OS" == "mac" ]]; then
    brew install wezterm eza zoxide thefuck ripgrep fzf fd \
        bat tldr yazi ffmpegthumbnailer ffmpeg sevenzip jq poppler \
        imagemagick zsh-autosuggestions zsh-syntax-highlighting \
        node git neovim tree-sitter-cli \
        gcc make yarn python tmux stow
else
    yay -S --noconfirm eza zoxide thefuck ripgrep fzf fd \
        bat tldr yazi ffmpegthumbnailer ffmpeg p7zip jq poppler \
        imagemagick zsh-autosuggestions zsh-syntax-highlighting \
        nodejs git neovim tree-sitter \
        gcc make yarn python tmux stow wezterm
fi

# Clone fzf-git for better git support
git clone https://github.com/junegunn/fzf-git.sh.git ~/fzf-git.sh

# Install theme for bat
mkdir -p "$(bat --config-dir)/themes"
curl --create-dirs --output-dir "$(bat --config-dir)/themes" -OJL \
    https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build

# Install Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed, skipping..."
else
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install powerlevel10k
if [[ "$OS" == "mac" ]]; then
    brew install powerlevel10k
else
    yay -S --noconfirm zsh-theme-powerlevel10k
fi

# Install MesloLGS Nerd Font from the official Nerd Fonts release
# This matches what brew installs: MesloLGSNerdFont-*.ttf, family "MesloLGS Nerd Font"
NERD_FONTS_TAG=$(curl -fsSL "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": "\(.*\)".*/\1/')
TMP_ZIP=$(mktemp /tmp/MesloNF.XXXXXX.zip)
curl -L -o "$TMP_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_TAG}/Meslo.zip"
mkdir -p "$FONT_DIR"
unzip -o "$TMP_ZIP" "MesloLGSNerdFont-*.ttf" -d "$FONT_DIR"
rm "$TMP_ZIP"

# Refresh font cache on Linux
if [[ "$OS" == "linux" ]]; then
    fc-cache -fv
fi

# Get dotfiles
git clone git@github.com:ViktorSheverdin/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .

# Symlink plugins into Oh My Zsh custom dir
ZSH_CUSTOM="${ZSH:-$HOME/.oh-my-zsh}/custom"
if [[ "$OS" == "mac" ]]; then
    ln -sf "$(brew --prefix)/share/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    ln -sf "$(brew --prefix)/share/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    ln -sf /usr/share/zsh/plugins/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    ln -sf /usr/share/zsh/plugins/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source ~/.tmux.conf
