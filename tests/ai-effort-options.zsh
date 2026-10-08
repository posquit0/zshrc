#!/usr/bin/env zsh
# Run with: zsh -f tests/ai-effort-options.zsh
hash claude=/bin/sh codex=/bin/sh kiro-cli=/bin/sh
source "${0:A:h:h}/ai.zshrc"
unset ZSH_AI_MODEL ZSH_AI_CLAUDE_CODE_MODEL ZSH_AI_CODEX_MODEL ZSH_AI_KIRO_CLI_MODEL
unset ZSH_AI_CLAUDE_CODE_OPTS ZSH_AI_CODEX_OPTS ZSH_AI_KIRO_CLI_OPTS
unset ZSH_AI_EFFORT ZSH_AI_CLAUDE_CODE_EFFORT ZSH_AI_CODEX_EFFORT ZSH_AI_KIRO_CLI_EFFORT
fail() { print -u2 -r -- "FAIL: $*"; exit 1 }

check_effort() {
  _zsh_ai_resolve_provider || fail "resolution: $_ZSH_AI_ERROR"
  if [[ $ZSH_AI_PROVIDER == codex ]]; then
    [[ ${_ZSH_AI_ARGV[-2]} == -c && ${_ZSH_AI_ARGV[-1]} == "model_reasoning_effort=$1" ]] || fail 'Codex effort mapping'
  else
    [[ ${_ZSH_AI_ARGV[-2]} == --effort && ${_ZSH_AI_ARGV[-1]} == "$1" ]] || fail 'effort flag mapping'
  fi
}

for ZSH_AI_PROVIDER in claude-code codex kiro-cli; do
  key=${${ZSH_AI_PROVIDER:u}//-/_}
  effort_var=ZSH_AI_${key}_EFFORT
  opts_var=ZSH_AI_${key}_OPTS
  check_effort low
  model_index=${_ZSH_AI_ARGV[(Ie)--model]}
  [[ ${_ZSH_AI_ARGV[model_index + 1]} == ${_ZSH_AI_PROVIDER_MODEL[$ZSH_AI_PROVIDER]} ]] || fail 'default model'
  ZSH_AI_EFFORT=medium
  check_effort medium
  typeset -g "$effort_var=high"
  check_effort high
  typeset -g "$effort_var="
  check_effort medium
  ZSH_AI_EFFORT=''
  check_effort low
  for flags in '--effort high' '--effort=high'; do
    typeset -g "$opts_var=$flags"
    _zsh_ai_resolve_provider && fail 'accepted effort option'
    [[ $_ZSH_AI_ERROR == *ZSH_AI_EFFORT* ]] || fail 'missing effort hint'
  done
  unset ZSH_AI_EFFORT "$effort_var" "$opts_var"
done

ZSH_AI_PROVIDER=codex
for flags in '-c model_reasoning_effort=high' '--config=model_reasoning_effort=high' '-cmodel_reasoning_effort=high' '-c=model_reasoning_effort=high' '--config "model_reasoning_effort = \"high\""'; do
  ZSH_AI_CODEX_OPTS=$flags
  _zsh_ai_resolve_provider && fail "accepted $flags"
  [[ $_ZSH_AI_ERROR == *ZSH_AI_EFFORT* ]] || fail 'missing Codex effort hint'
done
ZSH_AI_CODEX_OPTS='--config model=other'
_zsh_ai_resolve_provider && fail 'accepted config model override'
[[ $_ZSH_AI_ERROR == *ZSH_AI_MODEL* ]] || fail 'missing model hint'
ZSH_AI_CODEX_OPTS='-c model_verbosity=low --profile "two words"'
_zsh_ai_resolve_provider || fail 'unrelated config rejected'
[[ ${_ZSH_AI_ARGV[-1]} == 'two words' ]] || fail 'quoted option changed'
print 'PASS: default models, low effort defaults/precedence, CLI mappings, option conflicts'
