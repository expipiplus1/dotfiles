export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

unset RPROMPT

# Path to your oh-my-zsh installation.
export ZSH=$HOME/dotfiles/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="spaceship"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$HOME/dotfiles/zsh-custom

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git vi-mode tmux cabal virsh nix history-substring-search)
fpath+=$HOME/.nix-profile/share/zsh/site-functions

#
# Load oh my zsh
#

source $ZSH/oh-my-zsh.sh

# User configuration

if [[ "$IN_NIX_SHELL" == "" ]]; then
  if [ -e "/etc/nix/nix-profile.sh" ]; then
    . /etc/nix/nix-profile.sh
  fi
fi

export NIX_PATH=nixpkgs=$HOME/src/nixpkgs:$NIX_PATH

# Allow remote builds
export NIX_BUILD_HOOK=$HOME/.nix-profile/libexec/nix/build-remote.pl
export NIX_CURRENT_LOAD=/tmp/current-load

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/devenv/bin" ] ; then
    PATH="$PATH:$HOME/devenv/bin"
fi
if [ -d "$HOME/.nix-profile/bin" ] ; then
    PATH="$HOME/.nix-profile/bin:$PATH"
fi

export MANPATH="$HOME/.nix-profile/share/man:$MANPATH"

# export MANPATH="/usr/local/man:$MANPATH"

# 0.1s
export KEYTIMEOUT=1

# Base16 Shell
# BASE16_SHELL="$HOME/.config/base16-shell/base16-tomorrow.dark.sh"
# [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

function light()
{
  touch ~/.config/light
  source ~/.config/base16-shell/base16-solarized.light.sh
  tmux set-window-option -g window-active-style bg=colour15
  tmux set-window-option -g window-style bg=colour21
  gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#EEE8D5"
  gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#586E75"
}

function dark()
{
  if [ -f ~/.config/light ]; then
    rm ~/.config/light
  fi
  source ~/.config/base16-shell/base16-tomorrow.dark.sh
  tmux set-window-option -g window-active-style 'bg=black'
  tmux set-window-option -g window-style bg=colour18
  gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#282A2E"
  gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#C5C8C6"
}

if [ -f ~/.config/light ]; then
  light
else
  dark
fi

alias gs='git status'
alias gd='git diff'
alias cb='cabal build -j8'
alias cane='git commit --amend --no-edit'
alias nb='nix-build -j8'

if type xdg-open > /dev/null; then
open(){
  xdg-open "$@" 2> /dev/null
}
fi

md2pdf(){
  nix-shell -j8 -p pandocEnv --command "pandoc -t latex --latex-engine=xelatex -o $1.pdf $1"
}

printer(){
  lp -o sides=two-sided-long-edge "$@"
}

ns(){
  nix-shell --command "IN_NIX_SHELL=1 exec zsh; return" "$@"
}

c2n(){
  cp -v -n "$HOME/dotfiles/nix-haskell-skeleton/default.nix" "$HOME/dotfiles/nix-haskell-skeleton/shell.nix" .
}

sr(){
  ag -0 -l $1 | xargs -0 perl -pi -e "s/$1/$2/g"
}

autoload bashcompinit
bashcompinit

alias git=hub

unsetopt AUTO_CD

unsetopt share_history
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=10000000
HISTFILESIZE=20000000

bindkey "^R" history-incremental-search-backward

bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}"  end-of-line
bindkey "${terminfo[kich1]}" overwrite-mode
bindkey "${terminfo[kdch1]}" delete-char
bindkey "${terminfo[kcuu1]}" up-line-or-history
bindkey "${terminfo[kcud1]}" down-line-or-history
bindkey "${terminfo[kcub1]}" backward-char
bindkey "${terminfo[kcuf1]}" forward-char

# Remove the completion for ns, we use that name as a function
compdef -d ns

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR=vim
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#
# Keys for substring search
#

# OPTION 1: for most systems
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# OPTION 2: for iTerm2 running on Apple MacBook laptops
zmodload zsh/terminfo
bindkey "$terminfo[cuu1]" history-substring-search-up
bindkey "$terminfo[cud1]" history-substring-search-down

# OPTION 3: for Ubuntu 12.04, Fedora 21, and MacOSX 10.9
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

## EMACS mode ###########################################

bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

## VI mode ##############################################

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

export https_proxy=$http_proxy
