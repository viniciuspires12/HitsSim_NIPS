#!/usr/bin/env bash
set -euo pipefail
REPO_SSH="${REPO_SSH:-git@github.com-vini:viniciuspires12/HitsSim_NIPS.git}"
REPO_DIR="${REPO_DIR:-$HOME/HitsSim_NIPS}"
BRANCH="${BRANCH:-main}"
DEST_SUBPATH="${2:-HPS_FPGA_Simulador_v2_DE10/software/toolchain}"
MSG="${MSG:-Update $DEST_SUBPATH ($(date -u +'%Y-%m-%d %H:%M:%S UTC'))}"
SRC_DIR="${1:-}"; [[ -z "$SRC_DIR" ]] && { echo "Uso: $0 <SRC_DIR> [DEST_SUBPATH]"; exit 1; }
command -v git >/dev/null || { echo "git não encontrado"; exit 1; }
command -v rsync >/dev/null || { echo "rsync não encontrado"; exit 1; }
if [[ ! -d "$REPO_DIR/.git" ]]; then git clone "$REPO_SSH" "$REPO_DIR"; fi
cd "$REPO_DIR"
git fetch --all --prune
git checkout "$BRANCH" || git checkout -B "$BRANCH" "origin/$BRANCH" || true
git pull --rebase origin "$BRANCH" || true
mkdir -p "$DEST_SUBPATH"
rsync -av --delete --exclude '.git' --exclude '.DS_Store' "$SRC_DIR"/ "$DEST_SUBPATH"/
git add "$DEST_SUBPATH"
git diff --cached --quiet && { echo "Nada para commitar."; exit 0; }
git commit -m "$MSG"
git push -u origin "$BRANCH"
echo "OK — atualizado: $DEST_SUBPATH -> $BRANCH"
