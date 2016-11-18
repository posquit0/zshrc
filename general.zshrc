# general.zshrc
#
# Maintained by Claud D. Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


### General {{{
  # Define default $PATH and $MANPATH
  export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
  export MANPATH="/usr/local/man:$MANPATH"

  # Extend $PATH with ~/.bin
  [ -d $HOME/.bin ] && export PATH="$PATH:$HOME/.bin"

  # You may need to manually set your language environment
  export LANG="ko_KR.UTF-8"
  export LANGUAGE="ko_KR:ko:en_US:en"
  export LC_CTYPE="ko_KR.UTF-8"
  export LC_NUMERIC="ko_KR.UTF-8"
  export LC_TIME="en_US.UTF-8"
  export LC_COLLATE="ko_KR.UTF-8"
  export LC_MONETARY="ko_KR.UTF-8"
  export LC_MESSAGES="POSIX"
  export LC_PAPER="ko_KR.UTF-8"
  export LC_NAME="ko_KR.UTF-8"
  export LC_ADDRESS="ko_KR.UTF-8"
  export LC_TELEPHONE="ko_KR.UTF-8"
  export LC_MEASUREMENT="ko_KR.UTF-8"
  export LC_IDENTIFICATION="ko_KR.UTF-8"
  export LC_ALL=

  # Load alias list
  [ -f $HOME/.alias ] && source $HOME/.alias

  # Set term that supports 256 colors
  # export TERM=screen-256color

  # Preferred editor for local and remote sessions
  if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
  else
    export EDITOR='nvim'
  fi

  # Compilation flags
  # export ARCHFLAGS="-arch x86_64"

  # ssh
  # export SSH_KEY_PATH="~/.ssh/rsa_id"
### }}}
