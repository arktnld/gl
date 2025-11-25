#!/bin/bash
#
# Instalador do gl - Git/GitLab Automation Tool
# Uso: curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash
#

set -euo pipefail

readonly REPO_URL="https://raw.githubusercontent.com/arktnld/gl/main/gl"
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
INSTALL_CMD=""

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
    # Executando como root
    INSTALL_DIR="/usr/local/bin"
    log_info "Instalação global: $INSTALL_DIR (root)"
elif [[ -w /usr/local/bin ]]; then
    # Tem permissão em /usr/local/bin
    INSTALL_DIR="/usr/local/bin"
    log_info "Instalação global: $INSTALL_DIR"
else
    # Instalação local
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
if [[ "$INSTALL_DIR" == "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    log_step "Configurando PATH..."

    # Detectar shell
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

    read -p "Adicionar $INSTALL_DIR ao PATH em $SHELL_RC? (Y/n): " add_path
    if [[ ! "$add_path" =~ ^[Nn]$ ]]; then
        echo "" >> "$SHELL_RC"
        echo "# gl - GitLab Tool" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$SHELL_RC"
        log_info "PATH atualizado em $SHELL_RC"
        export PATH="$PATH:$INSTALL_DIR"
        NEEDS_SOURCE=true
    else
        log_warn "Adicione manualmente: export PATH=\"\$PATH:$INSTALL_DIR\""
    fi
fi

# 8. Testar Instalação
log_step "Testando instalação..."
if command -v gl &>/dev/null; then
    log_info "Comando 'gl' disponível"
else
    log_warn "Comando 'gl' não encontrado no PATH atual"
    log_warn "Reinicie seu terminal ou execute: source $SHELL_RC"
fi

# 9. Setup Inicial
echo ""
echo -e "${C_GREEN}${C_BOLD}✅ Instalação concluída!${C_RESET}\n"

read -p "Executar configuração inicial agora? (Y/n): " run_setup
echo ""
if [[ ! "$run_setup" =~ ^[Nn]$ ]]; then
    if command -v gl &>/dev/null; then
        gl --setup
    else
        "$TARGET_PATH" --setup
    fi
else
    echo -e "${C_YELLOW}Execute depois: gl --setup${C_RESET}"
fi

# 10. Mensagem Final
echo ""
echo -e "${C_BLUE}${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_BOLD}Próximos passos:${C_RESET}"
echo ""
echo -e "  ${C_GREEN}1.${C_RESET} Verificar saúde: ${C_BOLD}gl --doctor${C_RESET}"
echo -e "  ${C_GREEN}2.${C_RESET} Ver ajuda:       ${C_BOLD}gl --help${C_RESET}"
echo -e "  ${C_GREEN}3.${C_RESET} Usar:            ${C_BOLD}cd seu-projeto && gl${C_RESET}"
echo ""

if [[ "${NEEDS_SOURCE:-false}" == "true" ]]; then
    echo -e "${C_YELLOW}⚠  Reinicie o terminal ou execute:${C_RESET}"
    echo -e "   ${C_BOLD}source $SHELL_RC${C_RESET}"
    echo ""
fi

echo -e "${C_BLUE}${C_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""
echo -e "${C_GREEN}Documentação:${C_RESET} https://github.com/seu-repo/gl"
echo -e "${C_GREEN}Issues:${C_RESET}        https://github.com/seu-repo/gl/issues"
echo ""
