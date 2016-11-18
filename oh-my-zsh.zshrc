# oh-my-zsh.zshrc
#
# Maintained by Claud D. Park <posquit0.bj@gmail.com>
# http://www.posquit0.com/


### Oh-My-Zsh {{{
  # Path to your oh-my-zsh installation.
  export ZSH=$ZSH_HOME/oh-my-zsh
  ZSH_CUSTOM=$ZSH_HOME/oh-my-zsh-custom

  # Uncomment the following line to change how often to auto-update (in days).
  export UPDATE_ZSH_DAYS=7
  # Uncomment the following line to disable bi-weekly auto-update checks.
  # DISABLE_AUTO_UPDATE="true"

  # Uncomment the following line to disable auto-setting terminal title.
  DISABLE_AUTO_TITLE="true"
  # Uncomment the following line to use case-sensitive completion.
  CASE_SENSITIVE="true"
  # Uncomment the following line to use hyphen-insensitive completion.
  # Case sensitive completion must be off. _ and - will be interchangeable.
  # HYPHEN_INSENSITIVE="true"
  # Uncomment the following line to enable command auto-correction.
  # ENABLE_CORRECTION="true"
  # Uncomment the following line to display red dots whilst waiting for completion.
  # COMPLETION_WAITING_DOTS="true"

  # Uncomment the following line if you want to disable marking untracked files
  # under VCS as dirty. This makes repository status check for large repositories
  # much, much faster.
  DISABLE_UNTRACKED_FILES_DIRTY="true"

  # Uncomment the following line if you want to change the command execution time
  # stamp shown in the history command output.
  # The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
  HIST_STAMPS="yyyy-mm-dd"

  # Uncomment the following line to disable colors in ls.
  # DISABLE_LS_COLORS="true"

  # Set name of the theme to load.
  # Look in ~/.zsh/oh-my-zsh/themes/
  # Optionally, if you set this to "random", it'll load a random theme each
  # time that oh-my-zsh is loaded.
  ZSH_THEME="posquit0"
### }}}


### Plugin List {{{
### Which plugins would you like to load? (plugins can be found in ~/.zsh/oh-my-zsh/plugins/*)
### Custom plugins may be added to ~/.zsh/oh-my-zsh/custom/plugins/
  # Add wisely, as too many plugins slow down shell startup.
  plugins=(
    # Autocompletion or alias
    screen supervisor
    git git-flow mercurial docker docker-compose aws
    mvn scala sbt
    python pip pylint pep8 virtualenv virtualenvwrapper fabric
    gem
    node npm cofee bower gulp
    colored-man-pages
    # Useful tools
    colorize catimg command-not-found common-aliases
    encode64 jsontools urltools sudo gitignore themes
    emoji-clock
    # Just for fun
    nyan rand-quote
    # Custom or 3rd-party
    alias-tips zsh-autosuggestions
    resty motd
    # Note that zsh-syntax-highlighting must be the last plugin sourced
    zsh-syntax-highlighting
  )
  # Note that zsh-history-substring-search should be after zsh-syntax-highlighting
  [ -f $ZSH_CUSTOM/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ] \
    && source $ZSH_CUSTOM/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
### }}}

[ -f $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh
