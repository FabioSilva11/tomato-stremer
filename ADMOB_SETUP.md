# 🚀 Guia de Configuração do AdMob - Passo a Passo

## ✅ O que foi Implementado

### Arquivos Modificados/Criados:
1. ✅ `pubspec.yaml` - Adicionada dependência `google_mobile_ads: ^5.2.0`
2. ✅ `android/app/src/main/AndroidManifest.xml` - Configurado App ID do AdMob
3. ✅ `android/app/build.gradle.kts` - minSdk ajustado para 21
4. ✅ `lib/core/ads/admob_service.dart` - Serviço completo de gerenciamento de anúncios
5. ✅ `lib/main.dart` - Inicialização do AdMob
6. ✅ `lib/features/player/player_page.dart` - Integração com anúncios entre vídeos
7. ✅ `lib/features/home/home_page.dart` - Anúncios ao iniciar episódios

### Funcionalidades Implementadas:
- ✅ Anúncios premiados (rewarded ads) entre vídeos
- ✅ Classificação de conteúdo configurada (Teen 13+)
- ✅ Políticas de frequência (mínimo 2 vídeos ou 5 minutos entre anúncios)
- ✅ Diálogo de confirmação antes dos anúncios
- ✅ Contador de vídeos assistidos
- ✅ Conformidade com políticas do AdMob
- ✅ Sistema de IDs de teste para desenvolvimento

---

## 📋 Próximos Passos para Executar

### 1. Instalar Dependências

Execute no terminal do projeto:

```bash
flutter pub get
```

### 2. Limpar Build (Recomendado)

```bash
flutter clean
flutter pub get
```

### 3. Testar com Anúncios de Teste

#### Opção A: Usar IDs de Teste (Recomendado para Desenvolvimento)

Os IDs de teste já estão configurados. Em `lib/main.dart`, certifique-se que está:

```dart
await AdMobService().initialize(useTestAds: true);
```

#### Opção B: Adicionar Seu Dispositivo de Teste

1. Execute o app uma vez
2. Verifique os logs do Flutter/Android
3. Procure por uma mensagem como:
   ```
   Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("33BE2250B43518CCDA7DE426D04EE231"))
   ```
4. Copie o ID do dispositivo
5. Adicione em `lib/core/ads/admob_service.dart`:
   ```dart
   testDeviceIds: useTestAds ? ['SEU_DEVICE_ID_AQUI'] : [],
   ```

### 4. Executar no Android

```bash
flutter run -d <device_id>
```

Ou pelo Android Studio/VS Code:
- Selecione seu dispositivo
- Pressione F5 ou clique em "Run"

---

## 🧪 Como Testar os Anúncios

### Fluxo de Teste:

1. **Abra o app**
2. **Assista um episódio completo** ou navegue pelo player
3. **Feche o player** (isso incrementa o contador)
4. **Repita 2x** (após 2 vídeos o anúncio deve aparecer)
5. **Ao tentar assistir o 3º vídeo**, você verá:
   - Diálogo perguntando se quer ver anúncio
   - Anúncio premiado do Google (teste)
   - Após assistir, o vídeo carrega normalmente

### Logs para Verificar:

Procure no console:
```
Vídeos assistidos desde último anúncio: 1
Vídeos assistidos desde último anúncio: 2
Anúncio premiado carregado
Anúncio premiado exibido
Usuário assistiu anúncio completo
```

---

## 🔄 Mudando para Produção

### IMPORTANTE: Só faça isso quando publicar no Google Play!

1. **Em `lib/main.dart`**, mude para:
   ```dart
   await AdMobService().initialize(useTestAds: false);
   ```

2. **Remova IDs de teste de `admob_service.dart`**:
   ```dart
   testDeviceIds: [], // Vazio em produção
   ```

3. **Compile versão release**:
   ```bash
   flutter build apk --release
   # ou
   flutter build appbundle --release
   ```

### ⚠️ ATENÇÃO:
- **NUNCA** clique nos próprios anúncios em produção
- **NUNCA** use IDs de teste em produção
- Isso pode resultar em **banimento da conta AdMob**

---

## 📊 Monitoramento no Console do AdMob

### Acessar Console:
1. Vá para [https://apps.admob.com](https://apps.admob.com)
2. Faça login com sua conta Google
3. Selecione seu aplicativo

### O que Verificar:
- **Impressões**: Quantos anúncios foram exibidos
- **Requests**: Quantas solicitações foram feitas
- **Fill Rate**: % de solicitações atendidas
- **Receita**: Ganhos estimados
- **Violações**: **DEVE estar em 0**

### Tempo para Aparecer Dados:
- Primeiros dados: 1-2 horas após exibições
- Relatórios completos: 24 horas
- Pagamentos: Mensal (após atingir US$ 100)

---

## 🎯 Ajustes de Política de Frequência

Para ajustar quando os anúncios aparecem, edite em `lib/core/ads/admob_service.dart`:

```dart
// Configurações atuais
static const int _minVideosBetweenAds = 2; // Anúncio a cada 2 vídeos
static const int _minMinutesBetweenAds = 5; // Mínimo 5 min entre anúncios
```

### Recomendações:
- **Muito frequente** (a cada vídeo): Irritante para usuários
- **Balanceado** (a cada 2-3 vídeos): ✅ **Atual**
- **Pouco frequente** (a cada 5+ vídeos): Menos receita

---

## 🐛 Resolução de Problemas

### Problema: "App ID is not configured"
**Solução**: Verifique se o App ID está no AndroidManifest.xml:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-6598765502914364~1736433666"/>
```

### Problema: Anúncios não aparecem
**Possíveis causas**:
1. Está usando `useTestAds: false` mas os Ad Units são novos (espere 1-2h)
2. Sem conexão com internet
3. Ad Unit ID incorreto
4. Região sem anúncios disponíveis

**Soluções**:
1. Use `useTestAds: true` para testar
2. Verifique conexão
3. Confirme IDs no console do AdMob
4. Teste com VPN em outra região

### Problema: "Ad failed to load (3)"
**Causa**: Sem anúncios disponíveis no momento
**Solução**: Normal durante testes, especialmente com IDs reais em desenvolvimento

### Problema: App não compila
**Solução**:
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

## 📱 Testando em Diferentes Cenários

### Cenário 1: Primeiro Uso
- Anúncio NÃO deve aparecer nos primeiros 2 vídeos
- ✅ Comportamento esperado

### Cenário 2: Uso Contínuo
- Após 2 vídeos, anúncio deve ser oferecido
- Usuário pode recusar
- ✅ Comportamento esperado

### Cenário 3: Uso Espaçado
- Assistiu 1 vídeo, esperou 5+ minutos, assistiu outro
- Anúncio deve ser oferecido
- ✅ Comportamento esperado

### Cenário 4: Recusa de Anúncio
- Usuário pode fechar diálogo
- Vídeo NÃO carrega
- Contador NÃO é resetado
- ✅ Comportamento esperado

---

## 🔐 Conformidade com Políticas

### Checklist Antes de Publicar:

- [ ] App ID correto no AndroidManifest
- [ ] Ad Unit IDs corretos no código
- [ ] `useTestAds: false` em produção
- [ ] Classificação de conteúdo apropriada
- [ ] Política de Privacidade atualizada mencionando AdMob
- [ ] Testado em dispositivo real
- [ ] Sem violações de política
- [ ] Anúncios não bloqueiam conteúdo essencial
- [ ] UX não força cliques em anúncios

### Conteúdo do App:
O app está configurado como **Teen (13+)**. Se o conteúdo mudar:

**Conteúdo Infantil (<13 anos)**:
```dart
maxAdContentRating: MaxAdContentRating.g,
tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
```

**Conteúdo Adulto (18+)**:
```dart
maxAdContentRating: MaxAdContentRating.ma,
```

---

## 💡 Dicas Finais

### Maximizar Receita:
1. **Não exagere na frequência** - usuários frustrados desinstalam
2. **Mantenha UX suave** - diálogo de preparação ajuda
3. **Monitore métricas** - ajuste baseado em dados reais
4. **Considere mediation** - múltiplas redes de anúncios no futuro

### Evitar Banimento:
1. **NUNCA clique nos próprios anúncios**
2. **NUNCA peça para outros clicarem**
3. **NUNCA use bots ou tráfego falso**
4. **NUNCA esconda ou manipule anúncios**
5. **SEMPRE declare conteúdo sensível**

### Suporte:
- Documentação: [pub.dev/packages/google_mobile_ads](https://pub.dev/packages/google_mobile_ads)
- Políticas: [support.google.com/admob/answer/6128543](https://support.google.com/admob/answer/6128543)
- Ajuda: [support.google.com/admob](https://support.google.com/admob)

---

## 📞 Contato de Suporte do AdMob

Se tiver problemas com a conta AdMob:
1. Acesse [Ajuda do AdMob](https://support.google.com/admob)
2. Use o chat ou formulário de contato
3. Forneça App ID e detalhes do problema

---

**Status**: ✅ **Implementação completa e pronta para testes**

**Próximo passo**: Execute `flutter pub get` e teste o app!

---

*Última atualização: 2025-01-07*
