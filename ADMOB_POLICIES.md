# Políticas do AdMob e Configuração

## ℹ️ Informações da Conta AdMob

- **App ID**: `ca-app-pub-6598765502914364~1736433666`
- **Rewarded Ad Unit ID**: `ca-app-pub-6598765502914364/1896215768`

## 📋 Implementação Concluída

### 1. SDK do Google Mobile Ads
✅ Adicionado `google_mobile_ads: ^5.2.0` ao pubspec.yaml
✅ Configurado App ID no AndroidManifest.xml
✅ minSdk ajustado para 21 (requisito do SDK)

### 2. Classificação de Conteúdo (Content Rating)
A app está configurada com as seguintes classificações:

```dart
maxAdContentRating: MaxAdContentRating.t, // Teen (13+)
tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
```

**Opções de classificação:**
- `MaxAdContentRating.g` - General audiences (Todos)
- `MaxAdContentRating.pg` - Parental guidance (Orientação parental)
- `MaxAdContentRating.t` - Teen (13+) **[ATUAL]**
- `MaxAdContentRating.ma` - Mature audiences (Adulto)

### 3. Anúncios Premiados (Rewarded Ads)
✅ Implementado `AdMobService` com gerenciamento completo
✅ Anúncios são exibidos entre vídeos
✅ Políticas de frequência implementadas:
  - Mínimo de 2 vídeos assistidos entre anúncios
  - Mínimo de 5 minutos entre anúncios

### 4. Experiência do Usuário
✅ Diálogo de confirmação antes do anúncio
✅ Anúncios não bloqueiam conteúdo permanentemente
✅ Contador de vídeos assistidos
✅ Sistema de recompensa implementado

## 🔒 Políticas Importantes do AdMob (2024-2025)

### Conteúdo Proibido
❌ **NUNCA** mostre anúncios em páginas com:
- Conteúdo adulto ou sexual
- Conteúdo violento ou chocante
- Conteúdo que promova ódio
- Drogas ou tabaco
- Armas e munições
- Conteúdo falsificado ou enganoso

### Práticas Proibidas
❌ **NUNCA**:
- Force usuários a clicar em anúncios
- Coloque anúncios muito próximos a botões clicáveis
- Incentive cliques acidentais
- Oculte ou manipule anúncios
- Use tráfego artificial ou bots
- Clique em seus próprios anúncios

### Políticas de Implementação
✅ **SEMPRE**:
- Mantenha distância segura entre anúncios e conteúdo
- Use IDs de anúncio corretos (produção vs teste)
- Implemente anúncios naturalmente no fluxo do app
- Respeite a experiência do usuário
- Declare conteúdo sensível corretamente

### COPPA (Children's Online Privacy Protection Act)
Se seu app é direcionado a crianças menores de 13 anos:
```dart
tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
```

## 🧪 Testes

### IDs de Teste do AdMob
Durante desenvolvimento, use IDs de teste oficiais:

```dart
// Em admob_service.dart
await AdMobService().initialize(useTestAds: true);
```

**IDs de Teste Oficiais:**
- Rewarded: `ca-app-pub-3940256099942544/5224354917`
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`

### Adicionar Dispositivos de Teste
1. Execute o app
2. Verifique os logs para encontrar o Device ID
3. Adicione em `admob_service.dart`:
```dart
testDeviceIds: ['SEU_DEVICE_ID_AQUI']
```

## 📱 Uso em Produção

### Passo 1: Desativar Anúncios de Teste
Em `lib/main.dart`, mude para:
```dart
await AdMobService().initialize(useTestAds: false);
```

### Passo 2: Verificar IDs
Confirme que os IDs corretos estão sendo usados:
- ✅ App ID no AndroidManifest.xml
- ✅ Ad Unit IDs em admob_service.dart

### Passo 3: Teste em Dispositivo Real
- Remova o app completamente
- Instale a versão release
- Verifique se anúncios reais aparecem

## 📊 Monitoramento

### Console do AdMob
Acesse [https://apps.admob.com](https://apps.admob.com) para:
- Verificar impressões de anúncios
- Monitorar receita
- Verificar violações de política
- Analisar desempenho

### Métricas Importantes
- **Fill Rate**: % de solicitações atendidas com anúncios
- **Impressions**: Número de anúncios exibidos
- **eCPM**: Receita por 1000 impressões
- **Policy Violations**: Violações de política (ZERO é o ideal!)

## ⚠️ Resolução de Problemas

### Anúncios Não Aparecem
1. Verifique se o App ID está correto no Manifest
2. Confirme que o Ad Unit ID está correto
3. Verifique logs para erros de carregamento
4. Espere 1-2 horas após criar novos Ad Units
5. Teste com IDs de teste primeiro

### Erros Comuns
- **"App ID is not configured"**: App ID faltando no Manifest
- **"Ad failed to load (3)"**: Sem anúncios disponíveis no momento
- **"Invalid Ad Unit ID"**: ID incorreto ou não existente

## 🔄 Atualizações Futuras

### Recursos Opcionais
- [ ] Banner ads (topo/rodapé)
- [ ] Interstitial ads (tela cheia)
- [ ] Native ads (anúncios nativos)
- [ ] App Open ads (ao abrir app)

### Otimizações
- [ ] Mediation (múltiplas redes de anúncios)
- [ ] A/B testing de frequência
- [ ] Analytics de conversão

## 📚 Recursos

- [AdMob Policy Center](https://support.google.com/admob/answer/6128543)
- [Content Rating Documentation](https://support.google.com/admob/answer/7562142)
- [Rewarded Ads Best Practices](https://support.google.com/admob/answer/6066980)
- [Flutter Google Mobile Ads Plugin](https://pub.dev/packages/google_mobile_ads)

## ⚖️ Conformidade Legal

### Privacidade
- Atualize sua Política de Privacidade mencionando uso do AdMob
- Declare que usa Google Ads e Analytics
- Informe sobre cookies e rastreamento

### LGPD/GDPR
- Implemente consentimento de usuário quando necessário
- Use UMP SDK para conformidade europeia se necessário
- Permita que usuários optem por não serem rastreados

### Exemplo de Texto para Política de Privacidade:
```
Este aplicativo usa o Google AdMob para exibir anúncios. O AdMob pode
coletar e processar informações sobre o dispositivo para personalizar
anúncios. Para mais informações, consulte a Política de Privacidade
do Google: https://policies.google.com/privacy
```

---

**Última atualização**: 2025-01-07
**Versão do SDK**: google_mobile_ads ^5.2.0
