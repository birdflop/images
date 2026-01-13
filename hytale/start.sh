#!/bin/bash
set -euo pipefail

cd /home/container || exit 1

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
fail() { echo "[ERROR] $*" >&2; exit 1; }

# Configuration with sane defaults
SERVER_PORT=${SERVER_PORT:-5520}
AUTH_MODE=${AUTH_MODE:-authenticated}
ASSETS_PATH=${ASSETS_PATH:-Assets.zip}
NETTY_DISABLE_NATIVE=${NETTY_DISABLE_NATIVE:-true}

JAVA_PROPS=()
JAVA_ARGS=()

[ "${NETTY_DISABLE_NATIVE}" = "true" ] && JAVA_PROPS+=(-Dio.netty.transport.noNative=true)
[ "${ACCEPT_EARLY_PLUGINS:-false}" = "true" ] && JAVA_ARGS+=(--accept-early-plugins)
[ "${ALLOW_OP:-false}" = "true" ] && JAVA_ARGS+=(--allow-op)

require_tool() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required tool: $1"
}

download_downloader() {
  require_tool curl
  require_tool unzip

  if [ -x hytale-downloader ]; then
    return
  fi

  info "Fetching hytale-downloader..."
  tmp_zip=$(mktemp -p . hytale-dl.XXXX.zip)
  curl -fL --retry 3 --retry-delay 2 -o "$tmp_zip" https://downloader.hytale.com/hytale-downloader.zip
  unzip -oq "$tmp_zip"
  rm -f "$tmp_zip" QUICKSTART.md hytale-downloader-windows-amd64.exe
  mv hytale-downloader-linux-amd64 hytale-downloader
  chmod +x hytale-downloader
}

download_server() {
  if [ -f Server/HytaleServer.jar ]; then
    return
  fi

  if [ ! -f .hytale-downloader-credentials.json ]; then
    warn "Server not installed; OAuth device login required."
    warn "When prompted: open the URL, enter the device code, finish login in the browser."
    warn "Do not restart until authentication completes."
  else
    info "Server files missing; re-downloading."
  fi

  ./hytale-downloader --skip-update-check || true
}

find_patch_zip() {
  find . -maxdepth 1 -type f -name '*.zip' ! -name "$(basename "$ASSETS_PATH")" | head -n1
}

extract_server() {
  if [ -f Server/HytaleServer.jar ]; then
    return
  fi

  patch_zip=$(find_patch_zip)
  [ -n "$patch_zip" ] || fail "No patch ZIP found after download."

  info "Extracting server files from ${patch_zip#./}"
  unzip -oq "$patch_zip"
}

sanity_checks() {
  [ -f Server/HytaleServer.jar ] || fail "Server/HytaleServer.jar not found after extraction."
  [ -f "$ASSETS_PATH" ] || fail "Assets archive missing: $ASSETS_PATH"
  [ -n "${SERVER_MEMORY:-}" ] || fail "SERVER_MEMORY is not set by the panel."
}

start_server() {
  info "Starting Hytale server on 0.0.0.0:${SERVER_PORT} (auth: ${AUTH_MODE})"
  exec java \
    "${JAVA_PROPS[@]}" \
    -Xms128M \
    -Xmx"${SERVER_MEMORY}"M \
    -jar Server/HytaleServer.jar \
    --assets "${ASSETS_PATH}" \
    --auth-mode "${AUTH_MODE}" \
    --bind "0.0.0.0:${SERVER_PORT}" \
    "${JAVA_ARGS[@]}"
}

# Main flow
download_downloader
info "Hytale Downloader: $(./hytale-downloader -version 2>/dev/null || echo unknown)"

download_server
extract_server
sanity_checks
start_server
