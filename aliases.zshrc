# vi: filetype=zsh
# aliases.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


alias ~="cd ~/"
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias ll="ls -l"
alias grep="grep --color=auto"

# Use python3 as default
alias python=python3

# Pass credentials by default
alias ssh="ssh -A"

which chezmoi > /dev/null \
  && alias cm=chezmoi

which htop > /dev/null \
  && alias top=htop

which docker > /dev/null \
  && alias d=docker

which kubectl > /dev/null \
  && alias k=kubectl

which exa > /dev/null \
  && alias ls=exa

which lazygit > /dev/null \
  && alias g=lazygit

which nvim > /dev/null \
  && alias vim=nvim

which terraform > /dev/null \
  && alias tf=terraform

which packer > /dev/null \
  && alias pkr=packer

which pinentry-mac > /dev/null \
  && alias pinentry=pinentry-mac

which gopass > /dev/null \
  && alias pass=gopass
