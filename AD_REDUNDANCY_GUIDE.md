# 🎯 Guia Completo: Sistema de Anúncios com Redundância

## ✅ Sistema Implementado

### Plataformas de Anúncios
1. **AdMob (Google)** - Plataforma principal
2. **Unity Ads** - Redundância/Backup

### Tipos de Anúncios
- ✅ **Rewarded Ads** (Anúncios Premiados) - Entre vídeos
- ✅ **Banner Ads** (Banners) - Na home e outras páginas

---

## 📋 IDs Configurados

### AdMob
- **App ID**: `ca-app-pub-6598765502914364~1736433666`
- **Rewarded Ad Unit**: `ca-app-pub-6598765502914364/1896215768`
- **Banner Ad Unit**: `ca-app-pub-6598765502914364/2213698978`

### Unity Ads
- **Game ID Android**: `5740617` ⚠️ **SUBSTITUA PELO SEU**
- **Rewarded Placement**: `Rewarded_Android`
- **Banner Placement**: `Banner_Android`

---

## 🔄 Como Funciona o Sistema de Rotação

### 1. Inicialização
```dart
await AdManager().initialize(useTestAds: false);
```

- Inicializa ambas as plataformas simultaneamente
- Detecta quais estão disponíveis
- Define plataforma inicial baseada em disponibilidade

### 2. Seleção de Plataforma

O sistema usa **rotação inteligente 50/50** com peso baseado em performance:

```
Taxa de Sucesso = Sucessos / (Sucessos + Falhas)

Se AdMob Taxa > Unity Taxa:
  - 60% chance de usar AdMob
  - 40% chance de usar Unity

Se Unity Taxa > AdMob Taxa:
  - 60% chance de usar Unity
  - 40% chance de usar AdMob

Se iguais:
  - 50% chance cada
```

### 3. Fallback Automático

```
Tentativa 1: Plataforma Selecionada
   ↓ (se falhar)
Tentativa 2: Plataforma Alternativa
   ↓ (se falhar)
Usuário continua sem anúncio
```

**Exemplo de Fluxo:**
1. Sistema seleciona AdMob
2. AdMob falha ao carregar
3. Sistema automaticamente tenta Unity Ads
4. Unity Ads exibe o anúncio
5. Estatísticas são atualizadas

---

## 🎮 Configurando Unity Ads

### Passo 1: Criar Conta Unity

1. Acesse [Unity Dashboard](https://dashboard.unity3d.com)
2. Faça login ou crie conta
3. Vá para **Monetization** → **Projects**
4. Clique em **Add Project**

### Passo 2: Obter Game ID

1. No projeto criado, vá em **Settings**
2. Copie o **Game ID** para Android
3. Exemplo: `5740617`

### Passo 3: Configurar Placement IDs

1. Vá em **Ad Units**
2. Crie placement para **Rewarded Video**:
   - Nome: `Rewarded_Android`
   - Type: Rewarded Video
3. Crie placement para **Banner**:
   - Nome: `Banner_Android`
   - Type: Banner

### Passo 4: Atualizar Código

Em `lib/core/ads/ad_manager.dart`:

```dart
static const String _unityGameIdAndroid = 'SEU_GAME_ID_AQUI';
static const String _unityRewardedId = 'Rewarded_Android';
static const String _unityBannerId = 'Banner_Android';
```

---

## 📱 Testando o Sistema

### Modo de Teste

```dart
// Em main.dart
await AdManager().initialize(useTestAds: true);
```

### IDs de Teste

**AdMob:**
- Rewarded: `ca-app-pub-3940256099942544/5224354917`
- Banner: `ca-app-pub-3940256099942544/6300978111`

**Unity Ads:**
- Automaticamente usa modo de teste quando `testMode: true`

### Verificando Funcionamento

1. **Execute o app**
2. **Assista 2 vídeos**
3. **No 3º vídeo:**
   - Diálogo de anúncio aparece
   - Anúncio é exibido (AdMob ou Unity)
4. **Verifique os logs:**

```
🎯 Inicializando gerenciador de anúncios...
✅ AdMob inicializado com sucesso
✅ Unity Ads inicializado com sucesso
✅ Gerenciador de anúncios inicializado
   - AdMob: ✓
   - Unity: ✓
   - Plataforma atual: admob
📊 Vídeos assistidos: 1
📊 Vídeos assistidos: 2
🔄 Plataforma selecionada: admob
✅ AdMob rewarded ad carregado
✅ Usuário assistiu AdMob ad completo
```

---

## 📊 Monitoramento de Performance

### Ver Estatísticas

```dart
final stats = AdManager().getStats();
print(stats);
```

**Output:**
```json
{
  "admob_available": true,
  "unity_available": true,
  "current_platform": "admob",
  "admob_success": 15,
  "admob_fail": 2,
  "unity_success": 8,
  "unity_fail": 1,
  "videos_watched": 1,
  "last_ad_shown": "2025-01-07T10:30:00.000Z"
}
```

### Interpretação

- **admob_success > admob_fail**: AdMob funcionando bem
- **unity_success > unity_fail**: Unity funcionando bem
- Sistema prefere plataforma com melhor taxa de sucesso

---

## 🎨 Implementando Banners

### 1. Banner Fixo

```dart
// Em qualquer tela
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Expanded(child: YourContent()),
        AdBannerWidget(), // Banner no rodapé
      ],
    ),
  );
}
```

### 2. Banner no Scroll

```dart
CustomScrollView(
  slivers: [
    SliverList(...),
    
    // Banner entre conteúdo
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: AdBannerWidget(),
      ),
    ),
    
    SliverList(...),
  ],
)
```

### 3. Múltiplos Banners

```dart
// Home
SliverToBoxAdapter(
  child: AdBannerWidget(key: Key('banner_1')),
),

// Após algumas seções
SliverToBoxAdapter(
  child: AdBannerWidget(key: Key('banner_2')),
),
```

---

## ⚙️ Configurações Avançadas

### Ajustar Frequência de Anúncios

Em `ad_manager.dart`:

```dart
static const int _minVideosBetweenAds = 2; // Altere aqui
static const int _minMinutesBetweenAds = 5; // Altere aqui
```

**Recomendações:**
- **Baixa frequência**: 3-5 vídeos, 10 minutos
- **Média frequência**: 2-3 vídeos, 5 minutos ⭐ **Atual**
- **Alta frequência**: 1-2 vídeos, 3 minutos

### Ajustar Peso de Rotação

Em `ad_manager.dart` no método `_selectBestPlatform()`:

```dart
// Favorecer AdMob
_currentPlatform = random < 0.7 ? AdPlatform.admob : AdPlatform.unity;

// Favorecer Unity
_currentPlatform = random < 0.3 ? AdPlatform.admob : AdPlatform.unity;

// 50/50 (atual)
_currentPlatform = random < 0.5 ? AdPlatform.admob : AdPlatform.unity;
```

---

## 🐛 Resolução de Problemas

### Problema: Unity Ads não inicializa

**Sintomas:**
```
❌ Erro ao inicializar Unity Ads: INTERNAL_ERROR
```

**Soluções:**
1. Verifique se o Game ID está correto
2. Confirme que o projeto está ativo no Unity Dashboard
3. Aguarde 15-30 minutos após criar projeto
4. Teste com `testMode: true` primeiro

### Problema: AdMob retorna erro 3

**Sintomas:**
```
❌ Erro ao carregar AdMob ad: [Ad failed to load : 3]
```

**Causas:**
- Sem anúncios disponíveis na região
- Ad Unit ID novo (aguardar 1-2 horas)
- Muitas solicitações em curto período

**Soluções:**
1. Use `useTestAds: true`
2. Aguarde algumas horas
3. Unity Ads assume automaticamente

### Problema: Banners não aparecem

**Sintomas:**
- Loading infinito
- Espaço vazio onde deveria ter banner

**Soluções:**
1. Verificar logs para mensagens de erro
2. Confirmar IDs de banner
3. Verificar se ambas plataformas estão configuradas
4. Testar com IDs de teste primeiro

### Problema: App crasha ao mostrar anúncio

**Causas:**
- Anúncio já foi exibido/descartado
- Contexto inválido
- Permissões faltando

**Soluções:**
1. Verificar se `_isRewardedAdReady` está true
2. Carregar novo anúncio após exibir
3. Adicionar try-catch em todas chamadas

---

## 📈 Melhores Práticas

### 1. Balancear Monetização e UX

✅ **Bom:**
- Anúncios entre sessões de uso
- Usuário sabe quando vai ver anúncio
- Pode recusar sem perder funcionalidade essencial

❌ **Ruim:**
- Anúncios em excesso
- Pop-ups inesperados
- Bloquear conteúdo atrás de anúncios

### 2. Transparência

```dart
// Sempre avisar antes do anúncio
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Anúncio'),
    content: Text('Assista um anúncio para continuar...'),
  ),
);
```

### 3. Fallback Gracioso

```dart
// Se anúncios falharem, não bloquear usuário
if (!adShown) {
  // Usuário pode continuar normalmente
  _loadNextVideo();
}
```

### 4. Monitorar Performance

```dart
// Periodicamente verificar estatísticas
final stats = AdManager().getStats();
if (stats['admob_fail'] > 10) {
  // Talvez há problema com AdMob
  print('⚠️ AdMob com muitas falhas');
}
```

---

## 💰 Maximizando Receita

### 1. Placement Estratégico

**Locais recomendados para banners:**
- ✅ Rodapé da home
- ✅ Entre seções de conteúdo
- ✅ Tela de detalhes (abaixo da sinopse)
- ✅ Tela de busca (abaixo dos resultados)

**Evitar:**
- ❌ Sobre botões importantes
- ❌ Muito próximo a elementos clicáveis
- ❌ Bloqueando conteúdo

### 2. Timing Otimizado

**Rewarded Ads:**
- Após 2-3 vídeos ⭐ **Ideal**
- Nunca no primeiro uso
- Respeitar tempo mínimo entre anúncios

**Banners:**
- Permanentes em telas principais
- Rotação a cada 60 segundos (automático)

### 3. A/B Testing

```dart
// Testar diferentes configurações
const bool GROUP_A = true; // Mudar para false no grupo B

static const int _minVideosBetweenAds = GROUP_A ? 2 : 3;
```

Compare métricas:
- Taxa de abandono
- Tempo de sessão
- Receita por usuário

---

## 🔒 Políticas e Conformidade

### Políticas do AdMob

✅ **Permitido:**
- Anúncios entre conteúdo
- Banners em áreas designadas
- Rewarded ads com opt-in claro

❌ **Proibido:**
- Forçar cliques
- Anúncios muito próximos a botões
- Tráfego artificial
- Auto-cliques

### Políticas do Unity Ads

✅ **Permitido:**
- Rewarded ads com recompensa clara
- Banners não intrusivos
- Integração natural no fluxo do app

❌ **Proibido:**
- Forçar visualização
- Incentivo para cliques
- Manipular impressões

### LGPD/GDPR

Implementar consentimento para usuários na EU:

```dart
// Futuro: Implementar UMP SDK
// https://developers.google.com/admob/flutter/eu-consent
```

---

## 📚 Recursos Adicionais

### Documentação Oficial

- [AdMob Flutter](https://developers.google.com/admob/flutter)
- [Unity Ads Flutter](https://docs.unity.com/ads/)
- [Ad Mediation Best Practices](https://developers.google.com/admob/flutter/mediation)

### Dashboards

- [AdMob Console](https://apps.admob.com)
- [Unity Dashboard](https://dashboard.unity3d.com)

### Suporte

- AdMob: [support.google.com/admob](https://support.google.com/admob)
- Unity: [support.unity.com](https://support.unity.com)

---

## 🎯 Checklist Pré-Produção

Antes de publicar com anúncios reais:

- [ ] Game ID do Unity Ads atualizado
- [ ] IDs de produção configurados
- [ ] `useTestAds: false` em main.dart
- [ ] Testado em dispositivo real
- [ ] Políticas do AdMob revisadas
- [ ] Políticas do Unity revisadas
- [ ] Política de Privacidade atualizada
- [ ] Estatísticas de teste verificadas
- [ ] Fallback testado (desligar WiFi)
- [ ] Banners testados em várias telas
- [ ] UX sem anúncios testada (ambos falhando)

---

## 🚀 Status Atual

**Implementação**: ✅ **COMPLETA**

**Recursos Ativos:**
- ✅ AdMob Rewarded Ads
- ✅ AdMob Banner Ads
- ✅ Unity Rewarded Ads
- ✅ Unity Banner Ads
- ✅ Rotação 50/50
- ✅ Fallback automático
- ✅ Estatísticas de performance
- ✅ Políticas de frequência
- ✅ Diálogo de consentimento

**Próximos Passos:**
1. Obter Game ID do Unity Ads
2. Atualizar código com Game ID real
3. Testar com IDs de teste
4. Testar com IDs de produção
5. Monitorar performance
6. Ajustar políticas baseado em métricas

---

*Última atualização: 2025-01-07*
*Versão do sistema: 2.0 (AdMob + Unity Ads)*
