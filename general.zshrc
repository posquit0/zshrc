# vi: filetype=zsh
# general.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


# Preferred editor for local and remote sessions
for _editor in nvim vim vi; do
  if (( $+commands[$_editor] )); then
    export EDITOR=$_editor
    break
  fi
done
unset _editor

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
  export HISTSIZE=100000
  # The number of lines of your history you want saved
  export SAVEHIST=100000

  # Ensure that commands are added to the history immediately
  setopt inc_append_history
  # Record the timestamp of each command in HISTFILE
  setopt extended_history
  # Skip duplicates while searching
  setopt hist_find_no_dups
  # Remove older duplicates when a command is re-entered
  setopt hist_ignore_all_dups
  # Do not write duplicates to the history file
  setopt hist_save_no_dups
  # Remove superfluous blanks before recording
  setopt hist_reduce_blanks
  # Do not record commands starting with a space
  setopt hist_ignore_space
### }}}


### Path {{{
  # Keep entries in $path (and the tied $PATH) unique; the first occurrence wins
  typeset -U path PATH
  export PATH

  if [ ! "$PATH_LOADED" = "true" ]; then
    # Extend $PATH with the system binary directories
    path=(/usr/local/bin /usr/local/sbin /usr/bin /usr/sbin $path)

    if (( $+commands[kiro-cli] )); then
      [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
    fi

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
    [ -d $HOME/.bin ] && path=($HOME/.bin $path)
    [ -d $HOME/bin ] && path=($HOME/bin $path)
    [ -d $HOME/.local/bin ] && path=($HOME/.local/bin $path)
    [ -d $HOME/scripts ] && path=($HOME/scripts $path)
    [ -d $HOME/.rbenv/bin ] && path=($HOME/.rbenv/bin $path)

    # Extend $PATH with mise shims so mise-managed tools are visible to
    # non-interactive shells and to startup-time checks; `mise activate`
    # swaps these for the real tool paths in interactive shells
    [ -d ${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims ] \
      && path=(${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims $path)

    if (( $+commands[rbenv] )); then
      eval "$(rbenv init - zsh)"
    fi
    # Extend $PATH with Ruby Gem's bin directory
    if (( $+commands[ruby] )) && (( $+commands[gem] )); then
      path=("$(ruby -r rubygems -e 'puts Gem.user_dir')/bin" $path)
    fi

    # Node.js
    if (( $+commands[volta] )); then
      export VOLTA_HOME=$HOME/.volta

      # Extend $PATH with volta's bin directory
      path=($VOLTA_HOME/bin $path)
    fi

    if (( $+commands[kubectl] )); then
      path+=($HOME/.krew/bin)
    fi

    if (( $+commands[antigravity] )); then
      path+=($HOME/.antigravity/antigravity/bin)
    fi

    export PATH_LOADED="true"
  fi

  # Go PATH
  if (( $+commands[go] )); then
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

  if (( $+commands[aws-vault] )); then
    if (( $+commands[gopass] )); then
      export AWS_VAULT_BACKEND=pass
      export AWS_VAULT_PROMPT=osascript
      export AWS_VAULT_PASS_CMD=gopass
      export AWS_VAULT_PASS_PASSWORD_STORE_DIR=$HOME/.local/share/gopass/stores/root
      export AWS_VAULT_PASS_PREFIX=aws-vault/
    fi
  fi

  if (( $+commands[nvim] )); then
    export KUBE_EDITOR=nvim
  fi

  if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
  fi
### }}}
