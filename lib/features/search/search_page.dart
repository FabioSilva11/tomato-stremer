import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/api/tomato_api.dart';
import '../../core/models/feed_models.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import '../details/anime_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _items = <SearchItem>[];
  var _query = '';
  var _page = 0;
  var _loading = false;
  var _loadingMore = false;
  var _hasMore = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String query) async {
    final clean = query.trim();
    if (clean.length < 2) return;
    setState(() {
      _query = clean;
      _page = 0;
      _items.clear();
      _hasMore = false;
      _error = null;
      _loading = true;
    });
    await _loadPage(reset: true);
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    await _loadPage(reset: false);
  }

  Future<void> _loadPage({required bool reset}) async {
    try {
      final nextPage = reset ? 0 : _page + 1;
      final results = await context.read<TomatoApi>().search(
        _query,
        page: nextPage,
      );
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _items.addAll(results);
        _hasMore = results.isNotEmpty;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text('Pesquisar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'Busque por anime ou manga',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: IconButton(
                  icon: const Icon(LucideIcons.chevronRight),
                  onPressed: () => _submit(_controller.text),
                ),
              ),
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final error = _error;
    if (error != null && _items.isEmpty) return _SearchError(error: error);
    if (_items.isEmpty) return const _SearchEmpty();

    final total = _items.length + (_hasMore ? 1 : 0);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      itemCount: total,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(
            child: FilledButton.icon(
              onPressed: _loadingMore ? null : _loadMore,
              icon: _loadingMore
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.plus),
              label: Text(_loadingMore ? 'Carregando...' : 'Carregar mais'),
            ),
          );
        }
        return _SearchResultCard(item: _items[index]);
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.item});

  final SearchItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: item.type == 'anime'
          ? () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AnimeDetailsPage(animeId: item.id),
              ),
            )
          : null,
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
              width: 86,
              child: AspectRatio(
                aspectRatio: 0.68,
                child: PosterImage(url: item.image, borderRadius: 14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Pill(
                        label: item.type.toUpperCase(),
                        icon: item.type == 'anime'
                            ? LucideIcons.monitor
                            : LucideIcons.bookOpen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.date,
                        style: TextStyle(
                          color: AppTheme.mutedOf(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.tags,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.mutedOf(context),
                      height: 1.2,
                    ),
                  ),
                  if (item.episodes > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${item.episodes} episodios',
                      style: const TextStyle(fontWeight: FontWeight.w700),
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

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Digite pelo menos 2 caracteres para pesquisar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.mutedOf(context)),
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  const _SearchError({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.mutedOf(context)),
        ),
      ),
    );
  }
}
