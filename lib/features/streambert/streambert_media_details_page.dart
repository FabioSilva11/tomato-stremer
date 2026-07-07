import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/api/streambert_api.dart';
import '../../core/models/streambert_models.dart';
import '../../core/state/app_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import 'streambert_web_player_page.dart';

class StreambertMediaDetailsPage extends StatefulWidget {
  const StreambertMediaDetailsPage({super.key, required this.item});

  final StreambertMediaItem item;

  @override
  State<StreambertMediaDetailsPage> createState() =>
      _StreambertMediaDetailsPageState();
}

class _StreambertMediaDetailsPageState
    extends State<StreambertMediaDetailsPage> {
  late Future<StreambertMediaDetails> _detailsFuture;
  StreambertSeason? _selectedSeason;
  Future<StreambertSeasonEpisodes>? _seasonFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<StreambertMediaDetails> _loadDetails() async {
    final token = context.read<AppController>().tmdbToken;
    return context.read<StreambertApi>().fetchDetails(
      token: token,
      type: widget.item.type,
      id: widget.item.id,
    );
  }

  void _selectSeason(StreambertSeason season) {
    setState(() {
      _selectedSeason = season;
      _seasonFuture = context.read<StreambertApi>().fetchSeason(
        token: context.read<AppController>().tmdbToken,
        tvId: widget.item.id,
        seasonNumber: season.seasonNumber,
      );
    });
  }

  StreambertSeason? _initialSeason(List<StreambertSeason> seasons) {
    if (seasons.isEmpty) return null;
    for (final season in seasons) {
      if (season.seasonNumber > 0) return season;
    }
    return seasons.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<StreambertMediaDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DetailsError(error: snapshot.error.toString());
          }

          final details = snapshot.data!;
          final item = details.item;
          final season = _selectedSeason ?? _initialSeason(details.seasons);
          if (item.type == StreambertMediaType.tv &&
              season != null &&
              _selectedSeason == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedSeason == null) _selectSeason(season);
            });
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 292,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 56,
                    bottom: 14,
                    end: 16,
                  ),
                  title: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(url: item.backdropUrl, borderRadius: 0),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.35),
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
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 112,
                        child: AspectRatio(
                          aspectRatio: 0.68,
                          child: PosterImage(url: item.posterUrl),
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
                                  label: item.type.label,
                                  icon: item.type == StreambertMediaType.movie
                                      ? LucideIcons.film
                                      : LucideIcons.tv,
                                ),
                                if (item.year.isNotEmpty)
                                  Pill(
                                    label: item.year,
                                    icon: LucideIcons.calendar,
                                  ),
                                Pill(
                                  label: item.ratingLabel,
                                  icon: LucideIcons.star,
                                  color: AppTheme.goldOf(context),
                                ),
                                if (details.runtimeMinutes > 0)
                                  Pill(
                                    label: '${details.runtimeMinutes} min',
                                    icon: LucideIcons.clock,
                                  ),
                              ],
                            ),
                            if (details.genresLabel.isNotEmpty) ...[
                              const SizedBox(height: 13),
                              Text(
                                details.genresLabel,
                                style: TextStyle(
                                  color: AppTheme.mutedOf(context),
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.overview.trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
                    child: Text(
                      item.overview,
                      style: TextStyle(
                        height: 1.45,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              if (item.type == StreambertMediaType.movie)
                SliverToBoxAdapter(
                  child: _SourceButtons(
                    onSelect: (source) => _openSource(
                      context,
                      source: source,
                      title: item.title,
                      type: item.type,
                      tmdbId: item.id,
                    ),
                  ),
                )
              else
                ..._buildTvSlivers(details, season),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildTvSlivers(
    StreambertMediaDetails details,
    StreambertSeason? selected,
  ) {
    if (details.seasons.isEmpty || selected == null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Nenhuma temporada encontrada no TMDB.',
              style: TextStyle(color: AppTheme.mutedOf(context)),
            ),
          ),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: details.seasons.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final season = details.seasons[index];
              return ChoiceChip(
                selected: season.seasonNumber == selected.seasonNumber,
                label: Text(season.label),
                avatar: season.seasonNumber == 0
                    ? const Icon(LucideIcons.sparkles, size: 16)
                    : null,
                onSelected: (_) => _selectSeason(season),
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
              Expanded(
                child: Text(
                  selected.name.isEmpty ? selected.label : selected.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${selected.episodeCount} episodios',
                style: TextStyle(
                  color: AppTheme.mutedOf(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      FutureBuilder<StreambertSeasonEpisodes>(
        future: _seasonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snapshot.hasError) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  snapshot.error.toString(),
                  style: TextStyle(color: AppTheme.mutedOf(context)),
                ),
              ),
            );
          }
          final episodes = snapshot.data?.episodes ?? const [];
          if (episodes.isEmpty) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Nenhum episodio encontrado nessa temporada.',
                  style: TextStyle(color: AppTheme.mutedOf(context)),
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final episode = episodes[index];
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  index == 0 ? 0 : 10,
                  18,
                  index == episodes.length - 1 ? 26 : 0,
                ),
                child: _StreambertEpisodeCard(
                  episode: episode,
                  onTap: () => _showEpisodeSources(
                    context,
                    title: '${details.item.title} - ${episode.displayTitle}',
                    season: episode.seasonNumber,
                    episode: episode.episodeNumber,
                  ),
                ),
              );
            }, childCount: episodes.length),
          );
        },
      ),
    ];
  }

  Future<void> _showEpisodeSources(
    BuildContext context, {
    required String title,
    required int season,
    required int episode,
  }) async {
    final source = await showModalBottomSheet<StreambertPlayerSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SourceSheet(title: title),
    );
    if (!context.mounted || source == null) return;
    _openSource(
      context,
      source: source,
      title: title,
      type: StreambertMediaType.tv,
      tmdbId: widget.item.id,
      season: season,
      episode: episode,
    );
  }

  void _openSource(
    BuildContext context, {
    required StreambertPlayerSource source,
    required String title,
    required StreambertMediaType type,
    required int tmdbId,
    int? season,
    int? episode,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StreambertWebPlayerPage(
          url: source.buildUrl(
            type: type,
            tmdbId: tmdbId,
            season: season,
            episode: episode,
          ),
          title: title,
          sourceLabel: source.label,
        ),
      ),
    );
  }
}

class _SourceButtons extends StatelessWidget {
  const _SourceButtons({required this.onSelect});

  final ValueChanged<StreambertPlayerSource> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fontes Streambert',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final source in StreambertPlayerSource.sources)
                FilledButton.icon(
                  onPressed: () => onSelect(source),
                  icon: const Icon(LucideIcons.play, size: 18),
                  label: Text(
                    source.note == null
                        ? source.label
                        : '${source.label} (${source.note})',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final source in StreambertPlayerSource.sources)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(LucideIcons.play),
                title: Text(source.label),
                subtitle: source.note == null ? null : Text(source.note!),
                onTap: () => Navigator.of(context).pop(source),
              ),
          ],
        ),
      ),
    );
  }
}

class _StreambertEpisodeCard extends StatelessWidget {
  const _StreambertEpisodeCard({required this.episode, required this.onTap});

  final StreambertEpisode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
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
                    PosterImage(url: episode.stillUrl, borderRadius: 14),
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
                  if (episode.overview.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      episode.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.mutedOf(context),
                        height: 1.2,
                      ),
                    ),
                  ],
                  if (episode.runtimeMinutes > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${episode.runtimeMinutes} min',
                      style: TextStyle(color: AppTheme.mutedOf(context)),
                    ),
                  ],
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
