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

if has_cmd lazygit; then
  log_info "lazygit already installed"
  exit 0
fi

case "$OS" in
  macos)
    brew install lazygit
    ;;
  ubuntu|arch)
    arch="$(uname -m)"
    case "$arch" in
      x86_64) asset_arch="x86_64" ;;
      aarch64|arm64) asset_arch="arm64" ;;
      *) log_error "unsupported architecture: $arch"; exit 1 ;;
    esac
    install_from_github_release "jesseduffield/lazygit" "linux_${asset_arch}\.tar\.gz$" "lazygit"
    ;;
esac

log_success "installed lazygit"
