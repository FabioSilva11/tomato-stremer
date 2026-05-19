import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/library_models.dart';
import '../../core/state/app_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import '../details/anime_details_page.dart';
import 'library_empty_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<AppController>().favorites;
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favorites.isEmpty
          ? const LibraryEmptyState(
              icon: LucideIcons.heart,
              title: 'Nenhum favorito ainda',
              message: 'Abra um anime e toque no coracao para salvar aqui.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _FavoriteCard(anime: favorites[index]);
              },
            ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({required this.anime});

  final SavedAnime anime;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnimeDetailsPage(animeId: anime.animeId),
        ),
      ),
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
                child: PosterImage(url: anime.image, borderRadius: 14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (anime.year.isNotEmpty)
                        Pill(label: anime.year, icon: LucideIcons.calendar),
                      if (anime.rating.isNotEmpty)
                        Pill(
                          label: anime.rating,
                          icon: LucideIcons.shield,
                          color: AppTheme.goldOf(context),
                        ),
                      Pill(
                        label: '${anime.episodes} eps',
                        icon: LucideIcons.layers,
                      ),
                    ],
                  ),
                  if (anime.genre.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      anime.genre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
