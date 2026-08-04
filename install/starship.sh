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

if has_cmd starship; then
  log_info "starship already installed"
  exit 0
fi

curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
log_success "installed starship"
