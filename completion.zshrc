# vi: filetype=zsh
# completion.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/

autoload bashcompinit && bashcompinit

# Enable `skaffold` auto completion
which skaffold > /dev/null \
  && eval "$(skaffold completion zsh)"

# Enable `aws` auto completion
which aws > /dev/null \
  && complete -C '/usr/local/bin/aws_completer' aws

# Enable `aws-vault` auto completion
which aws-vault > /dev/null \
  && eval "$(aws-vault --completion-script-zsh)"

# Enable `pipenv` auto completion
which pipenv > /dev/null \
  && eval "$(pipenv --completion)"
# Creating the virtualenv inside project’s directory
export PIPENV_VENV_IN_PROJECT=1
