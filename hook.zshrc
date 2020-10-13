# vi: filetype=zsh
# hook.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


load-tfswitch() {
  if [ -f ".terraform-version" ]; then
    tfswitch
  fi
}
which tfswitch > /dev/null \
  && add-zsh-hook chpwd load-tfswitch
