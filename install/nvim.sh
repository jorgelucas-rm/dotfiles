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

nvim_need_install=1
if has_cmd nvim; then
  nvim_have="$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9.]+).*/\1/')"
  if printf '%s\n0.11.2\n' "$nvim_have" | sort -V -C; then
    log_warn "neovim $nvim_have is older than LazyVim's minimum 0.11.2; upgrading"
  else
    log_info "neovim already installed ($nvim_have)"
    nvim_need_install=0
  fi
fi

if [[ "$nvim_need_install" -eq 1 ]]; then
  case "$OS" in
    macos) nvim_os="macos" ;;
    ubuntu|arch) nvim_os="linux" ;;
    *) log_error "unhandled OS: $OS"; exit 1 ;;
  esac

  nvim_cpu="$(uname -m)"
  case "$nvim_cpu" in
    x86_64) nvim_arch="x86_64" ;;
    aarch64|arm64) nvim_arch="arm64" ;;
    *) log_error "unsupported architecture: $nvim_cpu"; exit 1 ;;
  esac

  nvim_json="$(curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/latest")"
  nvim_url="$(select_release_asset "$nvim_json" "nvim-${nvim_os}-${nvim_arch}\.tar\.gz$")"
  if [[ -z "$nvim_url" ]]; then
    log_error "no neovim release asset found for ${nvim_os}-${nvim_arch}"
    exit 1
  fi

  nvim_tmp_dir="$(mktemp -d)"
  curl -fsSL "$nvim_url" -o "$nvim_tmp_dir/nvim.tar.gz"
  sudo mkdir -p /opt /usr/local/bin
  sudo rm -rf "/opt/nvim-${nvim_os}-${nvim_arch}"
  sudo tar -xzf "$nvim_tmp_dir/nvim.tar.gz" -C /opt
  [[ -x "/opt/nvim-${nvim_os}-${nvim_arch}/bin/nvim" ]] || { log_error "extracted tree missing bin/nvim"; exit 1; }
  sudo ln -sf "/opt/nvim-${nvim_os}-${nvim_arch}/bin/nvim" /usr/local/bin/nvim
  rm -rf "$nvim_tmp_dir"
  log_success "installed neovim"
fi

if has_cmd rg; then
  log_info "ripgrep already installed"
else
  case "$OS" in
    macos) brew install ripgrep ;;
    ubuntu)
      sudo apt-get update -y
      sudo apt-get install -y ripgrep
      ;;
    arch) sudo pacman -Syu --noconfirm ripgrep ;;
    *) log_error "unhandled OS: $OS"; exit 1 ;;
  esac
  log_success "installed ripgrep"
fi

if has_cmd fd; then
  log_info "fd already installed"
else
  case "$OS" in
    macos) brew install fd ;;
    ubuntu)
      sudo apt-get update -y
      sudo apt-get install -y fd-find
      fd_bin="$(command -v fdfind || true)"
      if [[ -z "$fd_bin" ]]; then
        log_error "fd-find installed but fdfind not found on PATH"
        exit 1
      fi
      sudo ln -sf "$fd_bin" /usr/local/bin/fd
      ;;
    arch) sudo pacman -Syu --noconfirm fd ;;
    *) log_error "unhandled OS: $OS"; exit 1 ;;
  esac
  log_success "installed fd"
fi

c_compiler_present=0
if [[ "$OS" == "macos" ]]; then
  xcode-select -p >/dev/null 2>&1 && c_compiler_present=1
else
  { has_cmd cc || has_cmd gcc || has_cmd clang; } && c_compiler_present=1
fi

if [[ "$c_compiler_present" -eq 1 ]]; then
  log_info "C compiler already installed"
else
  case "$OS" in
    macos)
      xcode-select --install || true
      log_warn "Xcode Command Line Tools install started in the background; wait for it to finish before using LazyVim"
      ;;
    ubuntu)
      sudo apt-get update -y
      sudo apt-get install -y build-essential
      ;;
    arch) sudo pacman -Syu --noconfirm base-devel ;;
    *) log_error "unhandled OS: $OS"; exit 1 ;;
  esac
  log_success "installed C compiler toolchain"
fi

NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [[ -d "$NVIM_CONFIG_DIR" ]]; then
  log_info "nvim config already present at $NVIM_CONFIG_DIR"
else
  git clone --depth=1 https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
  rm -rf "$NVIM_CONFIG_DIR/.git"
  log_success "installed LazyVim starter config"
fi
