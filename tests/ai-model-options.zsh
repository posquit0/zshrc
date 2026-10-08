#!/usr/bin/env zsh
# Run with: zsh -f tests/ai-model-options.zsh
hash claude=/bin/sh codex=/bin/sh kiro-cli=/bin/sh
source "${0:A:h:h}/ai.zshrc"
unset ZSH_AI_MODEL ZSH_AI_CLAUDE_CODE_MODEL ZSH_AI_CODEX_MODEL ZSH_AI_KIRO_CLI_MODEL
unset ZSH_AI_CLAUDE_CODE_OPTS ZSH_AI_CODEX_OPTS ZSH_AI_KIRO_CLI_OPTS
unset ZSH_AI_EFFORT ZSH_AI_CLAUDE_CODE_EFFORT ZSH_AI_CODEX_EFFORT ZSH_AI_KIRO_CLI_EFFORT
fail() { print -u2 -r -- "FAIL: $*"; exit 1 }

for ZSH_AI_PROVIDER in claude-code codex kiro-cli; do
  key=${${ZSH_AI_PROVIDER:u}//-/_}
  model_var=ZSH_AI_${key}_MODEL
  opts_var=ZSH_AI_${key}_OPTS
  ZSH_AI_MODEL=shared-model
  _zsh_ai_resolve_provider || fail 'shared model rejected'
  [[ $_ZSH_AI_LABEL == shared-model && ${_ZSH_AI_ARGV[-1]} == shared-model ]] || fail 'shared model not applied'

  typeset -g "$model_var=provider-model"
  typeset -g "$opts_var=--agent 'two words'"
  _zsh_ai_resolve_provider || fail 'normal options rejected'
  [[ $_ZSH_AI_LABEL == provider-model && ${_ZSH_AI_ARGV[-1]} == 'two words' ]] || fail 'priority or quoting changed'

  for flags in '--model other' '--model=other' '-m other' '-mother' '-m=other'; do
    typeset -g "$opts_var=$flags"
    _zsh_ai_resolve_provider && fail "accepted $flags for $ZSH_AI_PROVIDER"
    [[ $_ZSH_AI_ERROR == *ZSH_AI_MODEL* && $_ZSH_AI_ERROR == *$opts_var* ]] || fail 'missing configuration hint'
    (( $#_ZSH_AI_ARGV == 0 )) || fail 'failed resolution left a runnable command'
  done
  unset "$model_var" "$opts_var"
done
print 'PASS: all providers, model precedence, quoted options, conflicting flags'
