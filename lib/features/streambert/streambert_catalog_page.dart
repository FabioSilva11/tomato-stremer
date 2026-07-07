import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/api/streambert_api.dart';
import '../../core/models/streambert_models.dart';
import '../../core/state/app_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import 'streambert_media_details_page.dart';

class StreambertCatalogPage extends StatefulWidget {
  const StreambertCatalogPage({super.key});

  @override
  State<StreambertCatalogPage> createState() => _StreambertCatalogPageState();
}

class _StreambertCatalogPageState extends State<StreambertCatalogPage> {
  final _tokenController = TextEditingController();
  final _searchController = TextEditingController();
  Future<List<StreambertMediaItem>>? _searchFuture;
  String _activeQuery = '';
  var _requestedInitialLoad = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _ensureCatalogLoaded(AppController controller) {
    if (_requestedInitialLoad ||
        !controller.hasTmdbToken ||
        controller.streambertCatalog != null ||
        controller.streambertLoading) {
      return;
    }
    _requestedInitialLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppController>().loadStreambertCatalog();
    });
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text;
    FocusScope.of(context).unfocus();
    _requestedInitialLoad = true;
    await context.read<AppController>().saveTmdbToken(token);
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.length < 2) return;
    final token = context.read<AppController>().tmdbToken;
    setState(() {
      _activeQuery = query;
      _searchFuture = context.read<StreambertApi>().search(query, token: token);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _activeQuery = '';
      _searchFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    _ensureCatalogLoaded(controller);

    if (!controller.hasTmdbToken) {
      return _TokenSetup(controller: _tokenController, onSave: _saveToken);
    }

    final catalog = controller.streambertCatalog;
    return Scaffold(
      appBar: AppBar(
        title: const Text('StreamBert'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: controller.streambertLoading
                ? null
                : controller.loadStreambertCatalog,
            icon: const Icon(LucideIcons.refreshCw),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadStreambertCatalog,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submitSearch,
                  decoration: InputDecoration(
                    hintText: 'Buscar filmes e series',
                    prefixIcon: const Icon(LucideIcons.search),
                    suffixIcon: _activeQuery.isEmpty
                        ? IconButton(
                            tooltip: 'Buscar',
                            onPressed: () =>
                                _submitSearch(_searchController.text),
                            icon: const Icon(LucideIcons.chevronRight),
                          )
                        : IconButton(
                            tooltip: 'Limpar',
                            onPressed: _clearSearch,
                            icon: const Icon(LucideIcons.x),
                          ),
                  ),
                ),
              ),
            ),
            if (_searchFuture != null)
              _SearchResultsSliver(query: _activeQuery, future: _searchFuture!)
            else if (controller.streambertLoading && catalog == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.streambertError != null && catalog == null)
              SliverFillRemaining(
                child: _StreambertError(
                  error: controller.streambertError!,
                  onRetry: controller.loadStreambertCatalog,
                ),
              )
            else if (catalog == null || catalog.isEmpty)
              SliverFillRemaining(
                child: _StreambertError(
                  error: 'Nenhuma categoria StreamBert foi carregada.',
                  onRetry: controller.loadStreambertCatalog,
                ),
              )
            else
              for (final section in catalog.sections)
                SliverToBoxAdapter(child: _StreambertSection(section: section)),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}

class _TokenSetup extends StatelessWidget {
  const _TokenSetup({required this.controller, required this.onSave});

  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StreamBert')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 28),
        children: [
          Icon(
            LucideIcons.keyRound,
            size: 42,
            color: AppTheme.primaryOf(context),
          ),
          const SizedBox(height: 18),
          const Text(
            'Token TMDB',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Text(
            'O StreamBert usa metadados do TMDB para catalogo, busca, imagens e temporadas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedOf(context), height: 1.35),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: controller,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSave(),
            decoration: const InputDecoration(
              hintText: 'Cole o Read Access Token',
              prefixIcon: Icon(LucideIcons.keyRound),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(LucideIcons.save),
            label: const Text('Salvar e carregar'),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsSliver extends StatelessWidget {
  const _SearchResultsSliver({required this.query, required this.future});

  final String query;
  final Future<List<StreambertMediaItem>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StreambertMediaItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: _StreambertError(error: snapshot.error.toString()),
          );
        }
        final items = snapshot.data ?? const [];
        if (items.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhum resultado para "$query".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.mutedOf(context)),
                ),
              ),
            ),
          );
        }
        return SliverList.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                index == 0 ? 0 : 0,
                18,
                index == items.length - 1 ? 24 : 0,
              ),
              child: _StreambertListTile(item: items[index]),
            );
          },
        );
      },
    );
  }
}

class _StreambertSection extends StatelessWidget {
  const _StreambertSection({required this.section});

  final StreambertCategory section;

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
              section.title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            height: 258,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: section.items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _StreambertPosterCard(item: section.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StreambertPosterCard extends StatelessWidget {
  const _StreambertPosterCard({required this.item});

  final StreambertMediaItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDetails(context, item),
      child: SizedBox(
        width: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.68,
              child: PosterImage(url: item.posterUrl),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, height: 1.1),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Pill(
                  label: item.type.label,
                  icon: item.type == StreambertMediaType.movie
                      ? LucideIcons.film
                      : LucideIcons.tv,
                ),
                if (item.year.isNotEmpty)
                  Pill(label: item.year, icon: LucideIcons.calendar),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreambertListTile extends StatelessWidget {
  const _StreambertListTile({required this.item});

  final StreambertMediaItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openDetails(context, item),
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
              width: 82,
              child: AspectRatio(
                aspectRatio: 0.68,
                child: PosterImage(url: item.posterUrl, borderRadius: 14),
              ),
            ),
            const SizedBox(width: 14),
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
                        Pill(label: item.year, icon: LucideIcons.calendar),
                      Pill(
                        label: item.ratingLabel,
                        icon: LucideIcons.star,
                        color: AppTheme.goldOf(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  if (item.overview.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.mutedOf(context),
                        height: 1.2,
                      ),
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

class _StreambertError extends StatelessWidget {
  const _StreambertError({required this.error, this.onRetry});

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
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
              'Nao foi possivel carregar o StreamBert',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedOf(context)),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void _openDetails(BuildContext context, StreambertMediaItem item) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => StreambertMediaDetailsPage(item: item)),
  );
}
