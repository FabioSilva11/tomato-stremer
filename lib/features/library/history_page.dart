import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/library_models.dart';
import '../../core/state/app_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import '../player/player_page.dart';
import 'library_empty_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<AppController>().history;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Limpar historico',
              icon: const Icon(LucideIcons.trash2),
              onPressed: () => context.read<AppController>().clearHistory(),
            ),
        ],
      ),
      body: history.isEmpty
          ? const LibraryEmptyState(
              icon: LucideIcons.history,
              title: 'Nada assistido ainda',
              message: 'Os episodios abertos aparecem aqui automaticamente.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _HistoryCard(entry: history[index]);
              },
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final WatchHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayerPage(episodeId: entry.episodeId),
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
              width: 132,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PosterImage(url: entry.thumbnail, borderRadius: 14),
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
                    entry.animeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _episodeTitle(entry),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.mutedOf(context),
                      height: 1.2,
                    ),
                  ),
                  if (entry.hasProgress && entry.progress < 0.92) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Continuar de ${_formatDuration(entry.playbackPosition)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: entry.progress,
                        minHeight: 4,
                        backgroundColor: AppTheme.mutedOf(
                          context,
                        ).withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: AppTheme.mutedOf(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _formatWatchedAt(entry.watchedAt),
                        style: TextStyle(
                          color: AppTheme.mutedOf(context),
                          fontSize: 12,
                        ),
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

  String _episodeTitle(WatchHistoryEntry entry) {
    if (entry.episodeName.startsWith('${entry.episodeNumber}.')) {
      return entry.episodeName;
    }
    if (entry.episodeNumber <= 0) return entry.episodeName;
    return '${entry.episodeNumber}. ${entry.episodeName}';
  }

  String _formatWatchedAt(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    if (date == today) return 'Hoje';
    if (date == today.subtract(const Duration(days: 1))) return 'Ontem';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
