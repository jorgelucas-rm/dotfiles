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

if has_cmd docker; then
  log_info "docker already installed"
else
  case "$OS" in
    macos) brew install --cask docker ;;
    ubuntu) curl -fsSL https://get.docker.com | sh ;;
    arch) sudo pacman -Syu --noconfirm docker docker-compose ;;
    *) log_error "unhandled OS: $OS"; exit 1 ;;
  esac
  log_success "installed docker"
fi

case "$OS" in
  ubuntu|arch)
    sudo systemctl enable --now docker
    if groups "$USER" | grep -q '\bdocker\b'; then
      log_info "$USER already in docker group"
    else
      sudo usermod -aG docker "$USER"
      log_warn "added $USER to docker group; log out and back in for this to take effect"
    fi
    ;;
  macos)
    log_info "Docker Desktop manages its own service; open the app manually the first time to start the daemon"
    ;;
esac
