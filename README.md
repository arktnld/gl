# 🚀 gl - Git/GitLab Automation Tool

Ferramenta profissional para gerenciar repositórios Git com GitLab de forma automatizada, segura e eficiente.
```
   _____ _
  / ____| |
 | |  __| |
 | | |_ | |
 | |__| | |____
  \_____|______|
```

[![Version](https://img.shields.io/badge/version-4.0-blue.svg)](https://github.com/seu-repo/gl)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

## ⚡ Quick Start
```bash
# 1. Instalar
curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash

# 2. Usar (já está configurado!)
cd meu-projeto
gl
```

**✨ Token configurado automaticamente - nunca mais pede senha! ✨**

## 📋 Índice

- [Instalação](#-instalação)
- [Uso Básico](#-uso-básico)
- [Funcionalidades Avançadas](#-funcionalidades-avançadas)
- [Auto-commit (Daemon)](#-auto-commit-daemon)
- [Templates](#-templates)
- [Troubleshooting](#-troubleshooting)
- [Referência Rápida](#-referência-rápida)

## 📦 Instalação

### Instalador Automático (Recomendado)
```bash
curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash
```

O instalador irá:
- ✅ Verificar e instalar dependências
- ✅ Baixar e instalar o script
- ✅ **Pedir seu token GitLab**
- ✅ Configurar Git (nome e email)
- ✅ **Configurar credential helper (não pede senha!)**
- ✅ Testar conexão com GitLab
- ✅ Pronto para usar!

### Instalação Manual
```bash
# Download
sudo curl -o /usr/local/bin/gl https://raw.githubusercontent.com/seu-repo/gl/main/gl
sudo chmod +x /usr/local/bin/gl

# Configurar
gl --setup
```

### Dependências
```bash
# Debian/Ubuntu
sudo apt update && sudo apt install -y git curl jq openssl

# Arch Linux
sudo pacman -S git curl jq openssl

# macOS
brew install git curl jq openssl
```

### Verificar Instalação
```bash
gl --version
# gl version 4.0

gl --doctor
# Verifica se tudo está funcionando
```

## 🎯 Uso Básico

### Criar Novo Projeto
```bash
cd ~/projetos/meu-novo-app
gl atendflow/backend meu-novo-app
```

**O que acontece:**
- Cria hierarquia de grupos no GitLab
- Cria projeto no GitLab
- Inicializa Git localmente
- Cria `.gitignore` padrão
- Faz commit inicial
- Push para `main`
- **SEM PEDIR SENHA!** ✨

### Commit & Push em Projeto Existente
```bash
cd ~/projetos/projeto-existente
vim src/main.py
gl
```

**Interação:**
```
[INFO ] Alterações detectadas:
  M src/main.py

Mensagem do commit: fix: corrige bug no login

[INFO ] Commit: fix: corrige bug no login
[INFO ] Push realizado com sucesso!
```

### Criar Merge Request
```bash
# MR para main
git checkout -b feature/nova-funcionalidade
vim src/feature.py
gl -m

# MR para develop
gl -M develop
```

## 🔥 Funcionalidades Avançadas

### Force Push com Backup
```bash
git commit --amend
gl -f
```

Cria backup automático em `~/.local/share/gl/backups/` antes do push.

**Restaurar backup:**
```bash
ls -lh ~/.local/share/gl/backups/
git clone ~/.local/share/gl/backups/meu-projeto_20250526_180000.bundle meu-projeto-restaurado
```

### Push para Branch Específico
```bash
gl -b develop  # Push branch atual para develop remoto
```

### Combinando Opções
```bash
gl -f -M develop           # Force push + MR para develop
gl -b staging -m           # Push para staging + MR para main
gl -v -m                   # Verbose mode com MR
```

## 🤖 Auto-commit (Daemon)

Automatiza commits e pushes para múltiplos repositórios.

### Setup Rápido
```bash
# 1. Adicionar repos ao monitoramento
cd ~/projetos/backend-api
gl --add-watch .

cd ~/projetos/frontend
gl --add-watch .

# 2. Listar repos monitorados
gl --list-watch

# 3. Testar manualmente
gl --daemon
```

### Configurar Cron Job
```bash
crontab -e
```

**Diário às 18h:**
```cron
0 18 * * * /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

**A cada 30min (horário comercial):**
```cron
*/30 9-18 * * 1-5 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

**Múltiplos horários:**
```cron
# gl - Auto-commit daemon
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin

# Segunda a Sexta: 9h, 12h, 17h
0 9,12,17 * * 1-5 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1

# Sábado: 10h
0 10 * * 6 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

### Verificar Logs
```bash
tail -f ~/.local/share/gl/cron.log      # Log do cron
tail -f ~/.local/share/gl/gl.log        # Log detalhado
```

## 📝 Templates

### Criar Template
```bash
cd ~/templates/python-api
mkdir -p src tests

cat > requirements.txt << EOF
fastapi==0.104.0
uvicorn==0.24.0
pydantic==2.5.0
EOF

gl -c python-api
```

### Usar Template
```bash
cd ~/projetos/novo-projeto
gl -t python-api atendflow/backend novo-projeto
```

### Templates Prontos

**Python FastAPI:**
```
python-fastapi/
├── src/
│   ├── __init__.py
│   ├── main.py
│   └── api/v1/
├── tests/
├── requirements.txt
└── Dockerfile
```

**React TypeScript:**
```
react-typescript/
├── src/
│   ├── components/
│   ├── pages/
│   └── App.tsx
├── package.json
└── tsconfig.json
```

## 🛠️ Troubleshooting

### Token não configurado
```bash
gl --set-token
# Ou
gl --setup
```

### API retornou 401
```bash
gl --doctor

# Gerar novo token: GitLab → Settings → Access Tokens
# Scopes: api, read_user, write_repository

gl --set-token
```

### Git push ainda pede senha
```bash
# Verificar credential helper
git config --global credential.helper

# Se não for "store", configurar:
git config --global credential.helper store

# Verificar ~/.git-credentials
cat ~/.git-credentials
# Deve ter: https://oauth2:TOKEN@git.agdtech.site
```

### Histórico divergente
```bash
# Opção 1: Rebase
git pull --rebase
gl

# Opção 2: Merge
git pull
gl

# Opção 3: Force push (cuidado!)
gl -f
```

### Daemon não executa no cron
```bash
# Testar com PATH do cron
env -i SHELL=/bin/bash PATH=/usr/local/bin:/usr/bin:/bin /usr/local/bin/gl --daemon

# Ver logs
tail -f ~/.local/share/gl/cron.log
grep gl /var/log/syslog | tail -20

# Corrigir crontab
crontab -e
# Adicionar:
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
```

### Comando 'gl' não encontrado
```bash
# Verificar instalação
which gl

# Adicionar ao PATH
export PATH="$PATH:$HOME/.local/bin"
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

## 📚 Referência Rápida

### Comandos Principais
```bash
# Setup
gl --setup              # Configuração inicial
gl --doctor             # Diagnóstico
gl --set-token          # Atualizar token
gl --version            # Versão

# Git
gl                      # Commit + push
gl -m                   # + MR para main
gl -M develop           # + MR para develop
gl -f                   # Force push (com backup)
gl -b staging           # Push para branch específico
gl -v                   # Verbose mode

# Daemon
gl --daemon             # Executar uma vez
gl --add-watch .        # Adicionar repo
gl --list-watch         # Listar repos

# Templates
gl -c <nome>            # Criar template
gl -t <nome> ...        # Usar template

# Novo projeto
gl grupo/subgrupo projeto-nome
```

### Estrutura de Diretórios
```
~/.config/gl/
├── config.json           # Configurações
├── watched-repos.txt     # Repos monitorados
└── token.enc             # Token criptografado

~/.local/share/gl/
├── backups/              # Backups dos force push
│   └── projeto_*.bundle
├── gl.log                # Log principal
└── cron.log              # Log do daemon

~/.git-credentials        # Credenciais Git (HTTPS)
```

### Conventional Commits
```
feat:     Nova funcionalidade
fix:      Correção de bug
docs:     Documentação
style:    Formatação
refactor: Refatoração
test:     Testes
chore:    Manutenção
perf:     Performance
```

O `gl` adiciona prefixo automaticamente se necessário.

### Atalhos Úteis
```bash
# Adicionar ao ~/.bashrc ou ~/.zshrc
alias glp='gl'                    # Push rápido
alias glm='gl -m'                 # Push + MR
alias gld='gl -M develop'         # Push + MR para develop
alias glf='gl -f'                 # Force push
alias gls='gl --doctor'           # Health check
alias glw='gl --add-watch .'      # Watch repo atual
```

## 🎨 Exemplos de Workflow

### Desenvolvimento Diário
```bash
# 09:00 - Nova feature
cd ~/projetos/backend-api
git checkout -b feature/nova-api

# 10:30 - Commit intermediário
vim src/api.py
gl

# 17:00 - Finalizar e MR
gl -M develop
```

### Setup de Novo Cliente
```bash
mkdir -p ~/clientes/novo-cliente/{backend,frontend,mobile}

# Backend
cd ~/clientes/novo-cliente/backend
gl -t python-fastapi novo-cliente/backend api-service

# Frontend
cd ~/clientes/novo-cliente/frontend
gl -t react-typescript novo-cliente/frontend web-app

# Adicionar ao monitoramento
cd ~/clientes/novo-cliente
for dir in backend frontend mobile; do
    cd $dir && gl --add-watch . && cd ..
done
```

### Hotfix em Produção
```bash
cd ~/projetos/backend-api
git checkout main
git checkout -b hotfix/critical-bug

vim src/bug.py
git add .
git commit -m "fix: corrige bug crítico"

gl -M main  # MR urgente
```

### Multi-repo com Daemon
```bash
# Setup
PROJECTS=(
    "~/projetos/backend-api"
    "~/projetos/frontend"
    "~/projetos/mobile"
)

for project in "${PROJECTS[@]}"; do
    cd "$project" && gl --add-watch .
done

# Configurar cron
crontab -e
# Adicionar: 0 18 * * * gl --daemon

# Trabalhar normalmente - commits automáticos às 18h!
```

## 🔒 Segurança

### Armazenamento do Token

**Token da API (para criar projetos, MRs):**
- Linux (GNOME): GNOME Keyring (criptografado)
- macOS: Keychain (criptografado)
- Outros: AES-256-CBC em `~/.config/gl/token.enc`

**Token do Git (para push/pull):**
- Salvo em `~/.git-credentials` (permissões 600)
- Formato: `https://oauth2:TOKEN@gitlab.com`
- Usado automaticamente pelo Git

### Permissões do Token GitLab

Token deve ter:
- ✅ `api` - Acesso completo à API
- ✅ `read_user` - Ler informações do usuário
- ✅ `write_repository` - Push para repositórios

### Boas Práticas
```bash
# 1. Nunca commitar configs
echo ".config/gl/" >> ~/.gitignore
echo ".git-credentials" >> ~/.gitignore

# 2. Renovar token periodicamente (90 dias)
gl --set-token

# 3. Backups do config (sem token!)
cp ~/.config/gl/config.json ~/backups/gl-config-$(date +%Y%m%d).json

# 4. Verificar saúde
gl --doctor

# 5. Ver token salvo (primeiros caracteres)
cat ~/.git-credentials | cut -d: -f3 | cut -d@ -f1 | head -c 20
```

### Auditoria
```bash
# Últimos commits automatizados
grep "auto-commit" ~/.local/share/gl/gl.log | tail -20

# Últimas execuções do daemon
tail -50 ~/.local/share/gl/cron.log

# Histórico de force pushes
ls -lht ~/.local/share/gl/backups/ | head -10
```

## 🎯 FAQ

**Por que usar gl ao invés do Git direto?**
- Automatiza tarefas repetitivas
- Cria estrutura de grupos automaticamente
- Integração nativa com GitLab (MRs)
- Auto-commit para múltiplos projetos
- Backups automáticos em force push
- Token salvo automaticamente (nunca pede senha!)

**Como funciona o token automático?**
Durante a instalação, o token é salvo em dois lugares:
1. `~/.config/gl/token.enc` - para API do gl (criar projetos, MRs)
2. `~/.git-credentials` - para Git push/pull (HTTPS)

**Preciso configurar SSH?**
Não! O gl usa HTTPS com credential helper. É mais simples e funciona em qualquer rede.

**É seguro ter token em ~/.git-credentials?**
Sim! O arquivo tem permissões 600 (só você pode ler). É o método padrão do Git para HTTPS.

**gl funciona com GitHub?**
Atualmente não, mas está no roadmap (v4.1).

**Posso usar em repositórios existentes?**
Sim! O gl detecta automaticamente se é projeto novo ou existente.

**O daemon commita tudo automaticamente?**
Sim, todos os repos em `~/.config/gl/watched-repos.txt` são processados.

## ⭐ Roadmap

### v4.1 (Próximo)
- Interface TUI interativa
- Suporte a GitHub
- Hooks customizáveis
- Integração com CI/CD

### v5.0 (Futuro)
- Dashboard web
- Suporte a múltiplos remotes
- Plugin system
- Auto-update

## 📄 Licença

MIT License - Veja [LICENSE](LICENSE)

## 🆘 Suporte

- Issues: https://github.com/seu-repo/gl/issues
- Discussões: https://github.com/seu-repo/gl/discussions
- Email: suporte@example.com

## 📊 Estatísticas
```
Linhas de código:    ~1200
Linguagem:           100% Bash
Dependências:        4 (git, curl, jq, openssl)
Tamanho:             ~50KB
Autenticação:        HTTPS + credential.helper store
```

## 📝 Changelog

### v4.0 (2025-11-26)
- ✨ Release inicial
- ✨ Token salvo automaticamente em ~/.git-credentials
- ✨ Credential helper configurado automaticamente
- ✨ HTTPS por padrão (sem necessidade de SSH)
- ✨ Setup wizard completo durante instalação
- ✨ Daemon mode para auto-commit
- ✨ Sistema de templates
- ✨ Backup automático em force push
- ✨ Rate limiting com retry
- ✨ Conventional commits automático
- ✨ Doctor para diagnóstico

---

**Feito com ❤️ por Cleberson**

⭐ Se este projeto te ajudou, considere dar uma estrela!
```bash
# Start automating now!
curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash
```

**✨ Token configurado automaticamente - nunca mais pede senha! ✨**
