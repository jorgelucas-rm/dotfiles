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

if has_cmd lazydocker; then
  log_info "lazydocker already installed"
  exit 0
fi

case "$OS" in
  macos)
    brew install lazydocker
    ;;
  ubuntu|arch)
    curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    ;;
esac

log_success "installed lazydocker"
