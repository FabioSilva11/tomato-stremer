import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/feed_models.dart';
import '../../core/state/app_controller.dart';
import '../../core/state/theme_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import '../details/anime_details_page.dart';
import '../player/player_page.dart';
import '../search/search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onOpenSearch});

  final VoidCallback? onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final themeController = context.watch<ThemeController>();
    final feed = controller.feed;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.loadHome,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 78,
              titleSpacing: 18,
              title: Row(
                children: [
                  Image.asset('assets/app_icon.png', width: 28, height: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'tomato',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: themeController.darkSelected
                      ? 'Usar tema claro'
                      : 'Usar tema escuro',
                  icon: Icon(
                    themeController.darkSelected
                        ? LucideIcons.sun
                        : LucideIcons.moon,
                  ),
                  onPressed: themeController.toggle,
                ),
                IconButton(
                  tooltip: 'Pesquisar',
                  icon: const Icon(LucideIcons.search),
                  onPressed:
                      onOpenSearch ??
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SearchPage()),
                      ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (controller.loading && feed == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.error != null && feed == null)
              SliverFillRemaining(
                child: _ErrorState(
                  error: controller.error!,
                  onRetry: controller.loadHome,
                ),
              )
            else if (feed == null || feed.sections.isEmpty)
              SliverFillRemaining(
                child: _ErrorState(
                  error: 'Nenhuma secao foi retornada pela API.',
                  onRetry: controller.loadHome,
                ),
              )
            else
              ..._buildFeed(context, feed.sections),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeed(BuildContext context, List<FeedSection> sections) {
    final feature = _firstFeature(sections);
    final fallback = _firstItemSection(sections);
    final content = <Widget>[];

    if (feature != null || fallback != null) {
      content.add(
        SliverToBoxAdapter(
          child: _HeroFeature(section: feature, fallback: fallback),
        ),
      );
    }

    for (final section in sections) {
      if (section.isFeature || section.title.trim().isEmpty) continue;
      if (section.isEpisodeSection) {
        content.add(SliverToBoxAdapter(child: _EpisodeRow(section: section)));
      } else if (section.isBannerSection) {
        content.add(SliverToBoxAdapter(child: _BannerRow(section: section)));
      } else if (section.items.isNotEmpty) {
        content.add(SliverToBoxAdapter(child: _PosterRow(section: section)));
      }
    }
    return content;
  }

  FeedSection? _firstFeature(List<FeedSection> sections) {
    for (final section in sections) {
      if (section.isFeature) return section;
    }
    return null;
  }

  FeedSection? _firstItemSection(List<FeedSection> sections) {
    for (final section in sections) {
      if (section.items.isNotEmpty) return section;
    }
    return null;
  }
}

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({required this.section, required this.fallback});

  final FeedSection? section;
  final FeedSection? fallback;

  @override
  Widget build(BuildContext context) {
    final hero = section;
    final fallbackItem = fallback?.items.first;
    final image = hero?.banner ?? fallbackItem?.thumbnail ?? '';
    final title = hero?.title ?? fallback?.title ?? 'Destaque';
    final animeId = hero?.animeId ?? fallbackItem?.animeId ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 26),
      child: GestureDetector(
        onTap: () => _openAnime(context, animeId),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PosterImage(url: image, borderRadius: 0),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.32),
                        Colors.black.withValues(alpha: 0.84),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((hero?.hyperTitle ?? '').isNotEmpty)
                        Pill(
                          label: hero!.hyperTitle!,
                          icon: LucideIcons.sparkles,
                          color: AppTheme.goldOf(context),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if ((hero?.text ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          hero!.text!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.28,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () => _openAnime(context, animeId),
                            icon: const Icon(LucideIcons.play, size: 18),
                            label: const Text('Assistir'),
                          ),
                          const SizedBox(width: 10),
                          if ((hero?.tags ?? '').isNotEmpty)
                            Expanded(
                              child: Text(
                                hero!.tags!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.mutedOf(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.section});

  final FeedSection section;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: section.title,
      child: SizedBox(
        height: 235,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: section.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = section.items[index];
            return GestureDetector(
              onTap: () => _openAnime(context, item.animeId),
              child: SizedBox(
                width: 132,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 0.68,
                      child: PosterImage(url: item.thumbnail),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BannerRow extends StatelessWidget {
  const _BannerRow({required this.section});

  final FeedSection section;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: section.title,
      child: SizedBox(
        height: 175,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: section.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = section.items[index];
            return GestureDetector(
              onTap: () => _openAnime(context, item.animeId),
              child: SizedBox(
                width: 260,
                child: Stack(
                  children: [
                    Positioned.fill(child: PosterImage(url: item.thumbnail)),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Pill(
                        label: '#${index + 1}',
                        icon: LucideIcons.flame,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({required this.section});

  final FeedSection section;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: section.title,
      child: SizedBox(
        height: 214,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          scrollDirection: Axis.horizontal,
          itemCount: section.items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = section.items[index];
            return GestureDetector(
              onTap: item.episodeId == null
                  ? () => _openAnime(context, item.animeId)
                  : () async {
                      await context.read<AppController>().addFeedHistory(item);
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PlayerPage(episodeId: item.episodeId!),
                        ),
                      );
                    },
              child: SizedBox(
                width: 246,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          PosterImage(url: item.thumbnail),
                          const Center(
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primary,
                              child: Icon(
                                LucideIcons.play,
                                color: AppTheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        if (item.dubbed == true)
                          const Pill(label: 'Dublado', icon: LucideIcons.check),
                        if (item.dubbed == true) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.animeName ?? 'Novo episodio',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.episodeName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.mutedOf(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Text(
              title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.badgeInfo,
            size: 42,
            color: AppTheme.primaryOf(context),
          ),
          const SizedBox(height: 14),
          const Text(
            'Nao foi possivel carregar a home',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedOf(context)),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

void _openAnime(BuildContext context, int animeId) {
  if (animeId <= 0) return;
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => AnimeDetailsPage(animeId: animeId)));
}
