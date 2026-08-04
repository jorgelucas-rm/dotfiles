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

case "$OS" in
  macos)
    if has_cmd ghostty; then
      log_info "ghostty already installed"
    else
      brew install --cask ghostty
      log_success "installed ghostty"
    fi
    ;;
  ubuntu|arch)
    log_info "ghostty is not auto-installed on Linux; only its config will be linked"
    mkdir -p "$HOME/.config/ghostty"
    ;;
esac
