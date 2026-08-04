#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

OS="${1:-}"
case "$OS" in
  ubuntu|arch|macos) ;;
  *)
    echo "Usage: $0 <ubuntu|arch|macos>" >&2
    exit 1
    ;;
esac

if has_cmd zsh; then
  log_info "zsh already installed"
else
  case "$OS" in
    macos) brew install zsh ;;
    ubuntu)
      sudo apt-get update -y
      sudo apt-get install -y zsh
      ;;
    arch) sudo pacman -Syu --noconfirm zsh ;;
    *) log_error "unhandled OS: $OS"; exit 1 ;;
  esac
  log_success "installed zsh"
fi

OMZ_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OMZ_DIR/custom}"

if [[ -d "$OMZ_DIR" ]]; then
  log_info "oh-my-zsh already installed"
else
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log_success "installed oh-my-zsh"
fi

clone_plugin() {
  local name="$1" repo_url="$2"
  local target="$ZSH_CUSTOM_DIR/plugins/$name"
  if [[ -d "$target" ]]; then
    log_info "plugin already present: $name"
  else
    git clone --depth=1 "$repo_url" "$target"
    log_success "installed plugin: $name"
  fi
}

clone_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
clone_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
clone_plugin "zsh-transient-prompt" "https://github.com/jorgelucas-rm/zsh-transient-prompt"
