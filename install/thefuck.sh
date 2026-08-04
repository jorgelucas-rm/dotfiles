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

if has_cmd thefuck; then
  log_info "thefuck already installed"
  exit 0
fi

case "$OS" in
  macos) brew install thefuck ;;
  ubuntu)
    sudo apt-get update -y
    sudo apt-get install -y thefuck
    ;;
  arch) sudo pacman -Syu --noconfirm thefuck ;;
  *) log_error "unhandled OS: $OS"; exit 1 ;;
esac

log_success "installed thefuck"
