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
    if has_cmd brew; then
      log_info "brew already installed"
    else
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      log_success "installed brew"
    fi
    ;;
  ubuntu|arch)
    log_info "brew is not used on this OS"
    ;;
  *) log_error "unhandled OS: $OS"; exit 1 ;;
esac
