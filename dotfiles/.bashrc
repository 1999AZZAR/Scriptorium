#!/usr/bin/env bash
# ~/.bashrc: executed by bash for non-login shells

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# ===== ENVIRONMENT VARIABLES =====
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

export OSH='/usr/local/share/oh-my-bash'
export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS}"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# ===== SHELL OPTIONS =====
export HISTSIZE=5000
export HISTFILESIZE=10000
export HISTCONTROL=ignoreboth

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

# ===== SAFE PATH CLEANUP =====
cleaned_path=""
seen=""
IFS=':'
for p in $PATH; do
  if [[ -n "$p" && ! "$seen" =~ (^|:)$p(:|$) ]]; then
    cleaned_path+="$p:"
    seen+="$p:"
  fi
done
unset IFS
export PATH="${cleaned_path%:}"

# ===== OH-MY-BASH CONFIGURATION =====
OSH_THEME="font"
DISABLE_AUTO_UPDATE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
OMB_PROMPT_SHOW_PYTHON_VENV="true"

# Only source if oh-my-bash exists
if [ -f "$OSH/oh-my-bash.sh" ]; then
  completions=(git composer ssh pip)
  aliases=(general debian misc)
  plugins=()
  source "$OSH/oh-my-bash.sh"
fi

# ===== SERVICE SHORTCUTS =====
alias portguard='echo "[*] Dynamic Port Guard Status:"; sudo systemctl status dynamic-port-guard --no-pager; echo; sudo systemctl status dynamic-port-webui --no-pager; echo; echo "[*] Opening Web UI..."; xdg-open http://localhost:6060 &>/dev/null &'
alias webterm='web_terminal'
alias servicemanager='xdg-open http://localhost:5001 &> /dev/null'
alias cdns=/usr/local/bin/doh-switcher-core
alias scrcpy2="./Documents/script/android\ scripting/scrcpy-scripts/virtual_display.sh"
alias tail-u="sudo systemctl start tailscale-receiver.service"
alias tail-d="sudo systemctl stop tailscale-receiver.service"
alias tail-s="sudo systemctl status tailscale-receiver.service"
alias tail-r="sudo systemctl restart tailscale-receiver.service"

# ===== CUSTOM ALIASES + AUTOCOMPLETE =====
ALIASES_DIR="$HOME/alias-hub"
if [ -d "$ALIASES_DIR" ]; then
  source "$ALIASES_DIR/script/helpers.sh" 2>/dev/null || true
  for file in "$ALIASES_DIR"/*.alias; do
    [ -f "$file" ] && source "$file"
  done

  _alias_list_completions() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local matches=$(compgen -W "$(ls -1 "$ALIASES_DIR" | grep -i "^$current_word" | grep '\.alias$' | sed 's/\.alias$//')" -- "$current_word")
    COMPREPLY=($matches)
  }
  complete -F _alias_list_completions alias-list
fi

export GOOGLE_API_KEY="AIzaSyDaqpk9CbU96YiAeSa1kYJLP-vI4gUgFYw"
. "$HOME/.cargo/env"
export PATH=$PATH:/usr/local/go/bin
export PATH="$HOME/.local/bin:$PATH"
