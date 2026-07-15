ZSH=$HOME/.oh-my-zsh

# You can change the theme with another one from https://github.com/robbyrussell/oh-my-zsh/wiki/themes
ZSH_THEME="robbyrussell"

# Useful oh-my-zsh plugins for Le Wagon bootcamps
plugins=(git gitfast last-working-dir common-aliases zsh-syntax-highlighting history-substring-search)

# (macOS-only) Prevent Homebrew from reporting - https://github.com/Homebrew/brew/blob/master/docs/Analytics.md
export HOMEBREW_NO_ANALYTICS=1

# Disable warning about insecure completion-dependent directories
ZSH_DISABLE_COMPFIX=true

# Actually load Oh-My-Zsh
source "${ZSH}/oh-my-zsh.sh"
unalias rm # No interactive rm by default (brought by plugins/common-aliases)
unalias lt # we need `lt` for https://github.com/localtunnel/localtunnel

# Load rbenv if installed (to manage your Ruby versions)
export PATH="${HOME}/.rbenv/bin:${PATH}" # Needed for Linux/WSL
type -a rbenv > /dev/null && eval "$(rbenv init -)"

# Load pyenv (to manage your Python versions)
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
type -a pyenv > /dev/null && eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init - 2> /dev/null)" && RPROMPT+='[🐍 $(pyenv version-name)]'

# Load nvm (to manage your node versions)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Call `nvm use` automatically in a directory with a `.nvmrc` file
autoload -U add-zsh-hook
load-nvmrc() {
  if nvm -v &> /dev/null; then
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"

    if [ -n "$nvmrc_path" ]; then
      local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

      if [ "$nvmrc_node_version" = "N/A" ]; then
        nvm install
      elif [ "$nvmrc_node_version" != "$node_version" ]; then
        nvm use --silent
      fi
    elif [ "$node_version" != "$(nvm version default)" ]; then
      nvm use default --silent
    fi
  fi
}
type -a nvm > /dev/null && add-zsh-hook chpwd load-nvmrc
type -a nvm > /dev/null && load-nvmrc

# Rails and Ruby uses the local `bin` folder to store binstubs.
# So instead of running `bin/rails` like the doc says, just run `rails`
# Same for `./node_modules/.bin` and nodejs
export PATH="./bin:./node_modules/.bin:${PATH}:/usr/local/sbin"

# Store your own aliases in the ~/.aliases file and load the here.
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Encoding stuff for the terminal
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export BUNDLER_EDITOR=code
export EDITOR=code

# Set ipdb as the default Python debugger
export PYTHONBREAKPOINT=ipdb.set_trace
# direnv: load per-project env from each project's .envrc (no global PYTHONPATH hacks)
eval "$(direnv hook zsh)"

# Apple-Silicon Homebrew + user-local binaries on PATH
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"

# Google Cloud service-account credentials
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/code/gcp/beaming-droplet-465911-a1-8100db634399.json"

# Secrets (API keys) live in ~/.secrets — gitignored, never committed.
[[ -f "$HOME/.secrets" ]] && source "$HOME/.secrets"

# fnm (Node version manager): auto-switch to the .nvmrc / .node-version
# version on `cd`. Placed last so its chpwd hook registers after nvm's and
# wins on PATH (this repo pins Node 22 via .nvmrc).
eval "$(fnm env --use-on-cd)"

# open a markdown file in Obsidian (file must be inside a registered vault)
omd() {
  [ -z "$1" ] && { echo "usage: omd <file.md>"; return 1; }
  open "obsidian://open?path=$(python3 -c 'import urllib.parse,sys,os;print(urllib.parse.quote(os.path.abspath(sys.argv[1])))' "$1")"
}

# Starship prompt — initialized after oh-my-zsh so it overrides the theme (added 2026-06-15).
# Config: ~/.config/starship.toml. Starship's python module replaces the old pyenv RPROMPT.
eval "$(starship init zsh)"

# GitHub MCP server token — pulled from the gh CLI keychain (added 2026-06-15)
export GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token)"
# ANTHROPIC_API_KEY export removed 2026-07-15 — Claude Code uses the subscription login.
