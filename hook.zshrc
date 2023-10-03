# vi: filetype=zsh
# hook.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


load-tfswitch() {
  [ -f ".terraform-version" ] && tfswitch
  [ -f "versions.tf" ] && tfswitch
}
which tfswitch > /dev/null \
  && add-zsh-hook chpwd load-tfswitch

# Enable `direnv` hook
which direnv > /dev/null \
  && eval "$(direnv hook zsh)"
