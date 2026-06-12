# vi: filetype=zsh
# hook.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


# `add-zsh-hook` is not loaded by default; do not rely on plugins to do it
autoload -Uz add-zsh-hook

# Enable `tfswitch` hook
load-tfswitch() {
  if [ -f ".terraform-version" ] || [ -f "versions.tf" ]; then
    tfswitch
  fi
}
if (( $+commands[tfswitch] )); then
  add-zsh-hook chpwd load-tfswitch
  load-tfswitch
fi

# Enable the `mise` hook, falling back to `direnv` when mise is not
# installed; mise covers direnv's use case so both hooks are not needed
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
elif (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
