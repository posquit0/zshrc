# vi: filetype=zsh
# ai.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/

(( $+commands[claude] )) || return 0

# Model for the inline helpers; haiku is the fastest tier
: ${ZSH_AI_MODEL:=haiku}

# zselect sleeps without forking; fall back to `sleep` when unavailable
zmodload zsh/zselect 2>/dev/null && typeset -g _ZSH_AI_HAS_ZSELECT=1

# Run `claude -p` in the background, animating a spinner until it finishes.
# The response is stored in $_ZSH_AI_RESPONSE; returns non-zero when the
# response is empty, or 130 when cancelled with Ctrl+C.
_zsh_ai_request() {
  local prompt=$1 label=$2
  local tmp pid
  tmp=$(mktemp) || return 1
  typeset -g _ZSH_AI_RESPONSE=

  # The status message must stay on one physical line: when it wraps, zle's
  # message area grows and every redraw leaves the previous frame on screen
  # as a ghost line. Strip newlines from the label here; width-based
  # truncation happens per frame below.
  label=${label//$'\n'/ }

  claude -p --model "$ZSH_AI_MODEL" "$prompt" > "$tmp" 2>/dev/null &!
  pid=$!

  # Kill the request and clean up when the user cancels with Ctrl+C
  trap "kill $pid 2>/dev/null; command rm -f '$tmp'; zle -M 'cancelled'; return 130" INT

  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=1 start=$SECONDS
  local msg suffix max
  while kill -0 $pid 2>/dev/null; do
    suffix=" [${ZSH_AI_MODEL}, $(( SECONDS - start ))s, Ctrl+C to cancel]"
    msg="${frames[i]} ${label}"
    # -3 leaves room for the ellipsis and double-width characters (emoji)
    max=$(( COLUMNS - $#suffix - 3 ))
    (( max > 1 && $#msg > max )) && msg="${msg[1,max]}…"
    zle -M "${msg}${suffix}"
    (( i = i % $#frames + 1 ))
    if [[ -n $_ZSH_AI_HAS_ZSELECT ]]; then
      zselect -t 10  # centiseconds
    else
      command sleep 0.1
    fi
  done
  trap - INT

  _ZSH_AI_RESPONSE=$(<"$tmp")
  command rm -f "$tmp"
  [[ -n $_ZSH_AI_RESPONSE ]]
}

# Turn the natural-language description in the buffer into a zsh command
zsh-ai-suggest() {
  [[ -z $BUFFER ]] && return 0
  if _zsh_ai_request \
    "You are a zsh command generator. Reply with a single zsh command only: no code fences, no backticks, no explanation. Task: $BUFFER" \
    "🤖 Suggesting a command for: $BUFFER"; then
    BUFFER=$_ZSH_AI_RESPONSE
    CURSOR=$#BUFFER
    zle -M ""  # clear the last spinner frame
    zle reset-prompt
  elif (( $? != 130 )); then
    zle -M "claude returned no suggestion; check \`claude /login\` or quota"
  fi
}

# Explain the command currently in the buffer
zsh-ai-explain() {
  [[ -z $BUFFER ]] && return 0
  if _zsh_ai_request \
    "Explain what this zsh command does, briefly and in plain text (no markdown): $BUFFER" \
    "🤖 Explaining: $BUFFER"; then
    zle -M "$_ZSH_AI_RESPONSE"
  elif (( $? != 130 )); then
    zle -M "claude returned no explanation; check \`claude /login\` or quota"
  fi
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
