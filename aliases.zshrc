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

[ -f /usr/local/bin/brew ] \
  && alias ibrew=/usr/local/bin/brew

[ -f /opt/homebrew/bin/brew ] \
  && alias abrew=/opt/homebrew/bin/brew

(( $+commands[chezmoi] )) \
  && alias cz=chezmoi

(( $+commands[zellij] )) \
  && alias zj=zellij

(( $+commands[htop] )) \
  && alias top=htop

(( $+commands[docker] )) \
  && alias d=docker

(( $+commands[kubectl] )) \
  && alias k=kubectl

# `switch` is a shell function defined by `switcher init zsh`, not a binary,
# so the function table must be checked as well
(( $+commands[switch] || $+functions[switch] )) \
  && alias ks=switch

(( $+commands[eza] )) \
  && alias ls=eza

(( $+commands[lazygit] )) \
  && alias g=lazygit

(( $+commands[nvim] )) \
  && alias vim=nvim

(( $+commands[terraform] )) \
  && alias tf=terraform

(( $+commands[packer] )) \
  && alias pkr=packer

(( $+commands[pinentry-mac] )) \
  && alias pinentry=pinentry-mac

(( $+commands[gopass] )) \
  && alias pass=gopass

(( $+commands[claude-squad] )) \
  && alias cs=claude-squad

(( $+commands[grealpath] )) \
  && alias realpath=grealpath
