# 🚀 Quick Start - Comece Aqui!

## ⚡ 3 Passos para Rodar

### 1️⃣ Instalar Dependências

```bash
flutter pub get
```

### 2️⃣ Executar em Modo de Teste

```bash
flutter run
```

### 3️⃣ Testar Funcionalidades

- ✅ Assista 2 vídeos para ver anúncio
- ✅ Use botões ⏪/⏩ no player
- ✅ Favorite um anime para receber notificações

---

## 🎯 Antes de Publicar

### Configurar Unity Ads (IMPORTANTE!)

1. **Criar conta**: https://dashboard.unity3d.com
2. **Criar projeto de monetização**
3. **Copiar Game ID** (ex: `5740617`)
4. **Atualizar código**:

```dart
// Em lib/core/ads/ad_manager.dart (linha ~30)
static const String _unityGameIdAndroid = 'SEU_GAME_ID_AQUI';
```

### Desativar Modo de Teste

```dart
// Em lib/main.dart (linha ~16)
await AdManager().initialize(useTestAds: false); // Mudar para false
```

### Build Release

```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

---

## 📊 IDs Já Configurados

### ✅ AdMob (Pronto para Usar)
- App ID: `ca-app-pub-6598765502914364~1736433666`
- Rewarded: `ca-app-pub-6598765502914364/1896215768`
- Banner: `ca-app-pub-6598765502914364/2213698978`

### ⚠️ Unity Ads (Precisa Configurar)
- Game ID: `5740617` ← **SUBSTITUA**
- Rewarded: `Rewarded_Android`
- Banner: `Banner_Android`

---

## 🧪 Testar Anúncios

### Com IDs de Teste (Atual)
```dart
useTestAds: true  // Anúncios de teste do Google
```

**Resultado**: Anúncios de teste aparecem instantaneamente

### Com IDs Reais
```dart
useTestAds: false  // Seus anúncios
```

**Aguarde**: 1-2 horas para novos Ad Units ficarem ativos

---

## 🎮 Funcionalidades Implementadas

### 1. Player com Controles Avançados
- ⏪ Voltar 10 segundos
- ⏩ Avançar 10 segundos
- ▶️ Play/Pause

### 2. Anúncios Inteligentes
- AdMob + Unity Ads (redundância)
- Rotação 50/50 automática
- Fallback se um falhar
- Banners na home

### 3. Notificações
- Novos episódios de favoritos
- Verificação a cada 6 horas
- Notificação local

### 4. Segurança
- Criptografia AES-256
- ProGuard ofuscação
- Token seguro
- Código protegido

---

## 📱 Fluxo de Uso

1. **Usuário abre app**
2. **Navega pela home** (vê banner)
3. **Assiste vídeo** (usa botões ±10s)
4. **Assiste 2º vídeo**
5. **Ao tentar 3º**: Anúncio aparece
6. **Favorite anime**: Recebe notificações

---

## 🐛 Problemas Rápidos

### Anúncios não aparecem?
```bash
# 1. Verificar logs
flutter run

# 2. Usar modo teste
useTestAds: true

# 3. Aguardar se usando IDs reais
```

### Build falha?
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Unity Ads não funciona?
1. Verificar Game ID
2. Criar placements no dashboard
3. Aguardar 15-30 minutos

---

## 📚 Documentação Completa

| Arquivo | Conteúdo |
|---------|----------|
| **IMPLEMENTATION_SUMMARY.md** | 📋 Resumo completo |
| **AD_REDUNDANCY_GUIDE.md** | 🎯 Guia de anúncios |
| **SECURITY_IMPLEMENTATION.md** | 🔒 Segurança |
| **ADMOB_SETUP.md** | 📱 Setup AdMob |
| **ADMOB_POLICIES.md** | ⚖️ Políticas |

---

## ✅ Checklist Final

Antes de publicar:

- [ ] Unity Game ID configurado
- [ ] `useTestAds: false`
- [ ] Testado com IDs reais
- [ ] Build release gerado
- [ ] Testado em dispositivo
- [ ] Política de Privacidade atualizada
- [ ] Anúncios funcionando
- [ ] Notificações funcionando
- [ ] Player testado

---

## 🆘 Precisa de Ajuda?

### Ver Estatísticas

```dart
final stats = AdManager().getStats();
print(stats);
```

### Logs Úteis

```
🎯 Inicializando...
✅ AdMob: ✓
✅ Unity: ✓
📊 Vídeos: 2
🔄 Plataforma: admob
✅ Anúncio exibido
```

### Suporte

- AdMob: https://support.google.com/admob
- Unity: https://support.unity.com
- Flutter: https://docs.flutter.dev

---

## 🎉 Pronto!

Seu app está com:
- ✅ Anúncios com redundância (AdMob + Unity)
- ✅ Player com controles avançados
- ✅ Notificações de episódios
- ✅ Segurança e criptografia
- ✅ Banners discretos

**Próximo passo**: Configure o Unity Ads e publique! 🚀

---

*Tempo estimado de setup: 15 minutos*
*Dificuldade: ⭐⭐⚪⚪⚪ (Fácil)*
