# vi: filetype=zsh
# completion.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


### Completion System {{{
  # Register extra completion directories BEFORE compinit so they are picked up
  if (( $+commands[brew] )); then
    fpath+=("$(brew --prefix)/share/zsh/site-functions")
  fi

  mkdir -p "$HOME/.zfunc"
  fpath+=("$HOME/.zfunc")

  # Initialize the completion system.
  # Perform the full (secure) initialization only when the dump file is older
  # than 24 hours; otherwise reuse the cached dump (-C) for a faster startup.
  autoload -Uz compinit
  if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    compinit
  else
    compinit -C
  fi

  # Replay `compdef` calls that zinit queued for plugins loaded before compinit
  (( $+functions[zinit] )) && zinit cdreplay -q

  # Enable bash-style `complete` for tools that only ship bash completions
  autoload -Uz bashcompinit && bashcompinit
### }}}


### Helpers {{{
  # Generate a completion file only when it is missing or older than the tool
  # binary, instead of regenerating it on every shell startup
  function _completion_cache() {
    local cmd=$1 target="$HOME/.zfunc/_$1"
    shift
    (( $+commands[$cmd] )) || return 0
    if [[ ! -f $target || $target -ot ${commands[$cmd]} ]]; then
      "$cmd" "$@" > "$target"
    fi
  }
### }}}


# Enable `mise` auto completion
_completion_cache mise completion zsh

# Enable `terraform` auto completion
(( $+commands[terraform] )) \
  && complete -o nospace -C "${commands[terraform]}" terraform

# Enable `volta` auto completion
_completion_cache volta completions zsh

# Enable `packer` auto completion
(( $+commands[packer] )) \
  && complete -o nospace -C "${commands[packer]}" packer

# Enable `skaffold` auto completion
(( $+commands[skaffold] )) \
  && eval "$(skaffold completion zsh)"

# Enable `kaf` auto completion
_completion_cache kaf completion zsh

# Enable `kubebuilder` auto completion
(( $+commands[kubebuilder] )) \
  && eval "$(kubebuilder completion zsh)"

if (( $+commands[switcher] )); then
  source <(switcher init zsh)
  compdef _switcher switch
  source <(switch completion zsh)
fi

# Enable `aws` auto completion
(( $+commands[aws] && $+commands[aws_completer] )) \
  && complete -C "${commands[aws_completer]}" aws

# Enable `aws-vault` auto completion
(( $+commands[aws-vault] )) \
  && eval "$(aws-vault --completion-script-zsh)"

# Enable `poetry` auto completion
_completion_cache poetry completions zsh

# Enable `pipenv` auto completion
(( $+commands[pipenv] )) \
  && eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"
# Creating the virtualenv inside project’s directory
export PIPENV_VENV_IN_PROJECT=1

unfunction _completion_cache
