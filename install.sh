#!/bin/bash
#
# Instalador do gl - Git/GitLab Automation Tool
# Uso: curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash
#

set -euo pipefail

readonly REPO_URL="https://raw.githubusercontent.com/arkntld/gl/master/gl"
readonly SCRIPT_NAME="gl"
readonly VERSION="4.0"

# Cores
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

log_info() { echo -e "${C_GREEN}✓${C_RESET} $*"; }
log_warn() { echo -e "${C_YELLOW}⚠${C_RESET} $*"; }
log_error() { echo -e "${C_RED}✗${C_RESET} $*" >&2; exit 1; }
log_step() { echo -e "\n${C_BLUE}${C_BOLD}▶${C_RESET} $*"; }

# Banner
clear
echo -e "${C_BOLD}${C_BLUE}"
cat << 'EOF'
   _____ _
  / ____| |
 | |  __| |
 | | |_ | |
 | |__| | |____
  \_____|______|

  Git/GitLab Automation Tool
  Installer v4.0
EOF
echo -e "${C_RESET}\n"

# 1. Verificar Sistema Operacional
log_step "Verificando sistema operacional..."
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    log_info "Linux detectado"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    log_info "macOS detectado"
else
    log_warn "Sistema não testado: $OSTYPE"
fi

# 2. Verificar Dependências
log_step "Verificando dependências..."
MISSING_DEPS=()

for cmd in git curl jq openssl; do
    if command -v "$cmd" &>/dev/null; then
        log_info "$cmd"
    else
        MISSING_DEPS+=("$cmd")
        log_warn "$cmd (faltando)"
    fi
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    echo ""
    INSTALL_CMD=""

    if [[ "$OS" == "linux" ]]; then
        if command -v apt &>/dev/null; then
            INSTALL_CMD="sudo apt update && sudo apt install -y ${MISSING_DEPS[*]}"
        elif command -v pacman &>/dev/null; then
            INSTALL_CMD="sudo pacman -S ${MISSING_DEPS[*]}"
        elif command -v dnf &>/dev/null; then
            INSTALL_CMD="sudo dnf install ${MISSING_DEPS[*]}"
        fi
    elif [[ "$OS" == "macos" ]]; then
        INSTALL_CMD="brew install ${MISSING_DEPS[*]}"
    fi

    if [[ -n "$INSTALL_CMD" ]]; then
        echo -e "${C_YELLOW}Execute:${C_RESET} $INSTALL_CMD"
        read -p "Instalar automaticamente? (y/N): " auto_install
        if [[ "$auto_install" =~ ^[Yy]$ ]]; then
            eval "$INSTALL_CMD" || log_error "Falha ao instalar dependências"
        else
            log_error "Instale as dependências e execute novamente"
        fi
    else
        log_error "Instale: ${MISSING_DEPS[*]}"
    fi
fi

# 3. Determinar Diretório de Instalação
log_step "Determinando local de instalação..."

if [[ $EUID -eq 0 ]]; then
    INSTALL_DIR="/usr/local/bin"
    log_info "Instalação global: $INSTALL_DIR (root)"
elif [[ -w /usr/local/bin ]]; then
    INSTALL_DIR="/usr/local/bin"
    log_info "Instalação global: $INSTALL_DIR"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    log_info "Instalação local: $INSTALL_DIR"
fi

# 4. Verificar se já existe
TARGET_PATH="$INSTALL_DIR/$SCRIPT_NAME"
if [[ -f "$TARGET_PATH" ]]; then
    CURRENT_VERSION=$("$TARGET_PATH" --version 2>/dev/null | grep -oP '\d+\.\d+' || echo "0.0")
    log_warn "gl já instalado (v${CURRENT_VERSION})"
    read -p "Substituir com v${VERSION}? (Y/n): " replace
    if [[ "$replace" =~ ^[Nn]$ ]]; then
        log_error "Instalação cancelada"
    fi
fi

# 5. Download
log_step "Baixando gl v${VERSION}..."

if curl -fsSL "$REPO_URL" -o "$TARGET_PATH"; then
    chmod +x "$TARGET_PATH"
    log_info "Download concluído"
else
    log_error "Falha no download de $REPO_URL"
fi

# 6. Verificar Instalação
if [[ -x "$TARGET_PATH" ]]; then
    INSTALLED_VERSION=$("$TARGET_PATH" --version 2>/dev/null | grep -oP '\d+\.\d+' || echo "unknown")
    log_info "Instalado: $TARGET_PATH (v${INSTALLED_VERSION})"
else
    log_error "Arquivo não executável: $TARGET_PATH"
fi

# 7. Configurar PATH (se necessário)
NEEDS_SOURCE=false
if [[ "$INSTALL_DIR" == "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    log_step "Configurando PATH..."

    SHELL_RC=""
    if [[ -n "${BASH_VERSION:-}" ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ -n "${ZSH_VERSION:-}" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.zshrc" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.profile"
    fi

    echo "" >> "$SHELL_RC"
    echo "# gl - GitLab Tool" >> "$SHELL_RC"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
    log_info "PATH atualizado em $SHELL_RC"
    export PATH="$PATH:$INSTALL_DIR"
    NEEDS_SOURCE=true
fi

# 8. Testar Instalação
log_step "Testando instalação..."
if command -v gl &>/dev/null; then
    log_info "Comando 'gl' disponível"
else
    log_warn "Comando 'gl' não encontrado no PATH atual"
    log_warn "Reinicie seu terminal ou execute: source $SHELL_RC"
fi

# 9. Setup Inicial COMPLETO
echo ""
echo -e "${C_GREEN}${C_BOLD}✅ Instalação concluída!${C_RESET}\n"

log_step "Configuração Inicial"

# 9.1 GitLab Host
read -p "GitLab Host [git.agdtech.site]: " GITLAB_HOST
GITLAB_HOST=${GITLAB_HOST:-git.agdtech.site}

# 9.2 Token
echo ""
echo -e "${C_YELLOW}${C_BOLD}Configure seu Personal Access Token${C_RESET}"
echo -e "${C_BLUE}Obtenha em: https://${GITLAB_HOST}/-/user_settings/personal_access_tokens${C_RESET}"
echo ""
echo "Scopes necessários:"
echo "  • api"
echo "  • read_user"
echo "  • write_repository"
echo ""
read -sp "Token (cole aqui): " GITLAB_TOKEN
echo ""

SKIP_TOKEN=false
if [[ -z "$GITLAB_TOKEN" ]]; then
    echo ""
    log_warn "Token não fornecido. Execute depois: gl --setup"
    SKIP_TOKEN=true
fi

# 9.3 Git User
echo ""
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [[ -z "$GIT_NAME" ]]; then
    read -p "Seu nome para commits: " GIT_NAME
fi

if [[ -z "$GIT_EMAIL" ]]; then
    read -p "Seu email para commits: " GIT_EMAIL
fi

# 9.4 Preferências
echo ""
read -p "Visibilidade padrão (private/internal/public) [private]: " VISIBILITY
VISIBILITY=${VISIBILITY:-private}

read -p "Fazer backup antes de force push? (Y/n): " BACKUP_PREF
if [[ "$BACKUP_PREF" =~ ^[Nn]$ ]]; then
    BACKUP_BEFORE_FORCE="false"
else
    BACKUP_BEFORE_FORCE="true"
fi

# 10. Criar estrutura de configuração
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gl"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gl"
mkdir -p "$CONFIG_DIR" "$DATA_DIR/backups"
touch "$CONFIG_DIR/watched-repos.txt"

# 11. Salvar configurações
CONFIG_FILE="$CONFIG_DIR/config.json"
cat > "$CONFIG_FILE" << EOF
{
  "gitlab_host": "$GITLAB_HOST",
  "default_visibility": "$VISIBILITY",
  "backup_before_force": "$BACKUP_BEFORE_FORCE"
}
EOF

log_info "Configuração salva em: $CONFIG_FILE"

# 12. Configurar Git global
if [[ -n "$GIT_NAME" ]]; then
    git config --global user.name "$GIT_NAME"
    log_info "Git user.name: $GIT_NAME"
fi

if [[ -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
    log_info "Git user.email: $GIT_EMAIL"
fi

# 13. Configurar credential helper
git config --global credential.helper store
log_info "Credential helper configurado (token salvo automaticamente)"

# 14. Salvar Token
if [[ "$SKIP_TOKEN" == "false" ]]; then
    # Salvar token para API do gl
    if command -v secret-tool &>/dev/null; then
        echo -n "$GITLAB_TOKEN" | secret-tool store --label="GitLab Token (gl)" application gl service gitlab 2>/dev/null
        log_info "Token armazenado no GNOME Keyring"
    elif [[ -f /usr/bin/security ]]; then
        security add-generic-password -a "$USER" -s "gl-gitlab-token" -w "$GITLAB_TOKEN" -U 2>/dev/null
        log_info "Token armazenado no macOS Keychain"
    else
        TOKEN_FILE="$CONFIG_DIR/token.enc"
        echo -n "$GITLAB_TOKEN" | openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -out "$TOKEN_FILE" -pass pass:"$USER-$(hostname)" 2>/dev/null
        chmod 600 "$TOKEN_FILE"
        log_info "Token armazenado criptografado"
    fi

    # Salvar token também em ~/.git-credentials para git push
    CRED_FILE="$HOME/.git-credentials"

    # Remover entrada antiga do host se existir
    if [[ -f "$CRED_FILE" ]]; then
        grep -v "${GITLAB_HOST}" "$CRED_FILE" > "${CRED_FILE}.tmp" 2>/dev/null || true
        mv "${CRED_FILE}.tmp" "$CRED_FILE" 2>/dev/null || true
    fi

    # Adicionar nova entrada
    echo "https://oauth2:${GITLAB_TOKEN}@${GITLAB_HOST}" >> "$CRED_FILE"
    chmod 600 "$CRED_FILE"
    log_info "Token salvo em ~/.git-credentials (git push não pedirá senha)"

    # 15. Testar conexão com GitLab
    echo ""
    log_step "Testando conexão com GitLab..."

    TEST_RESULT=$(curl -s -w "\n%{http_code}" \
        --request GET "https://${GITLAB_HOST}/api/v4/user" \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" 2>/dev/null)

    HTTP_CODE=$(echo "$TEST_RESULT" | tail -n1)
    BODY=$(echo "$TEST_RESULT" | sed '$d')

    if [[ "$HTTP_CODE" == "200" ]]; then
        USERNAME=$(echo "$BODY" | jq -r '.username // "unknown"' 2>/dev/null || echo "unknown")
        log_info "${C_GREEN}Conectado como: ${C_BOLD}$USERNAME${C_RESET}"
    else
        echo ""
        log_warn "Falha na autenticação (HTTP $HTTP_CODE)"
        echo "Execute 'gl --set-token' para reconfigurar"
    fi
fi

# 16. Mensagem Final
echo ""
echo -e "${C_BLUE}${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_BOLD}Próximos passos:${C_RESET}"
echo ""
echo -e "  ${C_GREEN}1.${C_RESET} Verificar saúde: ${C_BOLD}gl --doctor${C_RESET}"
echo -e "  ${C_GREEN}2.${C_RESET} Ver ajuda:       ${C_BOLD}gl --help${C_RESET}"
echo -e "  ${C_GREEN}3.${C_RESET} Usar:            ${C_BOLD}cd seu-projeto && gl${C_RESET}"
echo ""

if [[ "$NEEDS_SOURCE" == "true" ]]; then
    echo -e "${C_YELLOW}⚠  Reinicie o terminal ou execute:${C_RESET}"
    echo -e "   ${C_BOLD}source $SHELL_RC${C_RESET}"
    echo ""
fi

if [[ "$SKIP_TOKEN" == "true" ]]; then
    echo -e "${C_YELLOW}⚠  Token não configurado. Execute:${C_RESET}"
    echo -e "   ${C_BOLD}gl --setup${C_RESET}"
    echo ""
fi

echo -e "${C_BLUE}${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""
echo -e "${C_GREEN}Documentação:${C_RESET} https://github.com/seu-repo/gl"
echo -e "${C_GREEN}Issues:${C_RESET}        https://github.com/seu-repo/gl/issues"
echo ""
echo -e "${C_YELLOW}${C_BOLD}✨ Token configurado! Git push não vai pedir senha! ✨${C_RESET}"
echo ""
