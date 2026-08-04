#!/usr/bin/env bash
set -uo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/lib/common.sh"

OS="${1:-}"
case "$OS" in
  ubuntu|arch|macos) ;;
  *)
    echo "Usage: $0 <ubuntu|arch|macos>" >&2
    exit 1
    ;;
esac

case "$OS" in
  ubuntu) has_cmd apt-get || { log_error "apt-get is required for ubuntu but not found."; exit 1; } ;;
  arch)   has_cmd pacman  || { log_error "pacman is required for arch but not found."; exit 1; } ;;
esac

if ! has_cmd git; then
  log_error "git is required but not found. Please install git and re-run this script."
  exit 1
fi

if ! has_cmd curl; then
  log_error "curl is required but not found. Please install curl and re-run this script."
  exit 1
fi

INSTALLERS=(
  brew
  zsh_plugins
  thefuck
  asdf
  starship
  ghostty
  herdr
  lazygit
  lazydocker
  docker
  nvim
)

OK_TOOLS=()
FAILED_TOOLS=()

for name in "${INSTALLERS[@]}"; do
  log_info "=== $name ==="
  if "$REPO_DIR/install/${name}.sh" "$OS"; then
    OK_TOOLS+=("$name")
    if [[ "$name" == "brew" && "$OS" == "macos" ]]; then
      export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    fi
  else
    log_error "install/${name}.sh failed"
    FAILED_TOOLS+=("$name")
  fi
done

log_info "=== linking dotfiles ==="

do_link() {
  local src="$1" dest="$2"
  if link "$src" "$dest"; then
    OK_TOOLS+=("link:$dest")
  else
    FAILED_TOOLS+=("link:$dest")
  fi
}

do_link "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc"
do_link "$REPO_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
do_link "$REPO_DIR/ghostty/config" "$HOME/.config/ghostty/config"
do_link "$REPO_DIR/herdr/config.toml" "$HOME/.config/herdr/config.toml"

echo
log_info "=== summary ==="
log_success "ok: ${OK_TOOLS[*]:-none}"
if [[ ${#FAILED_TOOLS[@]} -gt 0 ]]; then
  log_error "failed: ${FAILED_TOOLS[*]}"
  exit 1
fi

log_success "setup complete"
