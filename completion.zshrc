# vi: filetype=zsh
# completion.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/

autoload bashcompinit && bashcompinit

# Enable `terraform` auto completion
which terraform > /dev/null \
  && complete -o nospace -C '/usr/local/bin/terraform' terraform

# Enable `packer` auto completion
which packer > /dev/null \
  && complete -o nospace -C '/usr/local/bin/packer' packer

# Enable `skaffold` auto completion
which skaffold > /dev/null \
  && eval "$(skaffold completion zsh)"

# Enable `kubebuilder` auto completion
which kubebuilder > /dev/null \
  && eval "$(kubebuilder completion zsh)"

# Enable `aws` auto completion
which aws > /dev/null \
  && complete -C '/usr/local/bin/aws_completer' aws

# Enable `aws-vault` auto completion
which aws-vault > /dev/null \
  && eval "$(aws-vault --completion-script-zsh)"

# Enable `pipenv` auto completion
which pipenv > /dev/null \
  && eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"
# Creating the virtualenv inside project’s directory
export PIPENV_VENV_IN_PROJECT=1
