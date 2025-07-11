# vi: filetype=zsh
# plugins.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit snippet OMZ::plugins/git/git.plugin.zsh

### Plugin: Fast Syntax Highlighting {{{
  # Fish shell-like syntax highlighting for Zsh
  # INFO: Alternative of `zsh-syntax-highlighting`

  zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
  zinit light zdharma-continuum/fast-syntax-highlighting
### }}}

### Plugin: Autosuggentions {{{
  # Fish-like autosuggestions for zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=244"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_USE_ASYNC=true

  zinit ice wait"0b" lucid atload'
    _zsh_autosuggest_start
    bindkey "^f" forward-word
    bindkey "^e" autosuggest-execute
    # bindkey "^ " autosuggest-accept
  '
  zinit light zsh-users/zsh-autosuggestions
### }}}

### Plugin: Completions {{{
  # Additional completion definitions for Zsh
  zinit ice wait lucid blockf atpull'zinit creinstall -q .'
  zinit light zsh-users/zsh-completions
### }}}

### Plugin: Alias Tips {{{
  # Help remembering those aliases you defined once
  zinit ice from'gh-r' as 'program'
  zinit light decayofmind/zsh-fast-alias-tips
  export ZSH_FAST_ALIAS_TIPS_PREFIX="💡 Alias: $(tput bold)"
### }}}

### Plugin: Calc {{{
  # Support for basic math
  zinit ice wait lucid
  zinit light arzzen/calc.plugin.zsh
### }}}

### Plugin: History Substring Search {{{
  # ZSH port of Fish history search
  # INFO: zsh-history-substring-search should be after zsh-syntax-highlighting
  zinit ice wait lucid atload'
    bindkey "^P" history-substring-search-up
    bindkey "^N" history-substring-search-down
    # Bind UP and DOWN arrow keys
    zmodload zsh/terminfo
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    # Bind UP and DOWN arrow keys (compatibility fallback
    # for Ubuntu 12.04, Fedora 21, and MacOSX 10.9 users)
    bindkey "^[[A" history-substring-search-up
    bindkey "^[[B" history-substring-search-down
    # Bind k and j for VI mode
    bindkey -M vicmd "k" history-substring-search-up
    bindkey -M vicmd "j" history-substring-search-down
  '
  zinit load 'zsh-users/zsh-history-substring-search'
### }}}

### Plugin: VI Mode {{{
  # A better and friendly vi(vim) mode plugin for ZSH.
  zinit ice depth=1
  zinit light jeffreytse/zsh-vi-mode
### }}}

zinit ice wait"2" lucid atload'
  export ZSH_COPILOT_AI_PROVIDER=anthropic
  export ZSH_COPILOT_KEY=^z
'
zinit light Myzel394/zsh-copilot

### Integration: FZF {{{
  zinit ice lucid wait"0"
  zinit snippet "$(brew --prefix)/opt/fzf/shell/completion.zsh"

  zinit ice lucid wait"0" 
  zinit snippet "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
### }}}
