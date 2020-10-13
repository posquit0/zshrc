# vi: filetype=zsh
# completion.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


# TODO: change file name
# Enable `skaffold` auto completion
which skaffold > /dev/null \
  && eval "$(skaffold completion zsh)"
# Enable `pipenv` auto completion
which pipenv > /dev/null \
  && eval "$(pipenv --completion)"
# Creating the virtualenv inside project’s directory
export PIPENV_VENV_IN_PROJECT=1
