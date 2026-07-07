# 🍅 Tomato Streaming

[![Build Status](https://github.com/SEU_USUARIO/tomato_streaming/workflows/Build%20and%20Release%20APK/badge.svg)](https://github.com/SEU_USUARIO/tomato_streaming/actions)
[![License](https://img.shields.io/badge/license-proprietary-red.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-3.24.5-blue.svg)](https://flutter.dev)
[![Version](https://img.shields.io/badge/version-1.0.0-green.svg)](https://github.com/SEU_USUARIO/tomato_streaming/releases)

Aplicativo de streaming de animes com sistema avançado de anúncios, criptografia e notificações.

---

## 📥 Download

### Última Versão

[**📱 Baixar APK v1.0.0**](https://github.com/SEU_USUARIO/tomato_streaming/releases/latest)

> **Requisitos:** Android 5.0+ (API 21+)

---

## ✨ Funcionalidades

### 📺 Player Avançado
- Controles com botões de ±10 segundos
- Múltiplas qualidades (1080p, 720p, 480p)
- Modo paisagem
- Retomada automática

### 🎯 Sistema de Anúncios
- **Dual-Platform**: AdMob + Unity Ads
- Rotação inteligente 50/50
- Fallback automático
- Banners discretos

### 🔔 Notificações
- Novos episódios de favoritos
- Verificação automática (6h)
- Toque para assistir

### 🔒 Segurança
- Criptografia AES-256
- ProGuard + R8 ofuscação
- Token seguro
- KeyStore Android

### 🌍 Idiomas
- 🇧🇷 Português
- 🇺🇸 English

---

## 🚀 Para Desenvolvedores

### Pré-requisitos

- Flutter 3.8+
- Android Studio / VS Code
- Git

### Instalação

```bash
# Clonar repositório
git clone https://github.com/SEU_USUARIO/tomato_streaming.git
cd tomato_streaming

# Instalar dependências
flutter pub get

# Gerar localizações
flutter gen-l10n

# Executar
flutter run
```

### Build Release

```bash
# Windows
build_production.bat

# Linux/Mac
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### Criar Release Automática

```bash
# 1. Atualizar versão em pubspec.yaml
version: 1.1.0+2

# 2. Criar tag
git tag -a v1.1.0 -m "Release v1.1.0"

# 3. Push
git push origin main --tags

# GitHub Actions compila e cria release automaticamente!
```

---

## 📖 Documentação

| Documento | Descrição |
|-----------|-----------|
| [QUICK_START.md](QUICK_START.md) | Começar rapidamente |
| [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) | CI/CD e releases |
| [AD_REDUNDANCY_GUIDE.md](AD_REDUNDANCY_GUIDE.md) | Sistema de anúncios |
| [SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md) | Segurança |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Resumo completo |

---

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── ads/          # AdMob + Unity Ads
│   ├── api/          # API clients
│   ├── security/     # Criptografia
│   ├── notifications/# Notificações
│   └── storage/      # SQLite
├── features/
│   ├── home/         # Tela principal
│   ├── player/       # Video player
│   └── library/      # Favoritos
└── l10n/             # Traduções PT/EN
```

---

## 🎯 Roadmap

### v1.0.0 ✅ (Atual)
- [x] Sistema de anúncios com redundância
- [x] Criptografia e ofuscação
- [x] Notificações
- [x] Player avançado
- [x] Internacionalização PT/EN

### v1.1.0 (Próxima)
- [ ] Modo offline/download
- [ ] Autenticação de usuário
- [ ] Perfis personalizados
- [ ] Picture-in-Picture

### v2.0.0 (Futuro)
- [ ] iOS support
- [ ] Chromecast
- [ ] Legendas customizáveis

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/NovaFuncionalidade`)
3. Commit (`git commit -m 'feat: adiciona nova funcionalidade'`)
4. Push (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

---

## 📊 Status do Projeto

- **Status:** ✅ Ativo
- **Versão:** 1.0.0
- **Última atualização:** Janeiro 2025
- **Builds automáticos:** ✅ Configurado

---

## 🔒 Segurança

### Nível de Proteção: 🔒🔒🔒🔒⚪ (4/5)

- ✅ AES-256 Encryption
- ✅ ProGuard + R8
- ✅ Token criptografado
- ✅ KeyStore Android
- ✅ String obfuscation

### Reportar Vulnerabilidades

Se encontrar problemas de segurança, **NÃO** abra uma issue pública. Entre em contato por email: security@exemplo.com

---

## 📄 Licença

Este projeto é proprietário e privado.

---

## 🙏 Créditos

### APIs
- Tomato API
- Streambert API

### Bibliotecas
- Flutter Framework
- Google Mobile Ads
- Unity Ads
- E muitas outras...

---

## 📞 Suporte

- **Issues:** [GitHub Issues](https://github.com/SEU_USUARIO/tomato_streaming/issues)
- **Releases:** [GitHub Releases](https://github.com/SEU_USUARIO/tomato_streaming/releases)
- **Documentação:** [Wiki](https://github.com/SEU_USUARIO/tomato_streaming/wiki)

---

## 📈 Estatísticas

![GitHub stars](https://img.shields.io/github/stars/SEU_USUARIO/tomato_streaming?style=social)
![GitHub forks](https://img.shields.io/github/forks/SEU_USUARIO/tomato_streaming?style=social)
![GitHub issues](https://img.shields.io/github/issues/SEU_USUARIO/tomato_streaming)
![GitHub pull requests](https://img.shields.io/github/issues-pr/SEU_USUARIO/tomato_streaming)

---

**Desenvolvido com ❤️ usando Flutter**

*Última atualização: Janeiro 2025*
