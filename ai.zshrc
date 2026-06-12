# vi: filetype=zsh
# ai.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/

(( $+commands[claude] )) || return 0

# Model for the inline helpers; haiku is the fastest tier
: ${ZSH_AI_MODEL:=haiku}

# Turn the natural-language description in the buffer into a zsh command
zsh-ai-suggest() {
  [[ -z $BUFFER ]] && return 0
  zle -M "🤖 Suggesting a command for: $BUFFER"
  local suggestion
  suggestion=$(claude -p --model "$ZSH_AI_MODEL" \
    "You are a zsh command generator. Reply with a single zsh command only: no code fences, no backticks, no explanation. Task: $BUFFER" 2>/dev/null)
  if [[ -n $suggestion ]]; then
    BUFFER=$suggestion
    CURSOR=$#BUFFER
    zle reset-prompt
  else
    zle -M "claude returned no suggestion; check \`claude /login\` or quota"
  fi
}

# Explain the command currently in the buffer
zsh-ai-explain() {
  [[ -z $BUFFER ]] && return 0
  zle -M "🤖 Explaining: $BUFFER"
  local explanation
  explanation=$(claude -p --model "$ZSH_AI_MODEL" \
    "Explain what this zsh command does, briefly and in plain text (no markdown): $BUFFER" 2>/dev/null)
  zle -M "${explanation:-claude returned no explanation; check \`claude /login\` or quota}"
}

zle -N zsh-ai-suggest
zle -N zsh-ai-explain

_zsh_ai_bind_keys() {
  bindkey '«' zsh-ai-suggest  # Option+\ on macOS
  bindkey '»' zsh-ai-explain  # Option+Shift+\ on macOS
}

if (( $+functions[zvm_init] )); then
  # zsh-vi-mode rebuilds keymaps when it initializes at the first prompt,
  # which would drop bindings made here; register them to run afterwards
  zvm_after_init_commands+=(_zsh_ai_bind_keys)
else
  _zsh_ai_bind_keys
fi
