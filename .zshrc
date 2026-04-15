# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# On macOS, clone plugins into oh-my-zsh custom dir:
#   git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# Function to auto-install custom plugins
install_plugin_if_not_exists() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
    if [ ! -d "$plugin_dir" ]; then
        echo "Installing $plugin_name..."
        git clone --depth 1 "$plugin_url" "$plugin_dir"
    fi
}

# List your custom plugins here
install_plugin_if_not_exists "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
install_plugin_if_not_exists "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"

# Standard Oh My Zsh plugins list
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ---- Detect OS and source platform-specific tools ----
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS — resolve Homebrew prefix (Apple Silicon vs Intel)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_PREFIX="/opt/homebrew"
  else
    BREW_PREFIX="/usr/local"
  fi

  eval "$($BREW_PREFIX/bin/brew shellenv)"

  source "$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
  source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
else
  # Linux — original paths
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
  source /usr/share/fzf/completion.zsh
  source /usr/share/fzf/key-bindings.zsh
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# Note: p10k requires a Nerd Font in your terminal (e.g. MesloLGS NF).
# On Mac: install via `brew install --cask font-meslo-lg-nerd-font`
# and set it in your terminal emulator settings.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Preferred editor
export EDITOR='nvim'

export PATH="$HOME/.local/bin:$PATH"

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# ---- Eza (better ls) -----
alias ls="eza --icons=always"

# ---- TheFuck -----
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"

alias p="pnpm"

# ---- fzf ----
eval "$(fzf --zsh)"

# --- fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# Use fd as the default source for fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# fzf-git — fuzzy git workflows (Ctrl+G Ctrl+B/H/F/S etc.)
[[ -f ~/fzf-git.sh/fzf-git.sh ]] && source ~/fzf-git.sh/fzf-git.sh

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ----- Bat (better cat) -----
export BAT_THEME=tokyonight_night
alias cat="bat"

# ---- Yazi ----
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ---- Custom aliases & functions ----

# Interactive ripgrep search with bat preview
alias rgg='rg --color=always --line-number "" | fzf --ansi --delimiter=: --preview "bat --color=always {1} --highlight-line {2}" --preview-window "right:60%:+{2}-5"'

# Fuzzy cd — fcd [root dir, default ~]
fcd() {
  local dir
  dir=$(fd -t d . "${1:-$HOME}" | fzf --preview 'eza --tree --color=always {}')
  [ -n "$dir" ] && cd "$dir"
}
