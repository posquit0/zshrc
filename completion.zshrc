# vi: filetype=zsh
# completion.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/

autoload bashcompinit && bashcompinit

if which brew > /dev/null; then
  fpath+=$(brew --prefix)/share/zsh/site-functions
fi

# Enable `terraform` auto completion
which terraform > /dev/null \
  && complete -o nospace -C '$(which terraform)' terraform

# Enable `packer` auto completion
which packer > /dev/null \
  && complete -o nospace -C '$(which packer)' packer

# Enable `skaffold` auto completion
which skaffold > /dev/null \
  && eval "$(skaffold completion zsh)"

# Enable `kaf` auto completion
which kaf > /dev/null \
  && kaf completion zsh > "${fpath[1]}/_kaf"

# Enable `kubebuilder` auto completion
which kubebuilder > /dev/null \
  && eval "$(kubebuilder completion zsh)"

# Enable `aws` auto completion
which aws > /dev/null \
  && complete -C '$(which aws_completer)' aws

# Enable `aws-vault` auto completion
which aws-vault > /dev/null \
  && eval "$(aws-vault --completion-script-zsh)"

# Enable `pipenv` auto completion
which pipenv > /dev/null \
  && eval "$(_PIPENV_COMPLETE=zsh_source pipenv)"
# Creating the virtualenv inside project’s directory
export PIPENV_VENV_IN_PROJECT=1

autoload -Uz compinit && compinit
