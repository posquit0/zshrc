# vi: filetype=zsh
# ai.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/

(( $+commands[claude] )) || return 0

# Model for the inline helpers; haiku is the fastest tier
: ${ZSH_AI_MODEL:=haiku}
# Highlight style of the loading status (defaults to a comment-like gray)
: ${ZSH_AI_STATUS_STYLE:=fg=244}
# Highlight style of the explanation result (defaults to bright cyan, bold)
: ${ZSH_AI_RESULT_STYLE:=fg=14,bold}
# Spinner refresh interval in milliseconds
: ${ZSH_AI_SPINNER_INTERVAL:=200}

# zselect sleeps without forking; fall back to `sleep` when unavailable
zmodload zsh/zselect 2>/dev/null && typeset -g _ZSH_AI_HAS_ZSELECT=1

# Expand a leading alias in the given command line, so the LLM sees the
# real command (e.g. `k get pods` -> `kubectl get pods`). Only the first
# word is expanded; aliases after pipes or separators are left alone since
# expanding them safely would require a full shell parse.
_zsh_ai_expand_aliases() {
  local cmd=$1
  local first expansion
  local -i guard=10
  while (( guard-- > 0 )); do
    first=${cmd%% *}
    expansion=${aliases[$first]}
    [[ -z $expansion || $expansion == "$first" ]] && break
    cmd="${expansion}${cmd#"$first"}"
    # Stop on self-referencing aliases like ssh='ssh -A'
    [[ ${expansion%% *} == "$first" ]] && break
  done
  print -r -- "$cmd"
}

# Run `claude -p` in the background, animating a spinner until it finishes.
# The response is stored in $_ZSH_AI_RESPONSE; returns non-zero when the
# response is empty, or 130 when cancelled with Ctrl+C.
#
# The status line is rendered through $POSTDISPLAY (the mechanism
# zsh-autosuggestions uses): it is part of the editor display, so zle
# repaints it in place on every `zle -R`. Animating via `zle -M` instead
# leaves the previous frame behind as a ghost line whenever the message
# wraps or the prompt sits at the bottom of the screen.
_zsh_ai_request() {
  local prompt=$1 label=$2
  local tmp pid
  tmp=$(mktemp) || return 1
  typeset -g _ZSH_AI_RESPONSE=

  # Keep the status to one line: strip newlines here, truncate per frame
  label=${label//$'\n'/ }

  claude -p --model "$ZSH_AI_MODEL" "$prompt" > "$tmp" 2>/dev/null &!
  pid=$!

  # On Ctrl+C, kill the request and let the loop exit on its own; the
  # normal cleanup path below restores the display
  local cancelled=0
  trap "kill $pid 2>/dev/null; cancelled=1" INT

  local saved_postdisplay=$POSTDISPLAY
  local -a saved_highlight=("${region_highlight[@]}")

  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=1 start=$SECONDS
  local msg suffix max
  while kill -0 $pid 2>/dev/null; do
    suffix=" [${ZSH_AI_MODEL}, $(( SECONDS - start ))s, Ctrl+C to cancel]"
    msg="${frames[i]} ${label}"
    # -3 leaves room for the ellipsis and double-width characters (emoji)
    max=$(( COLUMNS - $#suffix - 3 ))
    (( max > 1 && $#msg > max )) && msg="${msg[1,max]}…"
    POSTDISPLAY=$'\n'"${msg}${suffix}"
    # region_highlight offsets cover BUFFER followed by POSTDISPLAY
    region_highlight=("${saved_highlight[@]}"
      "$#BUFFER $(( $#BUFFER + $#POSTDISPLAY )) ${ZSH_AI_STATUS_STYLE}")
    zle -R
    (( i = i % $#frames + 1 ))
    if [[ -n $_ZSH_AI_HAS_ZSELECT ]]; then
      zselect -t $(( ZSH_AI_SPINNER_INTERVAL / 10 ))  # centiseconds
    else
      command sleep $(( ZSH_AI_SPINNER_INTERVAL / 1000.0 ))
    fi
  done
  trap - INT

  POSTDISPLAY=$saved_postdisplay
  region_highlight=("${saved_highlight[@]}")
  zle -R

  if (( cancelled )); then
    command rm -f "$tmp"
    zle -M "cancelled"
    return 130
  fi

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
    zle reset-prompt
  elif (( $? != 130 )); then
    zle -M "claude returned no suggestion; check \`claude /login\` or quota"
  fi
}

# Explain the command currently in the buffer, with leading aliases
# expanded so the LLM is told what will actually run
zsh-ai-explain() {
  [[ -z $BUFFER ]] && return 0
  local cmd
  cmd=$(_zsh_ai_expand_aliases "$BUFFER")
  if _zsh_ai_request \
    "Explain what this zsh command does, briefly and in plain text (no markdown): $cmd" \
    "🤖 Explaining: $cmd"; then
    # Render the explanation below the buffer through POSTDISPLAY so it can
    # be styled with region_highlight (zle -M cannot be colored); it stays
    # visible until the next keystroke repaints the editor
    POSTDISPLAY=$'\n'"$_ZSH_AI_RESPONSE"
    region_highlight+=("$#BUFFER $(( $#BUFFER + $#POSTDISPLAY )) ${ZSH_AI_RESULT_STYLE}")
    zle -R
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
