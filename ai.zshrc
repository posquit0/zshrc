# vi: filetype=zsh
# ai.zshrc
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/

# Supported AI backends, mapped to the binary that provides them. Each entry
# also implies two optional overrides, derived from the provider name:
#   ZSH_AI_<PROVIDER>_MODEL   model to use for that provider
#   ZSH_AI_<PROVIDER>_OPTS    extra CLI flags, parsed as shell words
# e.g. ZSH_AI_KIRO_CLI_OPTS='--agent fast --model auto'
typeset -gA _ZSH_AI_PROVIDER_BIN=(
  claude-code claude
  kiro-cli    kiro-cli
  codex       codex
)
# Model used when neither ZSH_AI_<PROVIDER>_MODEL nor ZSH_AI_MODEL is set.
# An empty value means "let the provider pick": kiro-cli only exposes `auto`,
# and codex takes its default from ~/.codex/config.toml (a ChatGPT account
# rejects most explicit model names anyway).
typeset -gA _ZSH_AI_PROVIDER_MODEL=(
  claude-code haiku
  kiro-cli    ''
  codex       ''
)
# Hint shown when a provider returns nothing, usually an auth or quota issue
typeset -gA _ZSH_AI_PROVIDER_HINT=(
  claude-code 'check `claude /login` or quota'
  kiro-cli    'check `kiro-cli login` or quota'
  codex       'check `codex login` or quota'
)

# Bail out only if none of the backends is installed; the active one is
# resolved per request, so ZSH_AI_PROVIDER may change at any time
() {
  local bin
  for bin in ${(v)_ZSH_AI_PROVIDER_BIN}; do
    (( $+commands[$bin] )) && return 0
  done
  return 1
} || return 0

# Backend used by the inline helpers: claude-code, kiro-cli or codex. Exported
# so tools launched from the shell (e.g. the lazygit AI commit message command)
# follow the same choice.
typeset -gx ZSH_AI_PROVIDER=${ZSH_AI_PROVIDER:-claude-code}
# Model override applied to every provider; empty means the provider default
typeset -gx ZSH_AI_MODEL=${ZSH_AI_MODEL:-}
# Highlight style of the loading status (defaults to a comment-like gray)
: ${ZSH_AI_STATUS_STYLE:=fg=244}
# Sweep the Instagram gradient across the loading status; 0 keeps it plain
: ${ZSH_AI_STATUS_GRADIENT:=1}
# Highlight style of the explanation result (defaults to bright cyan, bold)
: ${ZSH_AI_RESULT_STYLE:=fg=14,bold}
# Spinner refresh interval in milliseconds
: ${ZSH_AI_SPINNER_INTERVAL:=70}

# zselect sleeps without forking; fall back to `sleep` when unavailable
zmodload zsh/zselect 2>/dev/null && typeset -g _ZSH_AI_HAS_ZSELECT=1

# Instagram's brand gradient as 24-bit stops: violet-blue through purple and
# magenta into red, orange and yellow
typeset -ga _ZSH_AI_GRAD_STOPS=(
  '64;93;230'    # #405DE6
  '88;81;219'    # #5851DB
  '131;58;180'   # #833AB4
  '193;53;132'   # #C13584
  '225;48;108'   # #E1306C
  '253;29;29'    # #FD1D1D
  '245;96;64'    # #F56040
  '247;119;55'   # #F77737
  '252;175;69'   # #FCAF45
  '255;220;128'  # #FFDC80
)

# Interpolate the stops into $1 `fg=` colours in $_ZSH_AI_RAMP, so the gradient
# runs smoothly across the characters of the status line instead of banding.
# Terminals without 24-bit colour get the nearest entry of the xterm cube.
_zsh_ai_ramp() {
  emulate -L zsh
  local -i n=$1 i seg frac steps r g b
  local -i count=$#_ZSH_AI_GRAD_STOPS
  local -a from to
  typeset -ga _ZSH_AI_RAMP=()
  [[ -n $NO_COLOR || $ZSH_AI_STATUS_GRADIENT == 0 ]] && return 0
  local truecolor=
  [[ $COLORTERM == (truecolor|24bit) || $TERM == *-direct* ]] && truecolor=1
  steps=$(( count - 1 ))
  for (( i = 0; i < n; i++ )); do
    # Position along the whole ramp, in thousandths of a segment
    (( frac = i * steps * 1000 / (n > 1 ? n - 1 : 1) ))
    (( seg = frac / 1000 + 1 ))
    (( seg > steps )) && (( seg = steps ))
    (( frac = frac - (seg - 1) * 1000 ))
    from=(${(s.;.)_ZSH_AI_GRAD_STOPS[seg]})
    to=(${(s.;.)_ZSH_AI_GRAD_STOPS[seg + 1]})
    (( r = from[1] + (to[1] - from[1]) * frac / 1000 ))
    (( g = from[2] + (to[2] - from[2]) * frac / 1000 ))
    (( b = from[3] + (to[3] - from[3]) * frac / 1000 ))
    if [[ -n $truecolor ]]; then
      _ZSH_AI_RAMP+=("fg=#${(l:2::0:)$(([##16] r))}${(l:2::0:)$(([##16] g))}${(l:2::0:)$(([##16] b))}")
    else
      _ZSH_AI_RAMP+=("fg=$(( 16 + 36 * (r * 5 / 255) + 6 * (g * 5 / 255) + b * 5 / 255 ))")
    fi
  done
}
_zsh_ai_ramp 48

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

# Resolve $ZSH_AI_PROVIDER into the command to run, leaving the argument list
# (without the prompt) in $_ZSH_AI_ARGV and the status-line label in
# $_ZSH_AI_LABEL. On failure the reason is left in $_ZSH_AI_ERROR.
_zsh_ai_resolve_provider() {
  emulate -L zsh
  local provider=$ZSH_AI_PROVIDER
  local bin=${_ZSH_AI_PROVIDER_BIN[$provider]}
  typeset -g _ZSH_AI_ERROR=
  typeset -ga _ZSH_AI_ARGV=()

  if [[ -z $bin ]]; then
    _ZSH_AI_ERROR="unknown ZSH_AI_PROVIDER '${provider}' (supported: ${(kj:, :)_ZSH_AI_PROVIDER_BIN})"
    return 1
  fi
  if (( ! $+commands[$bin] )); then
    _ZSH_AI_ERROR="${bin} not found in PATH (ZSH_AI_PROVIDER=${provider})"
    return 1
  fi

  # ZSH_AI_<PROVIDER>_{MODEL,OPTS}, e.g. ZSH_AI_CLAUDE_CODE_MODEL
  local key=${${provider:u}//-/_}
  local var=ZSH_AI_${key}_MODEL
  local model=${(P)var}
  : ${model:=${ZSH_AI_MODEL:-${_ZSH_AI_PROVIDER_MODEL[$provider]}}}

  # Split the per-provider flags the way the shell would, so quoted values
  # such as --foo='a b' survive as a single argument
  local -a opts
  var=ZSH_AI_${key}_OPTS
  [[ -n ${(P)var} ]] && opts=(${(Q)${(z)${(P)var}}})

  case $provider in
    claude-code)
      _ZSH_AI_ARGV=($bin -p)
      ;;
    kiro-cli)
      # --wrap never keeps the reply unwrapped for parsing, and --trust-tools=
      # denies every tool so an inline helper can never touch the machine
      _ZSH_AI_ARGV=($bin chat --no-interactive --wrap never --trust-tools=)
      # Inside a work tree kiro-cli snapshots the repository for its checkpoint
      # feature and tags the snapshot. With tag.gpgsign set that tag gets
      # signed, so git blocks on pinentry (and on an editor for the tag
      # message) and the request never finishes in a background job. The
      # snapshot is throwaway, so sign nothing.
      _ZSH_AI_ARGV=(env GIT_CONFIG_COUNT=2
        GIT_CONFIG_KEY_0=tag.gpgsign GIT_CONFIG_VALUE_0=false
        GIT_CONFIG_KEY_1=commit.gpgsign GIT_CONFIG_VALUE_1=false
        "${_ZSH_AI_ARGV[@]}")
      ;;
    codex)
      # `codex exec` writes only the final message to stdout (the session log
      # goes to stderr). --ephemeral skips persisting a session for a one-off
      # question, --skip-git-repo-check allows running outside a repository,
      # and the read-only sandbox keeps the agent from changing anything
      _ZSH_AI_ARGV=($bin exec --color never --ephemeral
        --skip-git-repo-check --sandbox read-only)
      ;;
  esac
  [[ -n $model ]] && _ZSH_AI_ARGV+=(--model "$model")
  _ZSH_AI_ARGV+=("${opts[@]}")

  typeset -g _ZSH_AI_LABEL=${model:-$provider}
  return 0
}

# Providers do not necessarily emit clean text when redirected: kiro-cli keeps
# colouring its reply, prefixes it with a `> ` marker and appends an OSC 9
# "response complete" notification that can land mid-stream. Drop the control
# sequences and the marker so callers get the plain answer.
_zsh_ai_clean() {
  emulate -L zsh
  setopt extended_glob
  local s=$1
  local esc=$'\e' bel=$'\a'
  s=${s//${esc}\\/$bel}                  # normalise string terminators to BEL
  s=${s//${esc}\]<->[^$bel]#${bel}/}     # OSC (notifications, title changes)
  s=${s//${esc}\[[0-9;?]#[a-zA-Z]/}      # CSI (colours, cursor movement)
  s=${s//${esc}[()][A-Za-z0-9]/}         # charset selection
  s=${s//$'\r'/}
  s=${${s##[[:space:]]##}#> }
  s=${${s##[[:space:]]##}%%[[:space:]]##}
  print -r -- "$s"
}

# Reduce a reply to the single command it was asked for: providers that lean on
# markdown wrap the answer in a fenced block even when told not to
_zsh_ai_first_command() {
  emulate -L zsh
  setopt extended_glob
  local s=$1 line
  if [[ $s == *'```'* ]]; then
    # Keep the body of the first fenced block, dropping its info string
    s=${${s#*'```'}#[^$'\n']#$'\n'}
    s=${s%%'```'*}
  fi
  for line in ${(f)s}; do
    line=${${line##[[:space:]]##}%%[[:space:]]##}
    [[ -n $line ]] && { print -r -- "$line"; return 0 }
  done
  return 1
}

# Run the configured provider in the background, animating a spinner until it
# finishes. The response is stored in $_ZSH_AI_RESPONSE; returns non-zero when
# the response is empty, 130 when cancelled with Ctrl+C, and 2 when the
# provider could not be resolved (reason in $_ZSH_AI_ERROR).
#
# The status line is rendered through $POSTDISPLAY (the mechanism
# zsh-autosuggestions uses): it is part of the editor display, so zle
# repaints it in place on every `zle -R`. Animating via `zle -M` instead
# leaves the previous frame behind as a ghost line whenever the message
# wraps or the prompt sits at the bottom of the screen.
_zsh_ai_request() {
  local prompt=$1 label=$2
  local tmp pid
  typeset -g _ZSH_AI_RESPONSE=

  _zsh_ai_resolve_provider || return 2
  tmp=$(mktemp) || return 1

  # Keep the status to one line: strip newlines here, truncate per frame
  label=${label//$'\n'/ }

  # </dev/null so a provider that appends piped stdin to the prompt (codex)
  # neither blocks nor competes with zle for the terminal
  "${_ZSH_AI_ARGV[@]}" "$prompt" </dev/null > "$tmp" 2>/dev/null &!
  pid=$!

  # On Ctrl+C, kill the request and let the loop exit on its own; the
  # normal cleanup path below restores the display
  local cancelled=0
  trap "kill $pid 2>/dev/null; cancelled=1" INT

  local saved_postdisplay=$POSTDISPLAY
  local -a saved_highlight=("${region_highlight[@]}")

  local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local -i tick=0 start=$SECONDS max k idx base
  local msg suffix
  while kill -0 $pid 2>/dev/null; do
    suffix=" [${_ZSH_AI_LABEL}, $(( SECONDS - start ))s, Ctrl+C to cancel]"
    msg="${frames[tick % $#frames + 1]} ${label}"
    # -3 leaves room for the ellipsis and double-width characters (emoji)
    max=$(( COLUMNS - $#suffix - 3 ))
    (( max > 1 && $#msg > max )) && msg="${msg[1,max]}…"
    POSTDISPLAY=$'\n'"${msg}${suffix}"
    # region_highlight offsets cover BUFFER followed by POSTDISPLAY
    region_highlight=("${saved_highlight[@]}")
    if (( $#_ZSH_AI_RAMP )); then
      # One entry per character of the message, shifted by two ramp steps per
      # frame, so the gradient travels along the text; the suffix stays plain
      base=$(( $#BUFFER + 1 ))  # +1 for the newline that opens POSTDISPLAY
      for (( k = 0; k < $#msg; k++ )); do
        (( idx = (k + tick * 2) % $#_ZSH_AI_RAMP + 1 ))
        region_highlight+=("$(( base + k )) $(( base + k + 1 )) ${_ZSH_AI_RAMP[idx]}")
      done
      region_highlight+=(
        "$(( base + $#msg )) $(( $#BUFFER + $#POSTDISPLAY )) ${ZSH_AI_STATUS_STYLE}")
    else
      region_highlight+=(
        "$#BUFFER $(( $#BUFFER + $#POSTDISPLAY )) ${ZSH_AI_STATUS_STYLE}")
    fi
    zle -R
    (( tick++ ))
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

  _ZSH_AI_RESPONSE=$(_zsh_ai_clean "$(<"$tmp")")
  command rm -f "$tmp"
  [[ -n $_ZSH_AI_RESPONSE ]]
}

# Turn the natural-language description in the buffer into a zsh command
zsh-ai-suggest() {
  [[ -z $BUFFER ]] && return 0
  local status_code
  _zsh_ai_request \
    "You are a zsh command generator. Reply with a single zsh command only: no code fences, no backticks, no explanation. Task: $BUFFER" \
    "🤖 Suggesting a command for: $BUFFER"
  status_code=$?
  if (( status_code == 0 )); then
    local cmd
    cmd=$(_zsh_ai_first_command "$_ZSH_AI_RESPONSE") || {
      zle -M "${ZSH_AI_PROVIDER} returned no usable command"
      return 0
    }
    BUFFER=$cmd
    CURSOR=$#BUFFER
    zle reset-prompt
  elif (( status_code == 2 )); then
    zle -M "$_ZSH_AI_ERROR"
  elif (( status_code != 130 )); then
    zle -M "${ZSH_AI_PROVIDER} returned no suggestion; ${_ZSH_AI_PROVIDER_HINT[$ZSH_AI_PROVIDER]:-check auth or quota}"
  fi
}

# Explain the command currently in the buffer, with leading aliases
# expanded so the LLM is told what will actually run
zsh-ai-explain() {
  [[ -z $BUFFER ]] && return 0
  local cmd status_code
  cmd=$(_zsh_ai_expand_aliases "$BUFFER")
  _zsh_ai_request \
    "Explain what this zsh command does, briefly and in plain text (no markdown): $cmd" \
    "🤖 Explaining: $cmd"
  status_code=$?
  if (( status_code == 0 )); then
    # Render the explanation below the buffer through POSTDISPLAY so it can
    # be styled with region_highlight (zle -M cannot be colored); it stays
    # visible until the next keystroke repaints the editor
    POSTDISPLAY=$'\n'"$_ZSH_AI_RESPONSE"
    region_highlight+=("$#BUFFER $(( $#BUFFER + $#POSTDISPLAY )) ${ZSH_AI_RESULT_STYLE}")
    zle -R
  elif (( status_code == 2 )); then
    zle -M "$_ZSH_AI_ERROR"
  elif (( status_code != 130 )); then
    zle -M "${ZSH_AI_PROVIDER} returned no explanation; ${_ZSH_AI_PROVIDER_HINT[$ZSH_AI_PROVIDER]:-check auth or quota}"
  fi
}

zle -N zsh-ai-suggest
zle -N zsh-ai-explain

_zsh_ai_bind_keys() {
  bindkey '«' zsh-ai-suggest  # Option+\ on macOS
  bindkey '»' zsh-ai-explain  # Option+Shift+\ on macOS
  bindkey '^[\\' zsh-ai-suggest  # Alt+\
  bindkey '^[|' zsh-ai-explain   # Alt+Shift+\
}

if (( $+functions[zvm_init] )); then
  # zsh-vi-mode rebuilds keymaps when it initializes at the first prompt,
  # which would drop bindings made here; register them to run afterwards
  zvm_after_init_commands+=(_zsh_ai_bind_keys)
else
  _zsh_ai_bind_keys
fi
