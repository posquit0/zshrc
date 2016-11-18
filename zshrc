# .zshrc
#
# Maintained by Claud D. Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


# Set the path of zsh configuration directory
export ZSH_HOME=$HOME/.zsh

# Load a configuration of oh-my-zsh
[ -f $ZSH_HOME/oh-my-zsh.zshrc ] && source $ZSH_HOME/oh-my-zsh.zshrc

# Load a general configuration of zsh
[ -f $ZSH_HOME/general.zshrc ] && source $ZSH_HOME/general.zshrc


### User Configuration {{{
  # Ruby
  # eval "$(rbenv init -)"
  # Node.JS
  [ -f ~/.tools/nvm/nvm.sh ] && source ~/.tools/nvm/nvm.sh
  # Fzf(Fuzzy Finder)
  # Usage: Ctrl+T, Ctrl+R, Alt+C
  if [ -f ~/.fzf.zsh  ]; then
    source ~/.fzf.zsh
    bindkey '^T' fzf-completion
    bindkey '^I' $fzf_default_completion
  fi
### }}}


### Plugin Configuration {{{
  ## Plugin: History-Substring-Search {{
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
  ## }}
  ## Plugin: Autosuggestions {{
    # Use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
    # zsh-autosuggestions is designed to be unobtrusive)
    # bindkey '^T' autosuggest-toggle
    # Accept suggestions without leaving insert mode
    bindkey '^f' vi-forward-blank-word
  ## }}
### }}}

# Load a custom configuration of zsh
[ -f $HOME/.zshrc.custom ] && source $HOME/.zshrc.custom
