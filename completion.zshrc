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

  # Docker Desktop ships its CLI completions here; just register the
  # directory and let the single compinit below pick them up
  [ -d "$HOME/.docker/completions" ] \
    && fpath+=("$HOME/.docker/completions")

  # Initialize the completion system.
  # compinit scans every directory in $fpath and writes the result to a cache
  # file (~/.zcompdump). The scan is the slow part, so run it at most once a
  # day; otherwise reuse the cache as-is with -C, which skips the scan.
  #
  # The condition is a zsh glob, not a regex. It reads as: "does a plain
  # file (.) named .zcompdump, modified more than 24 hours ago (mh+24),
  # exist (N: expand to nothing instead of erroring when it does not)?"
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
  # Usage: _completion_cache <command> <args...>
  # Saves the output of `<command> <args...>` as the completion file
  # ~/.zfunc/_<command>, but only when that file is missing or older than
  # the command's binary (i.e. the tool was upgraded since the last run).
  # This replaces regenerating every completion file on every shell startup.
  function _completion_cache() {
    local cmd=$1 target="$HOME/.zfunc/_$1"
    shift
    (( $+commands[$cmd] )) || return 0
    if [[ ! -f $target || $target -ot ${commands[$cmd]} ]]; then
      # Drop the file on failure so a broken run doesn't cache an empty
      # completion (e.g. a mise shim whose tool is not yet activated)
      "$cmd" "$@" > "$target" 2>/dev/null || rm -f "$target"
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
