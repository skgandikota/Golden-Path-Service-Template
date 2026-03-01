#!/usr/bin/env bash
# bootstrap.sh — Golden Path Service Template
#
# Usage:
#   bash scripts/bootstrap.sh <service-name>
#
# What it does:
#   1. Copies the /template folder into a new directory named <service-name>
#   2. Renames placeholder strings to the provided service name
#   3. Prints next steps

set -euo pipefail

# ── Helpers ────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}ℹ  $*${RESET}"; }
success() { echo -e "${GREEN}✔  $*${RESET}"; }
error()   { echo -e "${RED}✖  $*${RESET}" >&2; exit 1; }

# ── Validate input ─────────────────────────────────────────────────────────────

SERVICE_NAME="${1:-}"

if [[ -z "$SERVICE_NAME" ]]; then
  error "Service name is required.\nUsage: bash scripts/bootstrap.sh <service-name>"
fi

if [[ ! "$SERVICE_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
  error "Service name must be lowercase alphanumeric with hyphens (e.g. payment-service)."
fi

# ── Locate template directory ──────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_DIR="${REPO_ROOT}/template"
TARGET_DIR="${REPO_ROOT}/${SERVICE_NAME}"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  error "Template directory not found at: ${TEMPLATE_DIR}"
fi

if [[ -d "$TARGET_DIR" ]]; then
  error "Directory '${SERVICE_NAME}' already exists. Choose a different name."
fi

# ── Copy template ──────────────────────────────────────────────────────────────

info "Bootstrapping service: ${BOLD}${SERVICE_NAME}${RESET}"
info "Source  : ${TEMPLATE_DIR}"
info "Target  : ${TARGET_DIR}"
echo ""

cp -r "$TEMPLATE_DIR" "$TARGET_DIR"
success "Template copied to ./${SERVICE_NAME}/"

# ── Replace placeholder names ──────────────────────────────────────────────────

PLACEHOLDER="hello-platform-service"

# Portable in-place sed (works on both Linux and macOS)
find "$TARGET_DIR" -type f | while read -r file; do
  if grep -qI "$PLACEHOLDER" "$file" 2>/dev/null; then
    sed -i.bak "s/${PLACEHOLDER}/${SERVICE_NAME}/g" "$file"
    rm -f "${file}.bak"
    info "Updated: ${file#"${REPO_ROOT}/"}"
  fi
done

success "Placeholder '${PLACEHOLDER}' replaced with '${SERVICE_NAME}'"

# ── Print next steps ───────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  🚀 Service '${SERVICE_NAME}' is ready!${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo ""
echo -e "  ${CYAN}1. Enter your new service directory${RESET}"
echo -e "     cd ${SERVICE_NAME}"
echo ""
echo -e "  ${CYAN}2. Run locally${RESET}"
echo -e "     pip install -r requirements.txt"
echo -e "     uvicorn app.main:app --reload"
echo -e "     → http://localhost:8000/docs"
echo ""
echo -e "  ${CYAN}3. Build the container${RESET}"
echo -e "     docker build -t ${SERVICE_NAME}:dev ."
echo -e "     docker run -p 8000:8000 ${SERVICE_NAME}:dev"
echo ""
echo -e "  ${CYAN}4. Push to GitHub to trigger CI/CD${RESET}"
echo -e "     git init && git add . && git commit -m 'feat: initial scaffold'"
echo -e "     git remote add origin https://github.com/your-org/${SERVICE_NAME}.git"
echo -e "     git push -u origin main"
echo ""
echo -e "  ${CYAN}5. Provision infrastructure${RESET}"
echo -e "     cd infra && terraform init && terraform apply"
echo ""
echo -e "  📖 Full guide: docs/onboarding-guide.md"
echo -e "  🔒 Security:   docs/security-model.md"
echo ""
