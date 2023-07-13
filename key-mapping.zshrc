# vi: filetype=zsh
# key-mapping.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


### Vi Mode {{{
  # Switch into vi mode
  bindkey -v

  # Make Vi mode transitions faster (KEYTIMEOUT is in hundredths of a second)
  export KEYTIMEOUT=1

  # Better searching in command mode
  bindkey -M vicmd '?' history-incremental-search-backward
  bindkey -M vicmd '/' history-incremental-search-forward

  # Allow `v` to edit the command line
  # zle -N edit-command-line
  # autoload -Uz edit-command-line
  # bindkey -M vicmd v edit-command-line
### }}}

### Custom {{{
  # Allow to move to beginning/end of line
  bindkey '^a' beginning-of-line
  bindkey '^e' end-of-line

  # Allow to move to backward/forward of word
  bindkey '^b' backward-word
  bindkey '^f' forward-word
### }}}
