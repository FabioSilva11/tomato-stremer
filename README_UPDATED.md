# 🍅 Tomato Streaming App

Aplicativo de streaming de animes com sistema avançado de anúncios, criptografia e notificações.

## ✨ Funcionalidades

### 📺 Player Avançado
- Controles intuitivos com botões de ±10 segundos
- Múltiplas qualidades de vídeo (1080p, 720p, 480p)
- Modo paisagem automático
- Retomada de reprodução
- Navegação entre episódios

### 🎯 Sistema de Anúncios Inteligente
- **Dual-Platform**: AdMob + Unity Ads
- **Rotação Automática**: 50/50 com peso por performance
- **Fallback**: Se uma plataforma falhar, usa a outra automaticamente
- **Rewarded Ads**: Entre vídeos (a cada 2 vídeos ou 5 minutos)
- **Banner Ads**: Discretos na home e outras telas

### 🔔 Notificações Inteligentes
- Notificações de novos episódios
- Apenas para animes favoritos
- Verificação automática em background (a cada 6 horas)
- Toque para abrir episódio

### 🔒 Segurança Avançada
- **Criptografia AES-256**: Dados sensíveis protegidos
- **ProGuard + R8**: Código ofuscado e minificado
- **KeyStore Android**: Chaves armazenadas com segurança
- **String Obfuscation**: Strings sensíveis não aparecem em texto claro
- **Token Seguro**: API token criptografado

### 📚 Biblioteca
- Favoritos sincronizados
- Histórico de visualização
- Progresso de reprodução salvo
- Notificações de novos episódios

### 🔍 Busca
- Busca rápida e eficiente
- Resultados instantâneos
- Filtros por tipo

## 🛠️ Tecnologias

### Framework
- **Flutter 3.8+**: UI multiplataforma
- **Dart**: Linguagem de programação

### Anúncios
- **Google Mobile Ads 5.2.0**: AdMob integration
- **Unity Ads Plugin 0.3.16**: Unity integration

### Segurança
- **Flutter Secure Storage 9.2.2**: Armazenamento criptografado
- **Encrypt 5.0.3**: Biblioteca de criptografia

### Notificações
- **Flutter Local Notifications 18.0.1**: Notificações locais
- **WorkManager 0.5.2**: Background tasks

### Backend
- **HTTP**: Comunicação com API
- **SQLite**: Banco de dados local

## 🚀 Quick Start

### Instalação

```bash
# Clonar repositório
git clone https://github.com/seu-usuario/tomato_streaming.git

# Instalar dependências
flutter pub get

# Executar em modo debug
flutter run
```

### Configuração Rápida

1. **Unity Ads** (Obrigatório para produção):
   ```dart
   // Em lib/core/ads/ad_manager.dart
   static const String _unityGameIdAndroid = 'SEU_GAME_ID';
   ```

2. **Modo de teste**:
   ```dart
   // Em lib/main.dart
   await AdManager().initialize(useTestAds: true); // teste
   await AdManager().initialize(useTestAds: false); // produção
   ```

3. **Build release**:
   ```bash
   flutter build apk --release
   ```

## 📖 Documentação

| Arquivo | Descrição |
|---------|-----------|
| [QUICK_START.md](QUICK_START.md) | 🚀 Começar rapidamente |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | 📋 Resumo completo |
| [AD_REDUNDANCY_GUIDE.md](AD_REDUNDANCY_GUIDE.md) | 🎯 Sistema de anúncios |
| [SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md) | 🔒 Segurança |
| [ADMOB_SETUP.md](ADMOB_SETUP.md) | 📱 Configurar AdMob |
| [ADMOB_POLICIES.md](ADMOB_POLICIES.md) | ⚖️ Políticas |

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── ads/
│   │   ├── admob_service.dart      # Serviço AdMob original
│   │   └── ad_manager.dart         # Gerenciador unificado
│   ├── api/
│   │   ├── tomato_api.dart         # API cliente
│   │   ├── secure_tomato_api.dart  # API com criptografia
│   │   └── streambert_api.dart     # API alternativa
│   ├── models/
│   │   ├── anime_models.dart       # Modelos de anime
│   │   ├── feed_models.dart        # Modelos de feed
│   │   └── library_models.dart     # Modelos de biblioteca
│   ├── state/
│   │   ├── app_controller.dart     # Estado global
│   │   └── theme_controller.dart   # Tema
│   ├── storage/
│   │   └── app_database.dart       # SQLite
│   ├── security/
│   │   └── security_manager.dart   # Criptografia
│   └── notifications/
│       └── notification_service.dart # Notificações
├── features/
│   ├── home/                        # Tela principal
│   ├── player/                      # Player de vídeo
│   ├── details/                     # Detalhes do anime
│   ├── search/                      # Busca
│   ├── library/                     # Biblioteca
│   └── app_shell.dart               # Shell do app
├── theme/
│   └── app_theme.dart               # Tema customizado
└── main.dart                         # Entry point
```

## 🔐 Segurança

### Nível de Proteção: 🔒🔒🔒🔒⚪ (4/5)

- ✅ AES-256 CBC Encryption
- ✅ Android KeyStore
- ✅ ProGuard + R8 Obfuscation
- ✅ String Obfuscation
- ✅ Code Minification
- ✅ Resource Shrinking
- ✅ Debug Log Removal
- ⚪ SSL Pinning (futuro)
- ⚪ Root Detection (futuro)

## 📊 Sistema de Anúncios

### Fluxo Inteligente

```
Usuário assiste vídeo
      ↓
Contador incrementa
      ↓
Atingiu 2 vídeos?
      ↓ Sim
Sistema escolhe plataforma (50/50)
      ↓
Tenta AdMob
      ↓ Falhou?
Tenta Unity Ads automaticamente
      ↓
Anúncio exibido
      ↓
Usuário pode continuar
```

### Estatísticas em Tempo Real

```dart
final stats = AdManager().getStats();
// {
//   "admob_success": 15,
//   "unity_success": 8,
//   "current_platform": "admob"
// }
```

## 🎨 Screenshots

```
[Adicionar screenshots aqui]
- Home com banner
- Player com controles
- Detalhes do anime
- Biblioteca de favoritos
- Notificações
```

## 📱 Requisitos

- **Android**: 5.0+ (API 21+)
- **Flutter**: 3.8+
- **Dart**: 3.8+

## 🧪 Testando

### Modo de Teste (IDs de teste do Google)

```bash
# 1. Configurar
# main.dart: useTestAds: true

# 2. Executar
flutter run

# 3. Testar
# - Assista 2 vídeos
# - Anúncio de teste aparece
```

### Modo de Produção

```bash
# 1. Configurar
# main.dart: useTestAds: false
# ad_manager.dart: Unity Game ID real

# 2. Build
flutter build apk --release

# 3. Instalar
flutter install --release
```

## 🐛 Problemas Conhecidos

### Anúncios não aparecem

**Causa**: IDs novos precisam de tempo
**Solução**: Aguardar 1-2 horas ou usar `useTestAds: true`

### Unity Ads erro

**Causa**: Game ID inválido
**Solução**: Configurar Game ID no Unity Dashboard

### Build release crasha

**Causa**: ProGuard muito agressivo
**Solução**: Adicionar regras keep no `proguard-rules.pro`

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

## 📄 Licença

Este projeto é privado e proprietário.

## 🙏 Créditos

### APIs Utilizadas
- **Tomato API**: Backend de animes
- **Streambert API**: Recomendações

### Bibliotecas
- Flutter e todas as dependências listadas
- Ícones: Lucide Icons

### Plataformas de Anúncios
- Google AdMob
- Unity Ads

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/seu-usuario/tomato_streaming/issues)
- **Email**: seu-email@exemplo.com
- **Discord**: [Link do servidor]

## 🔄 Atualizações Recentes

### v1.0.0 (Janeiro 2025)
- ✅ Sistema de anúncios com redundância (AdMob + Unity)
- ✅ Criptografia AES-256 e ofuscação ProGuard
- ✅ Notificações de novos episódios
- ✅ Botões de ±10 segundos no player
- ✅ Banners discretos
- ✅ Sistema de favoritos aprimorado

## 🚧 Roadmap

### v1.1.0
- [ ] SSL Pinning
- [ ] Root Detection
- [ ] Autenticação de usuário
- [ ] Perfis de usuário

### v1.2.0
- [ ] Download offline
- [ ] Picture-in-Picture
- [ ] Chromecast support
- [ ] Legendas customizáveis

### v2.0.0
- [ ] iOS support
- [ ] Web support
- [ ] Desktop support

---

## 📊 Status do Projeto

![Status](https://img.shields.io/badge/status-active-success.svg)
![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/flutter-3.8%2B-blue.svg)
![License](https://img.shields.io/badge/license-proprietary-red.svg)

---

**Desenvolvido com ❤️ usando Flutter**

*Última atualização: Janeiro 2025*
