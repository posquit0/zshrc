# vi: filetype=zsh
# .zshenv
#
# Maintained by Byungjin Park <posquit0.bj@gmail.com>
# https://www.posquit0.com/


# To make it work on Ubuntu
export DEBIAN_PREVENT_KEYBOARD_CHANGES=yes

# Use ~/.config directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Authenticate chezmoi's GitHub API template functions (e.g. gitHubLatestReleaseAssetURL)
# so `chezmoi apply` isn't throttled by the unauthenticated 60 req/hour limit. The token is pulled from the gh CLI
if [[ -z "$CHEZMOI_GITHUB_ACCESS_TOKEN" ]] && command -v gh >/dev/null 2>&1; then
  export CHEZMOI_GITHUB_ACCESS_TOKEN="$(gh auth token 2>/dev/null)"
fi

if [[ -z "$GITHUB_TOKEN" ]] && command -v gh >/dev/null 2>&1; then
  export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"
fi
