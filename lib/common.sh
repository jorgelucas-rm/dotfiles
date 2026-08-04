#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

has_cmd()  { command -v "$1" >/dev/null 2>&1; }

link() {
  local src="$1" dest="$2"

  if [[ ! -e "$src" ]]; then
    log_error "link source does not exist: $src"
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    log_info "already linked: $dest"
    return 0
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    local backup="${dest}.bak"
    log_warn "backing up existing $dest to $backup"
    rm -rf "$backup"
    mv "$dest" "$backup"
  fi

  ln -s "$src" "$dest"
  log_success "linked $dest -> $src"
}

select_release_asset() {
  local json="$1" pattern="$2"
  echo "$json" \
    | grep -Eo '"browser_download_url"[[:space:]]*:[[:space:]]*"[^"]+"' \
    | sed -E 's/.*"(https:[^"]+)"/\1/' \
    | grep -E "$pattern" \
    | head -n1 || true
}

install_from_github_release() {
  local repo="$1" asset_pattern="$2" binary_name="$3"
  local json
  json="$(curl -fsSL "https://api.github.com/repos/${repo}/releases/latest")"

  local url
  url="$(select_release_asset "$json" "$asset_pattern")"
  if [[ -z "$url" ]]; then
    log_error "no release asset matching '$asset_pattern' found for $repo"
    return 1
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local archive="$tmp_dir/asset"
  curl -fsSL "$url" -o "$archive"

  if [[ "$url" == *.tar.gz ]]; then
    tar -xzf "$archive" -C "$tmp_dir" "$binary_name"
  else
    mv "$archive" "$tmp_dir/$binary_name"
  fi

  chmod +x "$tmp_dir/$binary_name"
  sudo install -m 755 "$tmp_dir/$binary_name" "/usr/local/bin/$binary_name"
  rm -rf "$tmp_dir"
  log_success "installed $binary_name to /usr/local/bin"
}
