# vi: filetype=zsh
# .zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


# Set the path of zsh configuration directory
export ZSH_HOME=$HOME/.zsh

# Load a general configuration of zsh
[ -f $ZSH_HOME/general.zshrc ] && source $ZSH_HOME/general.zshrc

# Load a key mapping configuration of zsh
[ -f $ZSH_HOME/key-mapping.zshrc ] && source $ZSH_HOME/key-mapping.zshrc

# Load a configuration of zsh plugins
[ -f $ZSH_HOME/plugins.zshrc ] && source $ZSH_HOME/plugins.zshrc

# Load a hook configuration of zsh
[ -f $ZSH_HOME/hook.zshrc ] && source $ZSH_HOME/hook.zshrc

# Load an completion configuration of zsh
[ -f $ZSH_HOME/completion.zshrc ] && source $ZSH_HOME/completion.zshrc

# Load an alias configuration of zsh
[ -f $ZSH_HOME/aliases.zshrc ] && source $ZSH_HOME/aliases.zshrc

# Load a local configuration of zsh
[ -f $HOME/.zshrc.local ] && source $HOME/.zshrc.local
