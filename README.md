# Tomato Streaming

[![Build](https://github.com/FabioSilva11/tomato-stremer/actions/workflows/build-debug.yml/badge.svg)](https://github.com/FabioSilva11/tomato-stremer/actions)
[![Release](https://github.com/FabioSilva11/tomato-stremer/actions/workflows/build-release.yml/badge.svg)](https://github.com/FabioSilva11/tomato-stremer/actions)
![Flutter](https://img.shields.io/badge/Flutter-3.35.2-blue)
![Android](https://img.shields.io/badge/Android-5.0%2B-brightgreen)
![License](https://img.shields.io/badge/license-proprietary-red)

Aplicativo Flutter de streaming de animes com sistema de anúncios redundante (AdMob + Unity Ads), criptografia AES-256, notificações push e catálogo TMDB.

---

## Funcionalidades

### Player de Vídeo
- Qualidades múltiplas: 1080p (FHD), 720p (MHD), 480p (SHD)
- Controles: play/pause, avançar/voltar 10s, tela cheia paisagem
- Retomada automática da última posição assistida
- Navegação para o próximo episódio com anúncio opcional
- Barra de progresso com scrubbing

### Feed / Home
- Feed rolável com seções: hero, posters, banners, episódios
- Pull-to-refresh
- Alternador de tema claro/escuro
- Botão de busca e acesso à biblioteca

### Busca (Tomato API)
- Busca textual com paginação
- Resultados com imagem, tipo, data, nome, tags, episódios
- Navegação direta para detalhes do anime

### Detalhes do Anime
- Banner hero com gradiente, pôster, ano, rating, gênero, episódios
- Indicador de dia de lançamento (traduzido)
- Indicador de dublado e suporte a notificações
- Favoritar/desfavoritar
- Seletor de temporadas
- Lista de episódios paginada com progresso de assistido

### Biblioteca
- **Favoritos**: animes salvos com imagem, ano, rating, gênero
- **Histórico**: episódios assistidos com progresso e data
- **Notificações**: notificações de novos episódios com badge de não lidas
- Estado vazio com ilustração para cada seção

### Notificações Push
- Notificações locais via `flutter_local_notifications`
- Verificação em background a cada 6h via `workmanager`
- Notifica apenas para animes favoritados (máx. 5 por lote)
- Toque na notificação abre o player direto no episódio
- Permissão Android 13+ gerenciada

### Catálogo StreamBert (TMDB)
- Seção separada no bottom nav com catálogo TMDB
- Requer token de acesso TMDB (armazenado com criptografia)
- Seções: Trending Movies, Trending TV, Top Rated, Anime, Now Playing, On the Air
- Busca combinada (filmes + séries)
- Player WebView com fontes: Videasy, VidSrc, 2Embed
- Seletor de temporada/episódio para séries

### Sistema de Anúncios
- **Duas plataformas**: AdMob (desabilitado temporariamente) + Unity Ads
- **Redundância**: fallback automático entre plataformas
- **Rotação inteligente**: distribuição 50/50 com peso por performance
- **Anúncios premiados**: entre episódios (mín. 2 vídeos, mín. 5 min entre anúncios)
- **Banners**: na página inicial
- **Bloqueio**: conteúdo só é liberado após assistir o anúncio completo
- Estatísticas de performance por plataforma

### Segurança
- Criptografia AES-256 CBC com chave dinâmica por dispositivo
- Armazenamento seguro Android KeyStore via `flutter_secure_storage`
- Ofuscação de strings em runtime (XOR)
- Token da API armazenado e transmitido de forma segura
- ProGuard + R8 com dicionário de ofuscação
- Remoção de logs em produção

### Internacionalização
- Português (Brasil) e Inglês
- 65 chaves de tradução via ARB + `flutter gen-l10n`
- Suporte a Material 3

---

## Arquitetura

```
lib/
├── core/
│   ├── ads/              # AdManager (AdMob + Unity Ads)
│   ├── api/              # TomatoApi, StreambertApi, SecureTomatoApi
│   ├── models/           # AnimeDetails, FeedResponse, WatchHistory, etc.
│   ├── state/            # AppController, ThemeController (Provider)
│   ├── storage/          # SQLite (sqflite) — 6 tabelas
│   ├── security/         # SecurityManager (AES-256 + KeyStore)
│   └── notifications/    # NotificationService + WorkManager
├── features/
│   ├── app_shell.dart    # Bottom navigation (6 abas)
│   ├── home/             # Feed principal
│   ├── details/          # Detalhes do anime + episódios
│   ├── player/           # Player de vídeo
│   ├── search/           # Busca
│   ├── library/          # Favoritos, histórico, notificações
│   └── streambert/       # Catálogo TMDB + WebView player
├── shared/widgets/       # PosterImage, Pill
├── theme/                # AppTheme (dark/light, Material 3)
├── l10n/                 # app_en.arb, app_pt.arb
└── main.dart             # Entry point, providers, inicialização
```

### Padrões
- **Provider** (ChangeNotifier) para estado
- **Singleton** para AdManager, SecurityManager, NotificationService
- **Repository** via AppController (API + Database)
- **Sliver** para scroll complexo
- **IndexedStack** para persistência de abas

---

## Tecnologias

| Categoria | Tecnologia |
|-----------|-----------|
| **Framework** | Flutter 3.35.2 / Dart >=3.6 |
| **Estado** | Provider ^6.0.5 |
| **HTTP** | http ^1.5.0 |
| **Vídeo** | video_player ^2.9.2 |
| **WebView** | webview_flutter ^4.13.1 |
| **Banco** | sqflite ^2.4.2 |
| **Anúncios** | unity_ads_plugin ^0.3.16 |
| **Segurança** | encrypt ^5.0.3, flutter_secure_storage ^9.2.2 |
| **Notificações** | flutter_local_notifications ^18.0.1, workmanager ^0.5.2 |
| **Ícones** | lucide_icons_flutter ^3.1.13 |
| **i18n** | intl + flutter_gen_l10n |
| **Linting** | flutter_lints ^5.0 |
| **CI/CD** | GitHub Actions |

---

## APIs

### Tomato API (`https://edge.betomato.com`)
| Endpoint | Método | Descrição |
|----------|--------|-----------|
| `/v2/animes/feed` | GET | Feed principal com seções |
| `/v2/content/search` | POST | Busca de animes/mangás |
| `/v2/anime/{id}` | GET | Detalhes + temporadas |
| `/season/{id}/episodes` | POST | Episódios de uma temporada |
| `/v2/anime/episode/{id}/stream` | GET | URLs de stream (fhd, mhd, shd) |

### StreamBert API (`https://api.themoviedb.org/3`)
| Endpoint | Descrição |
|----------|-----------|
| `/trending/movie/week` | Filmes em alta |
| `/trending/tv/week` | Séries em alta |
| `/movie/top_rated` | Filmes mais bem avaliados |
| `/tv/top_rated` | Séries mais bem avaliadas |
| `/discover/tv?with_genres=16&with_origin_country=JP` | Anime |
| `/movie/now_playing` | Filmes em cartaz |
| `/tv/on_the_air` | Séries no ar |
| `/search/multi` | Busca multi |
| `/movie/{id}` | Detalhes do filme |
| `/tv/{id}` | Detalhes da série |
| `/tv/{id}/season/{num}` | Episódios da temporada |

---

## Banco de Dados (SQLite)

| Tabela | Descrição |
|--------|-----------|
| `meta` | Chave-valor (token TMDB, flags) |
| `favorites` | Animes favoritados |
| `watch_history` | Histórico com posição de playback |
| `known_episodes` | IDs de episódios conhecidos |
| `episode_notifications` | Notificações geradas |
| `anime_titles` | Cache de títulos/imagens |

Migrações: v1 (inicial), v2 (+anime_titles), v3 (+playback_position_ms, duration_ms)

---

## Anúncios

### Fluxo
1. Usuário assiste 2+ vídeos
2. Ao iniciar próximo vídeo, dialog pergunta "Assistir anúncio?"
3. Se aceito, AdManager tenta plataforma primária
4. Se falhar, tenta plataforma secundária (fallback)
5. Se assistiu completo → conteúdo liberado
6. Se pulou ou falhou → conteúdo bloqueado

### IDs (Produção)
| Plataforma | Tipo | ID |
|------------|------|-----|
| Unity Ads | Game ID | `5740617` |
| Unity Ads | Rewarded | `Rewarded_Android` |
| Unity Ads | Banner | `Banner_Android` |
| AdMob | App | `ca-app-pub-6598765502914364~1736433666` |
| AdMob | Rewarded | `ca-app-pub-6598765502914364/1896215768` |
| AdMob | Banner | `ca-app-pub-6598765502914364/2213698978` |

> AdMob está temporariamente desabilitado por questões de compatibilidade.

---

## Segurança (Nível 4/5)

- AES-256 CBC com chave dinâmica por dispositivo
- Armazenamento em Android KeyStore
- Ofuscação de strings em runtime (XOR)
- Token da API ofuscado no código-fonte
- Cache em memória com limpeza manual
- ProGuard + R8 com dicionário personalizado
- Logs removidos em produção

---

## CI/CD

### Debug (push p/ main/develop, PR p/ main)
- Flutter 3.35.2
- `flutter clean` + `pub get` + `gen-l10n`
- Análise estática (dart analyze)
- Testes com cobertura
- Build APK debug
- Upload de artifact

### Release (tag v*.*.*)
- Build release com ofuscação
- Extração de versão
- Criação de GitHub Release
- Upload do APK + debug symbols (retenção 90 dias)

---

## Requisitos

- Android 5.0+ (API 21+)
- Flutter 3.8+ (para desenvolvimento)
- Token TMDB (para catálogo StreamBert)

---

## Setup

```bash
# Clonar
git clone https://github.com/FabioSilva11/tomato-stremer.git
cd tomato-stremer

# Dependências
flutter pub get

# Gerar localizações
flutter gen-l10n

# Executar em desenvolvimento
flutter run

# Build release
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### Build via script (Windows)
```bash
build_production.bat
```

---

## Estrutura do Projeto

```
tomato_streaming/
├── .github/workflows/
│   ├── build-debug.yml
│   └── build-release.yml
├── lib/
│   ├── core/ads/
│   ├── core/api/
│   ├── core/models/
│   ├── core/state/
│   ├── core/storage/
│   ├── core/security/
│   ├── core/notifications/
│   ├── features/home/
│   ├── features/details/
│   ├── features/player/
│   ├── features/search/
│   ├── features/library/
│   ├── features/streambert/
│   └── shared/widgets/
├── assets/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
├── l10n.yaml
└── build_production.bat
```

---

## Roadmap

### v1.0.0 ✅
- Player com múltiplas qualidades e retomada
- Feed, busca, detalhes, favoritos, histórico
- Sistema de anúncios redundante (AdMob + Unity Ads)
- Criptografia AES-256 e ofuscação
- Notificações push locais + background check
- Catálogo TMDB (StreamBert)
- Internacionalização PT/EN
- Temas dark/light (Material 3)
- CI/CD com GitHub Actions

### Próximos
- [ ] Suporte a iOS
- [ ] Modo offline / download
- [ ] Picture-in-Picture
- [ ] Legendas customizáveis
- [ ] Chromecast
- [ ] Autenticação de usuário

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| [QUICK_START.md](QUICK_START.md) | Guia rápido de início |
| [AD_REDUNDANCY_GUIDE.md](AD_REDUNDANCY_GUIDE.md) | Sistema de anúncios detalhado |
| [SECURITY_IMPLEMENTATION.md](SECURITY_IMPLEMENTATION.md) | Implementação de segurança |
| [GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md) | CI/CD e releases |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Resumo técnico completo |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de versões |

---

## Licença

Projeto proprietário e privado.
