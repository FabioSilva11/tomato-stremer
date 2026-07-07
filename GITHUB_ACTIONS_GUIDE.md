# 🚀 Guia GitHub Actions - Build Automático e Releases

## ✅ O Que Foi Configurado

### Workflows Criados

1. **build-release.yml** - Build de produção com release
2. **build-debug.yml** - Build de desenvolvimento para testes

### O Que Acontece Automaticamente

- ✅ Compila APK com ofuscação ProGuard
- ✅ Cria release no GitHub
- ✅ Faz upload do APK para download
- ✅ Gera changelog automático
- ✅ Mantém símbolos de debug por 90 dias

---

## 📋 Pré-requisitos

### 1. Repositório no GitHub

```bash
# Se ainda não tem repositório
git init
git add .
git commit -m "Initial commit - Tomato Streaming App"

# Criar repositório no GitHub e conectar
git remote add origin https://github.com/SEU_USUARIO/tomato_streaming.git
git branch -M main
git push -u origin main
```

### 2. Configurar GitHub Token (Opcional)

O GitHub Actions já tem um token automático (`GITHUB_TOKEN`) que funciona para releases públicas. Para repositórios privados ou funcionalidades extras, você pode criar um token personalizado:

1. Vá em **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Clique em **Generate new token**
3. Dê um nome: `GitHub Actions`
4. Selecione scopes:
   - ✅ `repo` (acesso completo)
   - ✅ `workflow`
5. Copie o token
6. No repositório: **Settings** → **Secrets and variables** → **Actions**
7. Clique em **New repository secret**
8. Nome: `GH_TOKEN`
9. Valor: Cole o token

---

## 🎯 Como Usar

### Método 1: Criar Release com Tag

Esta é a forma **RECOMENDADA** para produção:

```bash
# 1. Fazer suas alterações
git add .
git commit -m "feat: nova funcionalidade"

# 2. Criar tag de versão
git tag -a v1.0.0 -m "Release v1.0.0 - Primeira versão"

# 3. Enviar para GitHub (isso dispara o build)
git push origin main --tags
```

**O que acontece:**
1. GitHub Actions detecta a tag `v1.0.0`
2. Compila o APK automaticamente
3. Cria uma release com o nome "Tomato Streaming v1.0.0"
4. Faz upload do APK para download
5. Você e usuários podem baixar direto do GitHub

### Método 2: Execução Manual

Ideal para testes rápidos:

1. Vá no seu repositório no GitHub
2. Clique em **Actions**
3. Selecione **Build and Release APK**
4. Clique em **Run workflow**
5. Escolha a branch
6. Clique em **Run workflow**

### Método 3: Push Automático (Debug)

Para branches de desenvolvimento:

```bash
# Fazer commit e push normalmente
git add .
git commit -m "fix: correção de bug"
git push origin main
```

**O que acontece:**
- Build de debug é criado automaticamente
- APK fica disponível em **Actions** → **Artifacts**
- Ideal para testar antes de criar release

---

## 📦 Versionamento

### Como funciona

A versão é lida do arquivo `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- `1.0.0` = Versão pública
- `+1` = Build number

### Esquema de Versionamento

Use **Semantic Versioning** (SemVer):

- **MAJOR.MINOR.PATCH**
  - `MAJOR`: Mudanças incompatíveis (2.0.0)
  - `MINOR`: Novas funcionalidades (1.1.0)
  - `PATCH`: Correções de bugs (1.0.1)

### Exemplos

```bash
# Primeira release
git tag -a v1.0.0 -m "Release inicial"

# Correção de bug
git tag -a v1.0.1 -m "Correção de crash no player"

# Nova funcionalidade
git tag -a v1.1.0 -m "Adicionado modo offline"

# Mudança grande (breaking change)
git tag -a v2.0.0 -m "Nova arquitetura com autenticação"
```

### Atualizar Versão

1. **Editar pubspec.yaml:**
```yaml
version: 1.1.0+2  # Incrementar versão
```

2. **Commit e tag:**
```bash
git add pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main --tags
```

---

## 📥 Baixar APK

### Para Usuários

1. Vá em **Releases** no repositório
2. Clique na versão desejada (ex: v1.0.0)
3. Em **Assets**, baixe o APK
4. Instale no Android

**Link direto:**
```
https://github.com/SEU_USUARIO/tomato_streaming/releases
```

### Para Desenvolvedores (Debug Builds)

1. Vá em **Actions**
2. Clique na execução desejada
3. Role até **Artifacts**
4. Baixe o APK de debug

---

## 🔍 Monitorar Builds

### Ver Status

1. Vá em **Actions** no repositório
2. Veja lista de execuções
3. Clique em uma para ver detalhes
4. Verde ✅ = Sucesso
5. Vermelho ❌ = Falhou

### Badges no README

Adicione ao README.md:

```markdown
![Build Status](https://github.com/SEU_USUARIO/tomato_streaming/workflows/Build%20and%20Release%20APK/badge.svg)
```

---

## 🐛 Solução de Problemas

### Build Falha: "Flutter SDK not found"

**Causa:** Versão do Flutter no workflow não existe

**Solução:** Atualizar versão em `build-release.yml`:
```yaml
flutter-version: '3.24.5'  # Usar versão estável
```

### Build Falha: "Dependency error"

**Causa:** Dependência incompatível

**Solução:**
1. Testar localmente primeiro: `flutter pub get`
2. Corrigir conflitos
3. Commitar e tentar novamente

### Release não cria

**Causa:** Tag já existe

**Solução:**
```bash
# Deletar tag local e remota
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# Criar novamente
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### APK não aparece em Assets

**Causa:** Permissões insuficientes

**Solução:**
1. Ir em **Settings** → **Actions** → **General**
2. Em **Workflow permissions**, selecionar **Read and write permissions**
3. Salvar
4. Re-executar workflow

---

## 🔒 Segurança

### Informações Sensíveis

**NUNCA COMMITE:**
- ❌ Keystores (`.jks`, `.keystore`)
- ❌ Senhas
- ❌ Tokens de API privados
- ❌ Credenciais

**Use GitHub Secrets para:**
- ✅ Senha do keystore
- ✅ API keys privadas
- ✅ Tokens de serviços

### Configurar Secrets

1. **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret**
3. Adicionar:
   - `KEYSTORE_PASSWORD`
   - `KEY_ALIAS`
   - `KEY_PASSWORD`

### Usar no Workflow

```yaml
- name: Sign APK
  env:
    KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
  run: ./sign_apk.sh
```

---

## 📊 Logs e Debug

### Ver Logs Detalhados

1. **Actions** → Clique na execução
2. Clique em **Build APK Release**
3. Expanda etapas para ver logs
4. Procure por erros em vermelho

### Download de Logs

1. Na execução, clique em **⋮** (três pontos)
2. **Download log archive**
3. Extrair e analisar

---

## 🚀 Workflow Avançado

### Build Multi-APK (Split por ABI)

Modificar em `build-release.yml`:

```yaml
- name: Build APK (Split by ABI)
  run: flutter build apk --release --split-per-abi --obfuscate
```

Gera APKs separados:
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit)
- `app-x86_64-release.apk` (emuladores)

### Build AAB (Google Play)

```yaml
- name: Build AAB
  run: flutter build appbundle --release --obfuscate
```

Upload para Google Play Console

---

## 📅 Cronograma de Release Sugerido

### Desenvolvimento
```bash
# Trabalho diário
git commit -m "feat: nova feature"
git push origin develop
# → Build debug automático
```

### Staging/Beta
```bash
# Quando pronto para testar
git checkout main
git merge develop
git tag -a v1.0.0-beta.1 -m "Beta 1"
git push origin main --tags
# → Build release beta
```

### Produção
```bash
# Quando testado e aprovado
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin main --tags
# → Build release final
```

---

## 📈 Métricas

### Ver Estatísticas

1. **Insights** → **Community**
2. Ver downloads de releases
3. Ver clones do repositório

### Analytics

GitHub não mostra downloads diretos, mas você pode:
1. Usar **GitHub API** para contar downloads
2. Adicionar analytics no APK (Firebase, etc.)

---

## ✅ Checklist Pré-Release

Antes de criar uma tag de release:

- [ ] Atualizar versão em `pubspec.yaml`
- [ ] Atualizar CHANGELOG.md
- [ ] Testar app localmente
- [ ] Verificar que `useTestAds: false`
- [ ] Verificar IDs de produção
- [ ] Commit e push de todas mudanças
- [ ] Criar tag com mensagem descritiva
- [ ] Push tag para GitHub
- [ ] Aguardar build (5-10 minutos)
- [ ] Verificar release criada
- [ ] Baixar e testar APK
- [ ] Atualizar README com nova versão

---

## 🎯 Exemplo Completo

```bash
# 1. Trabalhar na feature
git checkout -b feature/new-player
# ... fazer alterações ...
git add .
git commit -m "feat: adicionar controles avançados no player"
git push origin feature/new-player

# 2. Abrir Pull Request no GitHub
# ... revisão de código ...
# ... aprovar e merge ...

# 3. Atualizar versão
git checkout main
git pull origin main
# Editar pubspec.yaml: version: 1.1.0+2
git add pubspec.yaml
git commit -m "chore: bump version to 1.1.0"

# 4. Criar release
git tag -a v1.1.0 -m "Release v1.1.0

Novidades:
- Controles avançados no player
- Botões de ±10 segundos
- Melhorias de performance"

git push origin main --tags

# 5. Aguardar GitHub Actions
# Ir em Actions e monitorar build

# 6. Quando completo, verificar Releases
# Baixar APK e testar

# 7. Anunciar release
# Criar post, tweet, etc.
```

---

## 🆘 Suporte

### Recursos

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Semantic Versioning](https://semver.org)

### Problemas Comuns

1. **Build muito lento?**
   - Ativar cache: `cache: true` no setup-flutter
   
2. **Falta de espaço?**
   - GitHub Actions tem 2GB de espaço
   - Limpar cache antigo

3. **Timeout?**
   - Aumentar timeout no workflow
   - Otimizar dependencies

---

## 🎉 Pronto!

Agora você tem um sistema completo de CI/CD:

- ✅ Builds automáticos
- ✅ Releases no GitHub
- ✅ APKs sempre disponíveis
- ✅ Versionamento organizado
- ✅ Processo profissional

**Próximo passo:** Criar sua primeira tag e release!

```bash
git tag -a v1.0.0 -m "🎉 Primeira release oficial!"
git push origin main --tags
```

---

*Última atualização: Janeiro 2025*
*Versão do guia: 1.0*
