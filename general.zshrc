# vi: filetype=zsh
# general.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="$( echo $(which nvim) || echo $(which vim) || echo $(which vi) )"
else
  export EDITOR="$( echo $(which nvim) || echo $(which vim) || echo $(which vi) )"
fi

# Need to use gpg-agent with pinentry in macOS
export GPG_TTY=$(tty)
# Use ~/.config directory
export XDG_CONFIG_HOME="$HOME/.config"


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
    [ ! "$PATH" = "*/usr/sbin*" ] && export PATH="/usr/sbin:$PATH"
    [ ! "$PATH" = "*/usr/bin*" ] && export PATH="/usr/bin:$PATH"
    [ ! "$PATH" = "*/usr/local/sbin*" ] && export PATH="/usr/local/sbin:$PATH"
    [ ! "$PATH" = "*/usr/local/bin*" ] && export PATH="/usr/local/bin:$PATH"

    ### Homebrew {{{
      if [[ $OSTYPE == darwin* && $CPUTYPE == arm64 ]]; then
        if [ ! "$HOMEBREW_LOADED" = "true" ]; then
          eval $(/opt/homebrew/bin/brew shellenv)
          export HOMEBREW_LOADED="true"
        fi
      fi
      if [[ $OSTYPE == darwin* && $CPUTYPE == i386 ]]; then
        if [ ! "$HOMEBREW_LOADED" = "true" ]; then
          eval $(/usr/local/bin/brew shellenv)
          export HOMEBREW_LOADED="true"
        fi
      fi
    ### }}}

    # Extend $PATH with user's binary paths in home directory
    [ -d $HOME/.bin ] && export PATH="$HOME/.bin:$PATH"
    [ -d $HOME/bin ] && export PATH="$HOME/bin:$PATH"
    [ -d $HOME/.local/bin ] && export PATH="$HOME/.local/bin:$PATH"
    [ -d $HOME/scripts ] && export PATH="$HOME/scripts:$PATH"
    [ -d $HOME/.rbenv/bin ] && export PATH="$HOME/.rbenv/bin:$PATH"

    if which rbenv > /dev/null; then
      eval "$(rbenv init - zsh)"
    fi
    # Extend $PATH with Ruby Gem's bin directory
    if which ruby > /dev/null && which gem > /dev/null; then
      PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
    fi

    # Node.js
    if which volta > /dev/null; then
      export VOLTA_HOME=$HOME/.volta

      # Extend $PATH with volta's bin directory
      export PATH="$VOLTA_HOME/bin:$PATH"
    fi

    if which kubectl > /dev/null; then
      export PATH="$PATH:$HOME/.krew/bin"
    fi

    export PATH_LOADED="true"
  fi

  # Go PATH
  if which go > /dev/null; then
    export GOPATH=$HOME/go
  fi
### }}}


### SSH {{{
  if [[ "$(uname -s)" == "Darwin" ]]; then
    # The macOS allows us to store SSH keys in the keychain
    # Use `ssh-add -K /path/to/key` to store SSH keys into the macOS keychain
    # Load all SSH keys that have passphrases stored in the macOS keychain
    # ssh-add -A
  fi
  [ -d $HOME/.1password ] && export SSH_AUTH_SOCK=~/.1password/agent.sock
### }}}


### Misc {{{
  # Move to that directory, if a command is issued that can't be executed as a normal command and the command is the name of a directory.
  setopt auto_cd
  # Enable comments in interactive shell
  setopt interactive_comments

  if which aws-vault > /dev/null; then
    if which gopass > /dev/null; then
      export AWS_VAULT_BACKEND=pass
      export AWS_VAULT_PROMPT=osascript
      export AWS_VAULT_PASS_CMD=gopass
      export AWS_VAULT_PASS_PASSWORD_STORE_DIR=$HOME/.local/share/gopass/stores/root
      export AWS_VAULT_PASS_PREFIX=aws-vault/
    fi
  fi

  if which nvim > /dev/null; then
    export KUBE_EDITOR=nvim
  fi

  if which zoxide > /dev/null; then
    eval "$(zoxide init zsh)"
  fi
### }}}
