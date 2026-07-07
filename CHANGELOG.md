# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### A Adicionar
- Modo offline com download de episódios
- Autenticação de usuário
- Perfis personalizados

## [1.0.0] - 2025-01-07

### 🎉 Lançamento Inicial

#### Adicionado
- ✨ Sistema de anúncios com redundância (AdMob + Unity Ads)
- ✨ Rotação inteligente 50/50 entre plataformas de anúncios
- ✨ Fallback automático se uma plataforma falhar
- ✨ Rewarded ads entre vídeos (a cada 2 vídeos ou 5 minutos)
- ✨ Banner ads na home e outras telas
- 🔒 Criptografia AES-256 para dados sensíveis
- 🔒 ProGuard + R8 ofuscação de código
- 🔒 Token de API criptografado e seguro
- 🔒 Armazenamento seguro usando Android KeyStore
- 🔔 Notificações de novos episódios para animes favoritos
- 🔔 Verificação automática em background a cada 6 horas
- ⏩ Botões de avançar e voltar 10 segundos no player
- 🌍 Suporte a Português (Brasil) e Inglês
- 📺 Player de vídeo com múltiplas qualidades (1080p, 720p, 480p)
- 📺 Modo paisagem automático
- 📺 Retomada de reprodução
- 📚 Sistema de favoritos
- 📚 Histórico de visualização
- 📚 Progresso de reprodução salvo
- 🔍 Sistema de busca
- 🎨 Tema claro e escuro
- 🏗️ GitHub Actions para build e release automáticos

#### Segurança
- 🔐 Código ofuscado com ProGuard + R8
- 🔐 Strings sensíveis ofuscadas
- 🔐 Token de API não visível em texto claro
- 🔐 Nível de proteção: 4/5

#### Técnico
- 📱 Android 5.0+ (API 21+)
- 🎯 Flutter 3.24.5
- 🎯 Dart 3.8+
- 🗄️ SQLite para armazenamento local
- 🔄 WorkManager para tarefas em background
- 📊 AdMob SDK 5.2.0
- 📊 Unity Ads Plugin 0.3.16

#### IDs Configurados
- **AdMob App ID:** ca-app-pub-6598765502914364~1736433666
- **AdMob Rewarded:** ca-app-pub-6598765502914364/1896215768
- **AdMob Banner:** ca-app-pub-6598765502914364/2213698978
- **Unity Game ID:** 5740617
- **Unity Rewarded:** Rewarded_Android
- **Unity Banner:** Banner_Android

### Documentação
- 📖 README completo
- 📖 QUICK_START para início rápido
- 📖 GITHUB_ACTIONS_GUIDE para CI/CD
- 📖 AD_REDUNDANCY_GUIDE para sistema de anúncios
- 📖 SECURITY_IMPLEMENTATION para segurança
- 📖 IMPLEMENTATION_SUMMARY com resumo completo

---

## Tipos de Mudanças

- `Adicionado` para novas funcionalidades.
- `Alterado` para mudanças em funcionalidades existentes.
- `Descontinuado` para funcionalidades que serão removidas.
- `Removido` para funcionalidades removidas.
- `Corrigido` para correções de bugs.
- `Segurança` para vulnerabilidades corrigidas.

---

[Unreleased]: https://github.com/SEU_USUARIO/tomato_streaming/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/SEU_USUARIO/tomato_streaming/releases/tag/v1.0.0
