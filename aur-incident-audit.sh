#!/usr/bin/env bash
set -euo pipefail

AFFECTED_URL="https://md.archlinux.org/s/SxbqukK6IA/download"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

affected_raw="$TMPDIR/aur-affected.md"
affected_pkgs="$TMPDIR/aur-affected.txt"
installed_aur="$TMPDIR/installed-aur.txt"

echo "== AUR incident audit =="
echo

if ! command -v pacman >/dev/null; then
  echo "This script is intended for Arch-based systems with pacman."
  exit 1
fi

echo "[1/5] Collecting installed AUR packages..."
pacman -Qqm | sort -u > "$installed_aur" || true

echo "[2/5] Downloading affected package list..."
if command -v curl >/dev/null; then
  curl -fsSL "$AFFECTED_URL" -o "$affected_raw"
elif command -v wget >/dev/null; then
  wget -qO "$affected_raw" "$AFFECTED_URL"
else
  echo "Need curl or wget."
  exit 1
fi

echo "[3/5] Parsing affected package names..."
grep -Eo '`?[A-Za-z0-9@._+-]+`?' "$affected_raw" \
  | tr -d '`' \
  | grep -Ev '^(http|https|aur|pkgbuild|package|packages|npm|js|com|org|net)$' \
  | sort -u > "$affected_pkgs"

echo "[4/5] Comparing with installed AUR packages..."
matches="$(comm -12 "$installed_aur" "$affected_pkgs" || true)"

if [[ -n "$matches" ]]; then
  echo
  echo "WARNING: Installed AUR packages matching the affected list:"
  echo "$matches"
  echo
  echo "Suggested manual review:"
  echo "  pacman -Qi <package>"
  echo "  paru -G <package>   # or yay -G <package>"
  echo "  sudo pacman -Rns <package>   # only if you decide to remove it"
else
  echo "No installed AUR packages matched the downloaded affected list."
fi

echo
echo "[5/5] Scanning common AUR helper caches for known malicious npm deps..."
grep -RniE 'atomic-lockfile|js-digest|lockfile-js' \
  "$HOME/.cache/yay" \
  "$HOME/.cache/paru" \
  "$HOME/.cache/pikaur" \
  "$HOME/.cache/aura" \
  2>/dev/null || true

echo
echo "Recent AUR/pacman activity around June 9–12, 2026:"
grep -E '2026-06-(09|10|11|12).*(installed|upgraded)' /var/log/pacman.log 2>/dev/null || \
  echo "No matching pacman log entries found."

echo
echo "Done."
echo "If there were no package matches and no cache grep hits, you are likely unaffected."

