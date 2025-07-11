# vi: filetype=zsh
# aliases.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


alias ~="cd ~/"
alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
alias ll="ls -l"
alias la="ls -A"
alias lal="ls -Al"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# Use python3 as default
alias python=python3

# Pass credentials by default
alias ssh="ssh -A"

which chezmoi > /dev/null \
  && alias cz=chezmoi

which zellij > /dev/null \
  && alias zj=zellij

which htop > /dev/null \
  && alias top=htop

which docker > /dev/null \
  && alias d=docker

which kubectl > /dev/null \
  && alias k=kubectl

which switch > /dev/null \
  && alias ks=switch

which eza > /dev/null \
  && alias ls=eza

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
