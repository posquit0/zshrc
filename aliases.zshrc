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
  && alias n=nvim

which terraform > /dev/null \
  && alias tf=terraform
