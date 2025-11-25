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

---

## ⚡ Quick Start

```bash
# 1. Instalar
curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash

# 2. Configurar
gl --setup

# 3. Usar
cd meu-projeto
gl
```

---

## 📋 Índice

- [Instalação](#-instalação)
- [Configuração Inicial](#-configuração-inicial)
- [Uso Básico](#-uso-básico)
- [Funcionalidades Avançadas](#-funcionalidades-avançadas)
- [Auto-commit (Daemon)](#-auto-commit-daemon)
- [Templates](#-templates)
- [Troubleshooting](#-troubleshooting)
- [Referência Rápida](#-referência-rápida)

---

## 📦 Instalação

### Método 1: Instalador Automático (Recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/seu-repo/gl/main/install.sh | bash
```

O instalador irá:
- ✅ Verificar dependências
- ✅ Escolher local de instalação apropriado
- ✅ Adicionar ao PATH automaticamente
- ✅ Executar setup inicial

### Método 2: Instalação Manual

```bash
# Download
sudo curl -o /usr/local/bin/gl https://raw.githubusercontent.com/seu-repo/gl/main/gl
sudo chmod +x /usr/local/bin/gl

# Ou instalação local
mkdir -p ~/.local/bin
curl -o ~/.local/bin/gl https://raw.githubusercontent.com/seu-repo/gl/main/gl
chmod +x ~/.local/bin/gl
export PATH="$PATH:$HOME/.local/bin"
```

### Método 3: Clone do Repositório

```bash
git clone https://github.com/seu-repo/gl.git
cd gl
sudo cp gl /usr/local/bin/
sudo chmod +x /usr/local/bin/gl
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
# Saída: gl version 4.0

gl --doctor
# Verifica se tudo está funcionando
```

---

## 🔧 Configuração Inicial

### Passo 1: Setup Wizard

```bash
gl --setup
```

O wizard irá solicitar:

#### 1️⃣ GitLab Host
```
GitLab Host [git.agdtech.site]: gitlab.com
```
Informe o host do seu GitLab (pode ser self-hosted ou gitlab.com)

#### 2️⃣ Personal Access Token
```
Configure seu Personal Access Token
Obtenha em: https://gitlab.com/-/user_settings/personal_access_tokens
Scopes necessários: api, read_user, write_repository
Token: ************************************
```

**Como obter o token:**
1. Acesse seu GitLab → Settings → Access Tokens
2. Nome: `gl-automation`
3. Marque os scopes: `api`, `read_user`, `write_repository`
4. Clique em "Create personal access token"
5. Copie o token (só aparece uma vez!)

#### 3️⃣ Git User
```
Seu nome para commits: Cleberson
Seu email para commits: cleberson@example.com
```

#### 4️⃣ Preferências
```
Visibilidade padrão (private/internal/public) [private]: private
Fazer backup antes de force push? (Y/n): y
```

### Passo 2: Verificar Saúde

```bash
gl --doctor
```

**Saída esperada:**

```
=== gl Health Check ===

Dependências:
  ✓ git
  ✓ curl
  ✓ jq
  ✓ openssl

Configuração:
  ✓ Arquivo de config
  ✓ Token armazenado

Conectividade:
  ✓ GitLab acessível (gitlab.com)
  ✓ API funcional (user: cleberson)

Git:
  ✓ user.name: Cleberson
  ✓ user.email: cleberson@example.com

Resumo:
  ✓ Tudo OK!
```

---

## 🎯 Uso Básico

### Cenário 1: Criar Novo Projeto

```bash
# Estrutura: gl <caminho/do/grupo> <nome-do-projeto>

cd ~/projetos/meu-novo-app
gl atendflow/backend meu-novo-app
```

**O que acontece:**
```
[INFO ] Processando segmento de grupo: 'atendflow'
[INFO ] Processando segmento de grupo: 'atendflow/backend'
[INFO ] Projeto 'meu-novo-app' criado/confirmado
[INFO ] Push realizado com sucesso!

✓ Projeto criado!
URL: https://gitlab.com/atendflow/backend/meu-novo-app
```

**Estrutura criada:**
```
meu-novo-app/
├── .git/
├── .gitignore (gerado automaticamente)
└── (seus arquivos)
```

### Cenário 2: Commit & Push em Projeto Existente

```bash
cd ~/projetos/projeto-existente

# Editar arquivos...
vim src/main.py

# Commit e push
gl
```

**Interação:**

```
[INFO ] Alterações detectadas:
  M src/main.py
  A tests/test_new.py

Mensagem do commit (ou Enter para pular): fix: corrige bug no login

[INFO ] Commit: fix: corrige bug no login
[INFO ] Push realizado com sucesso!
```

### Cenário 3: Criar Merge Request

```bash
# Trabalhando em feature branch
git checkout -b feature/nova-funcionalidade

# Fazer alterações...
vim src/feature.py

# Commit, push e criar MR para main
gl -m
```

**Ou para branch específico:**

```bash
# Push e MR para develop
gl -M develop
```

---

## 🔥 Funcionalidades Avançadas

### Force Push (com Backup Automático)

```bash
# Reescrever histórico com segurança
git commit --amend
gl -f
```

**O que acontece:**
```
[INFO ] Backup criado: ~/.local/share/gl/backups/meu-projeto_20250526_180000.bundle
[WARN ] Push forçado com backup!
[INFO ] Push realizado com sucesso!
```

**Restaurar backup:**

```bash
# Listar backups
ls -lh ~/.local/share/gl/backups/

# Restaurar
git clone ~/.local/share/gl/backups/meu-projeto_20250526_180000.bundle meu-projeto-restaurado
cd meu-projeto-restaurado
git remote set-url origin git@gitlab.com:grupo/projeto.git
```

### Push para Branch Específico

```bash
# Você está em: feature/nova-feature
# Quer enviar para: develop

gl -b develop
```

### Combinando Opções

```bash
# Force push + MR para develop
gl -f -M develop

# Push para staging + MR para main
gl -b staging -m

# Verbose mode (debug)
gl -v -m
```

### Modo Verbose (Debug)

```bash
gl -v
```

**Saída detalhada:**
```
[DEBUG] API GET /user -> 200
[DEBUG] API Response Body: {"id":123,"username":"cleberson"}
[INFO ] Commit: fix: corrige bug
[DEBUG] API POST /projects/456/merge_requests -> 201
```

---

## 🤖 Auto-commit (Daemon)

Automatiza commits e pushes para múltiplos repositórios.

### Setup Rápido

#### 1. Adicionar Repositórios ao Monitoramento

```bash
# Adicionar repo atual
cd ~/projetos/backend-api
gl --add-watch .

# Adicionar múltiplos
cd ~/projetos/frontend
gl --add-watch .

cd ~/projetos/mobile-app
gl --add-watch .
```

#### 2. Listar Repositórios Monitorados

```bash
gl --list-watch
```

**Saída:**

```
Repositórios Monitorados:
  • /home/cleberson/projetos/backend-api
  • /home/cleberson/projetos/frontend
  • /home/cleberson/projetos/mobile-app
```

#### 3. Testar Manualmente

```bash
gl --daemon
```

**Saída:**

```
[INFO ] Iniciando daemon mode...
[INFO ] Processando: backend-api (3 alterações)
[INFO ] ✓ backend-api
[INFO ] Processando: frontend (1 alteração)
[INFO ] ✓ frontend
[INFO ] Daemon concluído: 2 repos processados, 0 erros
```

### Configurar Cron Job

#### Opção 1: Auto-commit Diário (18h)

```bash
crontab -e
```

Adicionar:
```cron
# gl - Auto-commit diário às 18h
0 18 * * * /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

#### Opção 2: A Cada 30 Minutos (horário comercial)

```cron
# gl - Auto-commit a cada 30min (9h-18h, Seg-Sex)
*/30 9-18 * * 1-5 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

#### Opção 3: Múltiplos Horários

```cron
# Segunda a Sexta: 9h, 12h, 17h
0 9,12,17 * * 1-5 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1

# Sábado: 10h apenas
0 10 * * 6 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

### Exemplo de Crontab Completo

```bash
crontab -e
```

```cron
# gl - Auto-commit daemon
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin

# Diário às 18h (commit do dia)
0 18 * * * /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1

# A cada 2 horas durante expediente
0 9-18/2 * * 1-5 /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1

# Backup semanal dos backups (domingo à meia-noite)
0 0 * * 0 tar -czf ~/backups/gl-backups-$(date +\%Y\%m\%d).tar.gz ~/.local/share/gl/backups/

# Limpeza de logs antigos (mensalmente)
0 0 1 * * find ~/.local/share/gl -name "*.log" -mtime +30 -delete
```

### Verificar Logs do Cron

```bash
# Ver últimas execuções
tail -f ~/.local/share/gl/cron.log

# Ver log detalhado do daemon
tail -f ~/.local/share/gl/gl.log

# Ver execuções do cron no sistema
grep gl /var/log/syslog | tail -20
```

### Remover Repositório do Monitoramento

```bash
# Editar manualmente
vim ~/.config/gl/watched-repos.txt

# Ou remover linha específica
sed -i '/\/caminho\/para\/repo/d' ~/.config/gl/watched-repos.txt
```

---

## 📝 Templates

Crie e reutilize estruturas de projetos.

### Criar Template

```bash
# 1. Estruturar seu projeto modelo
cd ~/templates/python-api
mkdir -p src tests
touch src/__init__.py tests/__init__.py README.md

# 2. Adicionar arquivos
cat > requirements.txt << EOF
fastapi==0.104.0
uvicorn==0.24.0
pydantic==2.5.0
EOF

cat > .gitignore << EOF
__pycache__/
*.pyc
.venv/
.env
EOF

cat > README.md << EOF
# Python API Template

## Setup
\`\`\`bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
\`\`\`
EOF

# 3. Criar template no GitLab
gl -c python-api
```

**Resultado:**
```
[INFO ] Criando grupo: templates
[INFO ] Projeto 'python-api' criado/confirmado
[INFO ] Push realizado com sucesso!
```

### Usar Template

```bash
# Criar novo projeto usando template
cd ~/projetos/novo-projeto
gl -t python-api atendflow/backend novo-projeto
```

**O que acontece:**
1. ✅ Clona estrutura do template
2. ✅ Remove histórico Git do template
3. ✅ Cria novo projeto no GitLab
4. ✅ Inicializa novo repositório
5. ✅ Faz primeiro commit

### Templates Úteis (Exemplos)

#### Template Python FastAPI

```bash
cd ~/templates/python-fastapi
```

```
python-fastapi/
├── src/
│   ├── __init__.py
│   ├── main.py
│   ├── api/
│   │   └── v1/
│   └── core/
│       └── config.py
├── tests/
│   └── __init__.py
├── .env.example
├── .gitignore
├── requirements.txt
├── README.md
└── Dockerfile
```

```bash
gl -c python-fastapi
```

#### Template React TypeScript

```bash
cd ~/templates/react-typescript
```

```
react-typescript/
├── src/
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   ├── utils/
│   └── App.tsx
├── public/
├── .gitignore
├── package.json
├── tsconfig.json
└── README.md
```

```bash
gl -c react-typescript
```

#### Template Dagster ETL

```bash
cd ~/templates/dagster-pipeline
```

```
dagster-pipeline/
├── dagster_pipeline/
│   ├── __init__.py
│   ├── assets/
│   ├── resources/
│   └── schedules/
├── tests/
├── pyproject.toml
└── README.md
```

```bash
gl -c dagster-pipeline
```

---

## 🛠️ Troubleshooting

### Problema: "Token não configurado"

```bash
# Reconfigurar token
gl --set-token
```

Ou executar setup completo:
```bash
gl --setup
```

### Problema: "API retornou 401"

**Causa:** Token inválido, expirado ou com scopes insuficientes.

**Solução:**
```bash
# 1. Verificar diagnóstico
gl --doctor

# 2. Gerar novo token no GitLab:
# Settings → Access Tokens
# Scopes: api, read_user, write_repository

# 3. Reconfigurar
gl --set-token
```

### Problema: "Rate limit atingido"

**Causa:** Muitas requisições à API em curto período.

**Comportamento:** `gl` aguarda automaticamente e reprocessa.

**Verificar limites:**
```bash
TOKEN=$(cat ~/.config/gl/token.enc 2>/dev/null || gl --set-token)
curl -H "PRIVATE-TOKEN: $TOKEN" \
  https://gitlab.com/api/v4/user | \
  grep -i ratelimit
```

**Solução:** Reduzir frequência do daemon:
```cron
# Ao invés de a cada 30min, usar a cada 2h
0 */2 * * * gl --daemon
```

### Problema: "Histórico divergente"

```bash
[ERROR] Histórico divergente! Execute: git pull --rebase
```

**Solução:**
```bash
# Opção 1: Rebase (recomendado)
git pull --rebase
gl

# Opção 2: Merge
git pull
gl

# Opção 3: Force push (CUIDADO!)
gl -f
```

### Problema: Backup não está funcionando

```bash
# Verificar configuração
cat ~/.config/gl/config.json | jq .backup_before_force

# Se retornar "false", ativar:
gl --setup
# Escolher "Y" para backup
```

Ou editar manualmente:
```bash
jq '.backup_before_force = "true"' ~/.config/gl/config.json > /tmp/config.json
mv /tmp/config.json ~/.config/gl/config.json
```

### Problema: Daemon não executa no cron

```bash
# 1. Verificar cron
crontab -l

# 2. Testar com mesmo PATH do cron
env -i SHELL=/bin/bash PATH=/usr/local/bin:/usr/bin:/bin /usr/local/bin/gl --daemon

# 3. Ver log de erros do cron
tail -f ~/.local/share/gl/cron.log

# 4. Ver erros do sistema
grep gl /var/log/syslog | tail -20

# 5. Adicionar PATH absoluto no crontab
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
0 18 * * * /usr/local/bin/gl --daemon >> ~/.local/share/gl/cron.log 2>&1
```

### Problema: "Comando 'gl' não encontrado"

**Causa:** PATH não configurado.

**Solução:**
```bash
# Verificar onde está instalado
which gl
# Ou
find /usr -name gl 2>/dev/null

# Se estiver em ~/.local/bin
export PATH="$PATH:$HOME/.local/bin"

# Adicionar permanentemente
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Problema: Dependências faltando

```bash
gl --doctor
```

**Se aparecer faltando:**
```bash
# Debian/Ubuntu
sudo apt update && sudo apt install git curl jq openssl

# Arch Linux
sudo pacman -S git curl jq openssl

# macOS
brew install git curl jq openssl
```

### Problema: GitLab self-hosted com certificado auto-assinado

```bash
# Desabilitar verificação SSL (não recomendado para produção)
git config --global http.sslVerify false

# Ou adicionar certificado
sudo cp seu-certificado.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

---

## 📚 Referência Rápida

### Comandos Principais

```bash
# Setup e manutenção
gl --setup              # Configuração inicial
gl --doctor             # Diagnóstico
gl --set-token          # Atualizar token
gl --version            # Mostrar versão

# Operações Git
gl                      # Commit + push (interativo)
gl -m                   # + criar MR para main
gl -M develop           # + criar MR para develop
gl -f                   # Force push (com backup)
gl -b staging           # Push para branch específico
gl -v                   # Modo verbose (debug)

# Daemon
gl --daemon             # Executar uma vez
gl --add-watch .        # Adicionar repo ao monitoramento
gl --list-watch         # Listar repos monitorados

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
```

### Formato de Commit (Conventional Commits)

O `gl` automaticamente adiciona prefixo se necessário:

```
feat: Nova funcionalidade
fix: Correção de bug
docs: Documentação
style: Formatação
refactor: Refatoração
test: Testes
chore: Manutenção
perf: Performance
```

**Exemplos:**
```bash
# Você digita:
"adiciona endpoint de login"

# gl converte para:
"chore: adiciona endpoint de login"
```

### Atalhos Úteis

```bash
# Alias para .bashrc / .zshrc
alias glp='gl'                    # Push rápido
alias glm='gl -m'                 # Push + MR
alias gld='gl -M develop'         # Push + MR para develop
alias glf='gl -f'                 # Force push
alias gls='gl --doctor'           # Status/health check
alias glw='gl --add-watch .'      # Watch repo atual
```

### Variáveis de Ambiente

```bash
# Sobrescrever configurações (opcional)
export GL_GITLAB_HOST="gitlab.com"
export GL_LOG_LEVEL=3              # 0=ERROR, 1=WARN, 2=INFO, 3=DEBUG
export GL_CONFIG_DIR="$HOME/.config/gl"
```

---

## 🎨 Exemplos de Workflow

### Workflow 1: Desenvolvimento Diário

```bash
# 09:00 - Iniciar nova feature
cd ~/projetos/backend-api
git checkout -b feature/nova-api

# 10:30 - Commit intermediário
vim src/api.py
gl

# 12:00 - Mais trabalho
vim tests/test_api.py
gl

# 17:00 - Finalizar e criar MR
gl -M develop
```

### Workflow 2: Setup de Novo Cliente

```bash
# Criar estrutura
mkdir -p ~/clientes/novo-cliente/{backend,frontend,mobile}

# Backend
cd ~/clientes/novo-cliente/backend
gl -t python-fastapi novo-cliente/backend api-service

# Frontend
cd ~/clientes/novo-cliente/frontend
gl -t react-typescript novo-cliente/frontend web-app

# Mobile
cd ~/clientes/novo-cliente/mobile
gl -t react-native novo-cliente/mobile mobile-app

# Adicionar todos ao monitoramento
cd ~/clientes/novo-cliente
for dir in backend frontend mobile; do
    cd $dir && gl --add-watch . && cd ..
done
```

### Workflow 3: Hotfix em Produção

```bash
cd ~/projetos/backend-api

# Criar branch de hotfix
git checkout main
git checkout -b hotfix/critical-bug

# Corrigir
vim src/bug.py
git add .
git commit -m "fix: corrige bug crítico em produção"

# Push e MR urgente
gl -M main

# Após merge, voltar para develop
git checkout develop
git pull
```

### Workflow 4: Migração de Projeto Existente

```bash
# Projeto sem Git
cd ~/projetos/projeto-legado

# Inicializar e enviar para GitLab
gl empresa/legacy projeto-legado

# Adicionar ao monitoramento
gl --add-watch .
```

### Workflow 5: Multi-repo com Daemon

```bash
# Setup inicial de múltiplos projetos
PROJECTS=(
    "~/projetos/backend-api"
    "~/projetos/frontend"
    "~/projetos/mobile"
    "~/projetos/docs"
)

for project in "${PROJECTS[@]}"; do
    cd "$project" && gl --add-watch .
done

# Configurar cron para commits automáticos
crontab -e
# Adicionar: 0 18 * * * gl --daemon

# Trabalhar normalmente nos projetos
# Às 18h, tudo será commitado e enviado automaticamente
```

---

## 🔒 Segurança

### Armazenamento do Token

O `gl` armazena o token de forma segura:

1. **Linux (GNOME):** GNOME Keyring (criptografado pelo sistema)
2. **macOS:** Keychain (criptografado pelo sistema)
3. **Outros:** AES-256-CBC em `~/.config/gl/token.enc`

### Permissões do Token GitLab

Token deve ter apenas os scopes necessários:
- ✅ `api` - Acesso completo à API
- ✅ `read_user` - Ler informações do usuário
- ✅ `write_repository` - Push para repositórios

**Não adicione scopes desnecessários!**

### Boas Práticas

```bash
# 1. Nunca commitar arquivos de configuração
echo ".config/gl/" >> ~/.gitignore

# 2. Renovar token periodicamente (a cada 90 dias)
gl --set-token

# 3. Usar tokens com escopo mínimo
# Se só faz push: apenas write_repository é suficiente

# 4. Backups do config (sem token!)
cp ~/.config/gl/config.json ~/backups/gl-config-$(date +%Y%m%d).json

# 5. Verificar saúde regularmente
gl --doctor
```

### Auditoria

```bash
# Ver últimos commits automatizados
grep "auto-commit" ~/.local/share/gl/gl.log | tail -20

# Ver últimas execuções do daemon
tail -50 ~/.local/share/gl/cron.log

# Ver histórico de pushes forçados (com backups)
ls -lht ~/.local/share/gl/backups/ | head -10
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas!

### Setup de Desenvolvimento

```bash
# Fork e clone
git clone https://github.com/seu-usuario/gl.git
cd gl

# Criar branch
git checkout -b feature/minha-feature

# Editar
vim gl

# Testar
./gl --doctor
./gl --help

# Commit
./gl -m

# Push e abrir PR
./gl -M main
```

### Diretrizes

- ✅ Seguir estilo de código existente
- ✅ Adicionar comentários para lógica complexa
- ✅ Testar em múltiplos ambientes (Debian, Arch, macOS)
- ✅ Atualizar README se adicionar funcionalidades
- ✅ Usar Conventional Commits

### Reportar Bugs

[Abrir issue](https://github.com/seu-repo/gl/issues) com:
- Versão do `gl` (`gl --version`)
- Sistema operacional
- Saída do `gl --doctor`
- Passos para reproduzir
- Logs relevantes

---

## 📄 Licença

MIT License - Veja [LICENSE](LICENSE)

---

## 🆘 Suporte

- 🐛 **Issues:** https://github.com/seu-repo/gl/issues
- 💬 **Discussões:** https://github.com/seu-repo/gl/discussions
- 📖 **Wiki:** https://github.com/seu-repo/gl/wiki
- 📧 **Email:** suporte@example.com

---

## ⭐ Roadmap

### v4.1 (Próximo)
- [ ] Interface TUI interativa (ncurses)
- [ ] Suporte a GitHub
- [ ] Hooks customizáveis (pre-commit, post-push)
- [ ] Integração com CI/CD

### v5.0 (Futuro)
- [ ] Dashboard web
- [ ] Suporte a múltiplos remotes
- [ ] Plugin system
- [ ] Auto-update

---

## 🎯 FAQ

### Por que usar `gl` ao invés do Git direto?

- ✅ Automatiza tarefas repetitivas
- ✅ Cria estrutura de grupos automaticamente
- ✅ Integração nativa com GitLab (MRs, etc)
- ✅ Auto-commit para múltiplos projetos
- ✅ Backups automáticos em force push
- ✅ Conventional commits automático

### `gl` funciona com GitHub?

Atualmente não, mas está no roadmap (v4.1). Por enquanto, apenas GitLab.

### Posso usar em repositórios existentes?

Sim! `gl` detecta automaticamente se é projeto novo ou existente.

### É seguro usar force push?

Com `gl` sim, pois cria backup automático antes. Você sempre pode restaurar.

### O daemon commita tudo automaticamente?

Sim, todos os repos em `~/.config/gl/watched-repos.txt` são processados. Você controla quais adicionar.

### Posso usar em projetos privados?

Sim, `gl` respeita a visibilidade configurada (private por padrão).

---

## 📊 Estatísticas

```
Linhas de código:    ~1000
Linguagem:           100% Bash
Dependências:        4 (git, curl, jq, openssl)
Tamanho:             ~45KB
Tempo de execução:   <1s (operações típicas)
```

---

## 🙏 Agradecimentos

- Comunidade GitLab
- Contribuidores do projeto
- Usuários que reportaram bugs e sugeriram melhorias

---

## 📝 Changelog

### v4.0 (2025-05-26)
- ✨ Release inicial
- ✨ Setup wizard
- ✨ Daemon mode para auto-commit
- ✨ Sistema de templates
- ✨ Backup automático em force push
- ✨ Suporte a GNOME Keyring e macOS Keychain
- ✨ Rate limiting com retry automático
- ✨ Conventional commits automático
- ✨ Doctor para diagnóstico

---

**Feito com ❤️ por [Cleberson](https://github.com/seu-usuario)**

⭐ Se este projeto te ajudou, considere dar uma estrela!

```bash
# Start automating now!
gl --setup
```
```

README completo com:
- ✅ Quick start
- ✅ Instalação detalhada
- ✅ Todos os cenários de uso
- ✅ Troubleshooting completo
- ✅ Exemplos práticos
- ✅ Workflows reais
- ✅ FAQ
- ✅ Segurança
- ✅ Contribuição

Tudo pronto para publicação! 🚀
