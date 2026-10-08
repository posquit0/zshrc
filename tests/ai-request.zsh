#!/usr/bin/env zsh
# Run with: zsh -f tests/ai-request.zsh
hash claude=/bin/sh
source "${0:A:h:h}/ai.zshrc"

test_tmp=$(mktemp -d)
trap 'command rm -rf -- "$test_tmp"' EXIT
export TMPDIR=$test_tmp
COLUMNS=100
ZSH_AI_PROVIDER=claude-code
ZSH_AI_STATUS_GRADIENT=0

fail() { print -u2 -r -- "FAIL: $*"; exit 1 }
zle() {
  [[ $1 == -M ]] && last_message=$2
  if [[ $1 == -R && $cancel_next == 1 ]]; then
    cancel_next=0
    kill -INT $$
  fi
  return 0
}
_zsh_ai_resolve_provider() {
  _ZSH_AI_ERROR=
  _ZSH_AI_LABEL=mock
  _ZSH_AI_ARGV=(/bin/sh -c "$mock_script")
}
cancel_next=0
saved_monitor=$options[monitor]

mock_script='printf "answer\n"; printf "diagnostic\n" >&2'
_zsh_ai_request prompt label || fail 'successful response rejected'
[[ $_ZSH_AI_RESPONSE == answer ]] || fail 'stderr leaked into answer'
[[ $options[monitor] == $saved_monitor ]] || fail 'job-control option leaked'

mock_script='printf "ERROR: unsupported model\n"; printf "model unavailable\n" >&2; exit 42'
_zsh_ai_request prompt label
[[ $? == 2 && -z $_ZSH_AI_RESPONSE ]] || fail 'failed stdout accepted'
[[ $_ZSH_AI_ERROR == *'status 42: model unavailable' ]] || fail 'missing exit status/stderr'
BUFFER='original task'
zsh-ai-suggest
[[ $BUFFER == 'original task' && $last_message == "$_ZSH_AI_ERROR" ]] || fail 'failure replaced buffer'

mock_script='printf "auth failed\n" >&2; exit 1'
_zsh_ai_request prompt label
[[ $? == 2 && $_ZSH_AI_ERROR == *'status 1: auth failed' ]] || fail 'stderr-only failure lost'

mock_script='exit 7'
_zsh_ai_request prompt label
[[ $? == 2 && $_ZSH_AI_ERROR == *'status 7' ]] || fail 'silent failure lost'

mock_script='exit 0'
_zsh_ai_request prompt label
[[ $? == 1 && -z $_ZSH_AI_RESPONSE ]] || fail 'empty answer accepted'

mock_script='sleep 0.1; printf "delayed\n"'
_zsh_ai_request prompt label || fail 'delayed response rejected'
[[ $_ZSH_AI_RESPONSE == delayed && -z $_ZSH_AI_ERROR ]] || fail 'stale error retained'

mock_script='exec sleep 10'
cancel_next=1
_zsh_ai_request prompt label
[[ $? == 130 && -z $_ZSH_AI_RESPONSE ]] || fail 'cancellation failed'
[[ $last_message == cancelled ]] || fail 'cancellation message lost'
leftovers=("$test_tmp"/*(N))
(( $#leftovers == 0 )) || fail 'temporary files leaked'
print 'PASS: request success, errors, buffer preservation, cancellation, cleanup'
