# vi: filetype=zsh
# general.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="$( echo $(which nvim) || echo $(which vim) || echo $(which vi) )"
else
  export EDITOR="$( echo $(which nvim) || echo $(which vim) || echo $(which vi) )"
fi

### Locale {{{
  # You may need to manually set your language environment
  export LANG="en_US.UTF-8"
  export LANGUAGE=
  export LC_CTYPE="en_US.UTF-8"
  export LC_NUMERIC="en_US.UTF-8"
  export LC_TIME="en_US.UTF-8"
  export LC_COLLATE="C"
  export LC_MONETARY="ko_KR.UTF-8"
  export LC_MESSAGES="POSIX"
  export LC_PAPER="ko_KR.UTF-8"
  export LC_NAME="ko_KR.UTF-8"
  export LC_ADDRESS="ko_KR.UTF-8"
  export LC_TELEPHONE="ko_KR.UTF-8"
  export LC_MEASUREMENT="ko_KR.UTF-8"
  export LC_IDENTIFICATION="ko_KR.UTF-8"
  export LC_ALL=
### }}}


### History {{{
  # Tell it where to save the history
  export HISTFILE=$HOME/.zsh_history
  # The number of lines from $HISTFILE to read at the start of an interactive session
  export HISTSIZE=10000
  # The number of lines of your history you want saved
  export SAVEHIST=10000

  # Ensure that commands are added to the history immediately
  setopt inc_append_history
  # Record the timestamp of each command in HISTFILE
  setopt extended_history
  # Skip duplicates while searching
  setopt hist_find_no_dups
### }}}


### Path {{{
  if [ ! "$PATH_LOADED" = "true" ]; then
    # Extend $PATH with Homebrew's sbin directory
    [ ! "$PATH" = "*/usr/local/sbin*" ] && export PATH="/usr/local/sbin:$PATH"

    # Extend $PATH with user's binary paths in home directory
    [ -d $HOME/.bin ] && export PATH="$HOME/.bin:$PATH"
    [ -d $HOME/bin ] && export PATH="$HOME/bin:$PATH"
    [ -d $HOME/.local/bin ] && export PATH="$HOME/.local/bin:$PATH"

    # Extend $PATH with Ruby Gem's bin directory
    if which ruby > /dev/null && which gem > /dev/null; then
      PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
    fi

    export PATH_LOADED="true"
  fi
### }}}
