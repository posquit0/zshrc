# vi: filetype=zsh
# plugins.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


source $ZSH_HOME/zplug/init.zsh


### Plugin: Autosuggentions {{{
  # Fish-like autosuggestions for zsh
  zplug "zsh-users/zsh-autosuggestions", as:plugin, \
    defer:2, \
    hook-load:"config-zplug-zsh-autosuggestions"

  function config-zplug-zsh-autosuggestions() {
    # Color to use when highlighting suggestion
    # Uses format of `region_highlight`
    # More info: http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
    # ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=2'
    # Accept suggestions without leaving insert mode
    bindkey '^f' vi-forward-blank-word
  }
### }}}

### Plugin: Completions {{{
  # Additional completion definitions for Zsh
  zplug "zsh-users/zsh-completions", as:plugin
### }}}

### Plugin: Alias Tips {{{
  # Help remembering those aliases you defined once
  zplug "djui/alias-tips"
### }}}

### Plugin: Calc {{{
  # Support for basic math
  zplug "arzzen/calc.plugin.zsh"
### }}}

### Plugin: Fast Syntax Highlighting {{{
  # Fish shell-like syntax highlighting for Zsh
  # INFO: Alternative of `zsh-syntax-highlighting`
  zplug "zdharma/fast-syntax-highlighting", as:plugin, \
    defer:2, \
    hook-load:"config-zplug-fast-syntax-highlighting"

  function config-zplug-fast-syntax-highlighting() {
    fast-theme default -q
  }
### }}}

### Plugin: History Substring Search {{{
  # ZSH port of Fish history search
  # INFO: zsh-history-substring-search should be after zsh-syntax-highlighting
  zplug "zsh-users/zsh-history-substring-search", as:plugin, \
    defer:3, \
    hook-load:"config-zplug-zsh-history-substring-search"

  function config-zplug-zsh-history-substring-search() {
    # Bind UP and DOWN arrow keys
    zmodload zsh/terminfo
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    # Bind UP and DOWN arrow keys (compatibility fallback
    # for Ubuntu 12.04, Fedora 21, and MacOSX 10.9 users)
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    # Bind P and N for EMACS mode
    bindkey -M emacs '^P' history-substring-search-up
    bindkey -M emacs '^N' history-substring-search-down
    # Bind k and j for VI mode
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
  }
### }}}

### Plugin: Python Auto Switch Virtualenv {{{
  # Automatically switch python virtualenvs as you move between directories
  # Commands: mkvenv, rmvenv
  zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
### }}}

# zplug "b4b4r07/zsh-vimode-visual", defer:3

zplug "cusxio/delta-prompt", use:"delta.zsh"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  else
    echo
  fi
fi

# Then, source plugins and add commands to $PATH
zplug load
unfunction -m "config-zplug-*"
