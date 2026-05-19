import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/api/tomato_api.dart';
import '../../core/models/anime_models.dart';
import '../../core/state/app_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import '../player/player_page.dart';

class AnimeDetailsPage extends StatefulWidget {
  const AnimeDetailsPage({super.key, required this.animeId});

  final int animeId;

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  late Future<AnimeDetails> _future;
  final _episodes = <Episode>[];
  AnimeSeason? _selectedSeason;
  int? _episodesSeasonId;
  int _episodePage = 0;
  bool _episodesLoading = false;
  bool _episodesLoadingMore = false;
  bool _episodeHasMore = false;
  String? _episodesError;

  @override
  void initState() {
    super.initState();
    _future = context.read<TomatoApi>().fetchAnime(widget.animeId);
  }

  void _selectSeason(AnimeSeason season) {
    setState(() => _selectedSeason = season);
    _loadEpisodes(season, reset: true);
  }

  Future<void> _loadEpisodes(AnimeSeason season, {required bool reset}) async {
    if (_episodesLoading || _episodesLoadingMore) return;
    setState(() {
      if (reset) {
        _episodesSeasonId = season.id;
        _episodePage = 0;
        _episodes.clear();
        _episodeHasMore = false;
        _episodesError = null;
        _episodesLoading = true;
      } else {
        _episodesLoadingMore = true;
      }
    });

    try {
      final nextPage = reset ? 0 : _episodePage + 1;
      final episodePage = await context.read<TomatoApi>().fetchEpisodePage(
        season.id,
        page: nextPage,
      );
      if (!mounted || _episodesSeasonId != season.id) return;
      setState(() {
        _episodePage = nextPage;
        _episodes.addAll(episodePage.items);
        _episodeHasMore =
            episodePage.items.isNotEmpty &&
            _episodes.length < episodePage.total;
        _episodesError = null;
      });
    } catch (error) {
      if (!mounted || _episodesSeasonId != season.id) return;
      setState(() => _episodesError = error.toString());
    } finally {
      if (mounted && _episodesSeasonId == season.id) {
        setState(() {
          _episodesLoading = false;
          _episodesLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<AnimeDetails>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DetailsError(error: snapshot.error.toString());
          }

          final anime = snapshot.data!;
          final season =
              _selectedSeason ??
              (anime.seasons.isNotEmpty ? anime.seasons.first : null);
          if (season != null && _episodesSeasonId != season.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _episodesSeasonId == season.id) return;
              _selectSeason(season);
            });
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  Consumer<AppController>(
                    builder: (context, controller, _) {
                      final favorite = controller.isFavorite(anime.id);
                      return IconButton(
                        tooltip: favorite
                            ? 'Remover dos favoritos'
                            : 'Adicionar aos favoritos',
                        onPressed: () => controller.toggleFavorite(anime),
                        icon: Icon(
                          favorite ? LucideIcons.heartOff : LucideIcons.heart,
                          color: favorite ? AppTheme.primaryOf(context) : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 56,
                    bottom: 14,
                    end: 16,
                  ),
                  title: Text(
                    anime.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(url: anime.bannerUrl, borderRadius: 0),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.3),
                              AppTheme.bgOf(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 112,
                        child: AspectRatio(
                          aspectRatio: 0.68,
                          child: PosterImage(url: anime.capeUrl),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Pill(
                                  label: anime.year,
                                  icon: LucideIcons.calendar,
                                ),
                                Pill(
                                  label: anime.rating,
                                  icon: LucideIcons.shield,
                                  color: AppTheme.goldOf(context),
                                ),
                                if (anime.dubAvailable)
                                  const Pill(
                                    label: 'Dublado',
                                    icon: LucideIcons.check,
                                  ),
                                if (anime.releaseDay.isNotEmpty)
                                  Pill(
                                    label: _releaseDayLabel(anime.releaseDay),
                                    icon: LucideIcons.calendar,
                                  ),
                                if (anime.notifyCapable)
                                  const Pill(
                                    label: 'Avisos',
                                    icon: LucideIcons.bell,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '${anime.episodes} episodios',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              anime.genre,
                              style: TextStyle(
                                color: AppTheme.mutedOf(context),
                                height: 1.25,
                              ),
                            ),
                            if (anime.commentsCount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.messageCircle,
                                    size: 15,
                                    color: AppTheme.mutedOf(context),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${anime.commentsCount} comentarios',
                                    style: TextStyle(
                                      color: AppTheme.mutedOf(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
                  child: Text(
                    anime.description,
                    style: TextStyle(
                      height: 1.45,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              if (anime.seasons.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      scrollDirection: Axis.horizontal,
                      itemCount: anime.seasons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = anime.seasons[index];
                        final selected = item.id == _selectedSeason?.id;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(item.name),
                          avatar: item.dubbed
                              ? const Icon(LucideIcons.check, size: 16)
                              : null,
                          onSelected: (_) => _selectSeason(item),
                        );
                      },
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Row(
                    children: [
                      const Text(
                        'Episodios',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedSeason != null)
                        Text(
                          _selectedSeason!.dubbed ? 'Dublado' : 'Legendado',
                          style: TextStyle(
                            color: AppTheme.mutedOf(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ..._buildEpisodeSlivers(
                context: context,
                season: season,
                animeName: anime.name,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildEpisodeSlivers({
    required BuildContext context,
    required AnimeSeason? season,
    required String animeName,
  }) {
    if (season == null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Nenhuma temporada disponivel.',
              style: TextStyle(color: AppTheme.mutedOf(context)),
            ),
          ),
        ),
      ];
    }
    if (_episodesLoading) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ];
    }

    final error = _episodesError;
    if (error != null && _episodes.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              error,
              style: TextStyle(color: AppTheme.mutedOf(context)),
            ),
          ),
        ),
      ];
    }
    if (_episodes.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Nenhum episodio encontrado.',
              style: TextStyle(color: AppTheme.mutedOf(context)),
            ),
          ),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final episode = _episodes[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              index == 0 ? 0 : 10,
              18,
              index == _episodes.length - 1 && !_episodeHasMore ? 26 : 0,
            ),
            child: _EpisodeCard(episode: episode, animeName: animeName),
          );
        }, childCount: _episodes.length),
      ),
      if (_episodeHasMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
            child: Center(
              child: FilledButton.icon(
                onPressed: _episodesLoadingMore
                    ? null
                    : () => _loadEpisodes(season, reset: false),
                icon: _episodesLoadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.plus),
                label: Text(
                  _episodesLoadingMore ? 'Carregando...' : 'Carregar mais',
                ),
              ),
            ),
          ),
        ),
    ];
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({required this.episode, required this.animeName});

  final Episode episode;
  final String animeName;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await context.read<AppController>().addHistory(
          episode: episode,
          animeName: animeName,
        );
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlayerPage(episodeId: episode.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.panelOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 126,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PosterImage(url: episode.thumbnail, borderRadius: 14),
                    const Center(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primary,
                        child: Icon(
                          LucideIcons.play,
                          size: 18,
                          color: AppTheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.fileClock,
                        size: 15,
                        color: AppTheme.mutedOf(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${episode.minutes} min',
                        style: TextStyle(color: AppTheme.mutedOf(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: AppTheme.mutedOf(context)),
          ],
        ),
      ),
    );
  }
}

String _releaseDayLabel(String value) {
  return switch (value.toUpperCase()) {
    'SUN' => 'Domingo',
    'MON' => 'Segunda',
    'TUE' => 'Terca',
    'WED' => 'Quarta',
    'THU' => 'Quinta',
    'FRI' => 'Sexta',
    'SAT' => 'Sabado',
    _ => value,
  };
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedOf(context)),
          ),
        ),
      ),
    );
  }
}
