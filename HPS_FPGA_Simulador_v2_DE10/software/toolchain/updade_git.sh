#!/usr/bin/env bash
set -euo pipefail

# --- Config padrão (altere via env) ---
REPO_SSH="${REPO_SSH:-git@github.com-vini:viniciuspires12/HitsSim_NIPS.git}"  # use seu alias SSH
REPO_DIR="${REPO_DIR:-$HOME/HitsSim_NIPS}"                                     # pasta local do repo
BRANCH="${BRANCH:-main}"                                                       # branch alvo
DEST_SUBPATH="${2:-HPS_FPGA_Simulador_v2_DE10/software/toolchain}"             # destino no repo
MSG="${MSG:-Update $DEST_SUBPATH ($(date -u +'%Y-%m-%d %H:%M:%S UTC'))}"

# --- Args ---
SRC_DIR="${1:-}"
usage(){ echo "Uso: $0 <SRC_DIR_LOCAL> [DEST_SUBPATH_NO_REPO]"; exit 1; }
[[ -z "${SRC_DIR}" ]] && usage
command -v git >/dev/null || { echo "git não encontrado"; exit 1; }
command -v rsync >/dev/null || { echo "rsync não encontrado"; exit 1; }

# --- Clona se necessário ---
if [[ ! -d "${REPO_DIR}/.git" ]]; then
  git clone "${REPO_SSH}" "${REPO_DIR}"
fi

# --- Atualiza repo ---
cd "${REPO_DIR}"
git fetch --all --prune
# checkout do branch (cria local a partir do remoto se precisar)
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  git checkout "${BRANCH}"
else
  git checkout -B "${BRANCH}" "origin/${BRANCH}" || git checkout "${BRANCH}"
fi
git pull --rebase origin "${BRANCH}" || true

# --- Copia conteúdo (espelha) ---
mkdir -p "${DEST_SUBPATH}"
rsync -av --delete --exclude '.git' --exclude '.DS_Store' "${SRC_DIR}/" "${DEST_SUBPATH}/"

# --- Commit & push (se houve mudanças) ---
git add "${DEST_SUBPATH}"
if git diff --cached --quiet; then
  echo "Nada para commitar. Pasta já está atualizada."
  exit 0
fi
git commit -m "${MSG}"
git push -u origin "${BRANCH}"
echo "OK — atualizado: ${DEST_SUBPATH} -> ${BRANCH}"

