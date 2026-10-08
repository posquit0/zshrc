<img src="https://raw.githubusercontent.com/posquit0/zshrc/main/icon.png?v=3&s=200" align="left" width="128px" height="128px"/>

### Zshrc by posquit0
> *Zsh Configuration for nerds written by posquit0*

[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)
[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badge/)


[**This Zsh configuration**](https://github.com/posquit0/zshrc) is written by [posquit0](https://github.com/posquit0/) to improve the environment in Zshell.

- If you want to override my configuration or add more configuration, just create `~/.zshrc.local` and write your configurations for zsh.


## Getting Started

```sh
$ cd ~
$ git clone --recursive https://github.com/posquit0/zshrc ~/.zsh

$ ln -s .zsh/zshrc .zshrc
$ ln -s .zsh/zshenv .zshenv
```


## Inline AI helpers

Use `Alt+\\` to generate a command from the current input and `Alt+Shift+\\` to
explain a command. On macOS, the corresponding bindings are `Option+\\` and
`Option+Shift+\\`. Suggestions replace the input buffer; they are not executed.

Configure the helpers in `~/.zshrc.local`. `ZSH_AI_PROVIDER` selects
`claude-code` (the default), `codex`, or `kiro-cli`. All three use the same
`ZSH_AI_MODEL` variable, which passes the selected CLI's model ID as `--model`:

```zsh
# Claude Code: pin a version instead of following the haiku alias
export ZSH_AI_PROVIDER=claude-code
export ZSH_AI_MODEL=claude-haiku-5-5
# To use Haiku 4.5 instead:
# export ZSH_AI_MODEL=claude-haiku-4-5-20251001
```

Alternative provider/model pairs (choose one):

```zsh
export ZSH_AI_PROVIDER=codex
export ZSH_AI_MODEL=gpt-6.1-sol

# Or use a model available through Kiro:
export ZSH_AI_PROVIDER=kiro-cli
export ZSH_AI_MODEL=claude-sonnet-5.5
```

Model IDs and availability belong to each CLI/account; the helpers do not
translate names between providers. In particular, Claude Code uses hyphens
in `claude-haiku-5-5`, while Kiro uses IDs such as `claude-sonnet-5.5`.
Check the CLI's model picker (or `kiro-cli chat --list-models`) for availability.

The first non-empty value wins:

1. `ZSH_AI_CLAUDE_CODE_MODEL`, `ZSH_AI_CODEX_MODEL`, or `ZSH_AI_KIRO_CLI_MODEL`
   for the selected provider.
2. `ZSH_AI_MODEL`.
3. The helper's built-in default for that provider:

| Provider | Default model |
| --- | --- |
| `claude-code` | `claude-haiku-5-5` |
| `codex` | `gpt-6.1-sol` |
| `kiro-cli` | `claude-sonnet-5.5` |

Unset a provider-specific override to control that provider through the shared
variable. An empty string falls through to the next level; it does not disable
the built-in model default. These values are resolved on every request.
The loading label shows the requested model ID/alias, or the provider name
when `--model` is omitted; it does not report the server's resolved model.

The built-in defaults pin model versions. You can still choose an alias such
as `haiku`, which Claude Code resolves using its provider and any
`ANTHROPIC_DEFAULT_HAIKU_MODEL` override. The helper's explicit `--model` takes
precedence over normal CLI model preferences, including Kiro agent models.
See the official [Claude model configuration](https://code.claude.com/docs/en/model-config),
[Codex models](https://learn.chatgpt.com/docs/models?surface=cli), and
[Kiro headless model selection](https://kiro.dev/docs/cli/headless/#agent-selection).

Use `ZSH_AI_CLAUDE_CODE_OPTS`, `ZSH_AI_CODEX_OPTS`, or `ZSH_AI_KIRO_CLI_OPTS`
for additional CLI options, with quoted values preserved. Direct `--model`,
`-m`, and `--effort` options are rejected here, as are Codex `-c`/`--config`
assignments to `model` or `model_reasoning_effort`. Use the dedicated variables
so flags cannot conflict with the selected settings.

### Reasoning effort

All three CLIs support effort controls, but supported levels depend on the
selected model and CLI version. The helpers pass the value through to the CLI;
they do not translate levels or maintain a separate list of supported models.
Typical levels are `low`, `medium`, `high`, `xhigh`, and `max`; check your CLI's
model settings before using a level with a different model.

```zsh
# Prefer quick responses from all providers
export ZSH_AI_EFFORT=low
# Override just one provider when needed
export ZSH_AI_CODEX_EFFORT=medium
```

The first non-empty value wins: `ZSH_AI_CLAUDE_CODE_EFFORT`,
`ZSH_AI_CODEX_EFFORT`, or `ZSH_AI_KIRO_CLI_EFFORT` for the selected provider,
then `ZSH_AI_EFFORT`. If both are empty, no effort option is passed and the
CLI's existing setting applies. Changing the model alone does not force a
lower effort setting.

Claude Code and Kiro receive `--effort <value>`. Codex receives
`-c model_reasoning_effort=<value>`. Replace older configurations such as
`ZSH_AI_CODEX_OPTS='-c model_reasoning_effort=low'` with
`ZSH_AI_CODEX_EFFORT=low`. See [Codex configuration](https://learn.chatgpt.com/docs/developer-settings),
[Claude effort](https://code.claude.com/docs/en/model-config#adjust-effort-level),
and [Kiro headless options](https://kiro.dev/docs/cli/headless/#agent-selection).

The `ai-commit-msg` script in the chezmoi dotfiles uses the same model defaults,
model/effort precedence, and extra-option rules. The shell exports the shared
`ZSH_AI_PROVIDER`, `ZSH_AI_MODEL`, and `ZSH_AI_EFFORT` variables. Export any
provider-specific overrides yourself so child processes see them too.


## Contributing

This project follows the [**Contributor Covenant**](http://contributor-covenant.org/version/1/4/) Code of Conduct.

#### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/posquit0/zshrc/issues) to report any bugs or ask feature requests.


## Self Promotion

Like this project? Please give it a ★  on [GitHub](https://github.com/posquit0/zshrc)! It helps this project **a lot**.
And if you're feeling especially charitable, follow [posquit0](https://posquit0.com) on [GitHub](https://github.com/posquit0).


## See Also

- [brewfile](https://github.com/posquit0/brewfile) - Brewfile to install softwares in macOS for engineers.
- [dotfiles](https://github.com/posquit0/dotfiles) - Awesome configurations for the development environments.
- [gitconfig](https://github.com/posquit0/gitconfig) - Git configurations.
- [vimrc](https://github.com/posquit0/vimrc) - Vim Configuration for nerds with vim-plug.
- [tmux-conf](https://github.com/posquit0/tmux-conf) - TMUX Configuration for nerds with tpm.


## License

Provided under the terms of the [MIT License](https://github.com/posquit0/zshrc/blob/main/LICENSE).

Copyright © 2014-2026, [Byungjin Park](https://www.posquit0.com).
