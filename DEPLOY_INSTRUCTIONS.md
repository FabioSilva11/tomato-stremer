# 🚀 Instruções de Deploy e Release

## ✅ Status Atual

- ✅ Código pronto para produção
- ✅ IDs de anúncios configurados (AdMob + Unity)
- ✅ Criptografia e segurança implementadas
- ✅ Internacionalização (PT/EN)
- ✅ GitHub Actions configurado
- ✅ Modo de produção ativado (`useTestAds: false`)

---

## 📋 Passo a Passo para Deploy

### 1️⃣ Preparar Repositório GitHub

```bash
# 1. Criar repositório no GitHub (se ainda não tiver)
# Vá em: https://github.com/new
# Nome: tomato_streaming
# Descrição: Aplicativo de streaming de animes
# Privado ou Público (sua escolha)

# 2. No seu computador, navegue até a pasta do projeto
cd C:\Users\kirit\AndroidStudioProjects\tomato_streaming

# 3. Inicializar Git (se ainda não estiver)
git init
git add .
git commit -m "🎉 Initial commit - Tomato Streaming v1.0.0"

# 4. Conectar ao GitHub
git remote add origin https://github.com/SEU_USUARIO/tomato_streaming.git
git branch -M main
git push -u origin main
```

### 2️⃣ Verificar Arquivos Importantes

Certifique-se que estes arquivos estão no repositório:

- ✅ `.github/workflows/build-release.yml`
- ✅ `.github/workflows/build-debug.yml`
- ✅ `.gitignore`
- ✅ `README.md`
- ✅ `CHANGELOG.md`
- ✅ `pubspec.yaml`
- ✅ `l10n.yaml`
- ✅ `lib/l10n/app_en.arb`
- ✅ `lib/l10n/app_pt.arb`

### 3️⃣ Configurar Permissões no GitHub

1. Vá no seu repositório no GitHub
2. Clique em **Settings**
3. No menu lateral, clique em **Actions** → **General**
4. Role até **Workflow permissions**
5. Selecione **Read and write permissions**
6. Marque ✅ **Allow GitHub Actions to create and approve pull requests**
7. Clique em **Save**

### 4️⃣ Criar Primeira Release

```bash
# 1. Criar tag de versão
git tag -a v1.0.0 -m "🎉 Release v1.0.0 - Primeira versão oficial

Funcionalidades:
- Sistema de anúncios com redundância (AdMob + Unity)
- Criptografia AES-256 e ofuscação ProGuard
- Notificações de novos episódios
- Player com controles avançados
- Suporte a PT e EN
- Banners discretos"

# 2. Enviar tag para GitHub
git push origin v1.0.0
```

### 5️⃣ Acompanhar Build

1. Vá em **Actions** no seu repositório
2. Você verá o workflow **Build and Release APK** executando
3. Aguarde 5-10 minutos (primeira vez pode demorar mais)
4. Quando ficar verde ✅, está pronto!

### 6️⃣ Verificar Release

1. Vá em **Releases** no repositório
2. Você verá **Tomato Streaming v1.0.0**
3. Em **Assets**, terá o APK para download
4. Exemplo: `tomato-streaming-v1.0.0.apk`

### 7️⃣ Testar APK

1. Baixe o APK do GitHub
2. Transfira para seu celular Android
3. Instale (habilite "Instalar de fontes desconhecidas" se necessário)
4. Teste todas as funcionalidades:
   - ✅ Player funciona
   - ✅ Botões ±10s funcionam
   - ✅ Anúncios aparecem (após 2 vídeos)
   - ✅ Banners aparecem na home
   - ✅ Notificações funcionam
   - ✅ Favoritos funcionam
   - ✅ Idioma está correto

---

## 🔄 Próximas Releases

### Para Criar Nova Versão

```bash
# 1. Fazer suas alterações
git add .
git commit -m "feat: adicionar nova funcionalidade"
git push origin main

# 2. Atualizar versão em pubspec.yaml
# Antes: version: 1.0.0+1
# Depois: version: 1.1.0+2

git add pubspec.yaml
git commit -m "chore: bump version to 1.1.0"
git push origin main

# 3. Criar nova tag
git tag -a v1.1.0 -m "Release v1.1.0

Novidades:
- Feature X
- Feature Y
- Correção Z"

git push origin v1.1.0

# 4. GitHub Actions compila automaticamente!
```

### Versionamento

Use **Semantic Versioning**:

- **1.0.0** → **1.0.1**: Correção de bugs
- **1.0.0** → **1.1.0**: Nova funcionalidade
- **1.0.0** → **2.0.0**: Mudança grande (breaking change)

---

## 🎯 Distribuição do APK

### Opção 1: GitHub Releases (Recomendado)

**Vantagens:**
- ✅ Grátis
- ✅ Versionamento automático
- ✅ Changelog incluído
- ✅ Downloads rastreáveis

**Como compartilhar:**
```
Link direto: https://github.com/SEU_USUARIO/tomato_streaming/releases/latest
```

### Opção 2: Google Play Store

**Para publicar na Play Store:**

1. **Criar conta de desenvolvedor:**
   - https://play.google.com/console
   - Taxa única: $25 USD

2. **Preparar assets:**
   - Ícone: 512x512px
   - Screenshots: Mínimo 2
   - Banner: 1024x500px
   - Descrição em PT e EN

3. **Gerar AAB (Android App Bundle):**
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

4. **Upload na Play Console:**
   - Criar novo aplicativo
   - Upload do AAB
   - Preencher informações
   - Enviar para revisão (2-7 dias)

### Opção 3: Sites de APK

Sites como APKPure, APKMirror aceitam submissões:
- https://apkpure.com/developer-upload
- Mas requer processo de verificação

---

## 📊 Monitoramento Pós-Deploy

### 1. Verificar Anúncios

**AdMob Console:**
- https://apps.admob.com
- Ver impressões
- Ver receita
- Verificar fill rate

**Unity Dashboard:**
- https://dashboard.unity3d.com
- Ver estatísticas
- Ver eCPM

### 2. Monitorar Crashes

**Usar Firebase Crashlytics (futuro):**
```yaml
# Adicionar ao pubspec.yaml
dependencies:
  firebase_crashlytics: ^latest
```

### 3. Analytics

**Usar Firebase Analytics (futuro):**
```yaml
# Adicionar ao pubspec.yaml
dependencies:
  firebase_analytics: ^latest
```

---

## 🐛 Troubleshooting

### Build Falha no GitHub Actions

**Problema:** Erro de compilação

**Solução:**
1. Verificar logs em Actions
2. Testar localmente primeiro: `flutter build apk --release`
3. Corrigir erros
4. Commit e push novamente

### APK Não Aparece em Release

**Problema:** Assets vazio

**Solução:**
1. Verificar permissões do GitHub Actions (passo 3)
2. Re-executar workflow manualmente
3. Verificar que tag foi criada corretamente

### Anúncios Não Aparecem

**Problema:** AdMob ou Unity não mostra anúncios

**Solução:**
1. Aguardar 1-2 horas (novos Ad Units precisam ser ativados)
2. Verificar IDs em `ad_manager.dart`
3. Ver logs do app: `adb logcat | grep -i "ad"`
4. Verificar se app não está em teste (`useTestAds: false`)

### App Crasha ao Abrir

**Problema:** Crash imediato

**Solução:**
1. Ver logs: `adb logcat`
2. Verificar se ProGuard não removeu código essencial
3. Adicionar regras keep em `proguard-rules.pro`
4. Rebuild

---

## ✅ Checklist Pré-Deploy

Antes de criar release para produção:

### Código
- [ ] `useTestAds: false` em main.dart
- [ ] IDs de produção configurados
- [ ] Versão atualizada em pubspec.yaml
- [ ] CHANGELOG.md atualizado
- [ ] README.md atualizado

### Testes
- [ ] Testado em dispositivo real
- [ ] Anúncios funcionando
- [ ] Player funcionando
- [ ] Notificações funcionando
- [ ] Favoritos funcionando
- [ ] Idiomas testados (PT e EN)

### GitHub
- [ ] Repositório criado
- [ ] Código commitado
- [ ] Workflows copiados
- [ ] Permissões configuradas
- [ ] Tag criada

### Documentação
- [ ] README completo
- [ ] CHANGELOG atualizado
- [ ] Links corretos (substituir SEU_USUARIO)

### Legal
- [ ] Política de Privacidade pronta
- [ ] Termos de Uso prontos
- [ ] Licença definida

---

## 🎉 Parabéns!

Se chegou até aqui, seu app está pronto para o mundo!

### Próximos Passos Sugeridos:

1. **Divulgação:**
   - Criar página no Facebook/Instagram
   - Postar no Reddit (r/androidapps)
   - Enviar para blogs de apps

2. **Feedback:**
   - Criar canal de suporte (Discord, Telegram)
   - Monitorar issues no GitHub
   - Responder reviews

3. **Melhorias:**
   - Implementar analytics
   - Adicionar crashlytics
   - Implementar autenticação
   - Adicionar modo offline

4. **Monetização:**
   - Monitorar receita de anúncios
   - Ajustar frequência se necessário
   - Considerar plano premium (sem anúncios)

---

## 📞 Suporte

Se precisar de ajuda:

1. **Documentação:** Leia os guias em `/docs`
2. **Issues:** Abra issue no GitHub
3. **Community:** Discord/Telegram (se tiver)

---

**Boa sorte com seu app! 🚀**

*Última atualização: Janeiro 2025*
