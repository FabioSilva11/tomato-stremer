import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/library_models.dart';
import '../../core/state/app_controller.dart';
import '../../shared/widgets/poster_image.dart';
import '../../theme/app_theme.dart';
import '../player/player_page.dart';
import 'library_empty_state.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<AppController>().notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        actions: [
          IconButton(
            tooltip: 'Verificar episodios',
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => context.read<AppController>().loadHome(),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const LibraryEmptyState(
              icon: LucideIcons.bell,
              title: 'Sem avisos novos',
              message:
                  'Quando a API listar episodios novos, eles aparecem aqui.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _NotificationCard(item: notifications[index]);
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final EpisodeNotification item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await context.read<AppController>().addNotificationHistory(item);
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PlayerPage(episodeId: item.episodeId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: item.unread
              ? AppTheme.primary.withValues(alpha: 0.12)
              : AppTheme.panelOf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.unread
                ? AppTheme.primary.withValues(alpha: 0.42)
                : Colors.white.withValues(alpha: 0.06),
          ),
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
                    PosterImage(url: item.thumbnail, borderRadius: 14),
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
                  Row(
                    children: [
                      if (item.unread)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            LucideIcons.sparkles,
                            size: 15,
                            color: AppTheme.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          item.animeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.episodeName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.mutedOf(context),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.dubbed)
                        const Pill(label: 'Dublado', icon: LucideIcons.check),
                      Pill(
                        label: _formatCreatedAt(item.createdAt),
                        icon: LucideIcons.clock,
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

  String _formatCreatedAt(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    if (date == today) return 'Hoje';
    if (date == today.subtract(const Duration(days: 1))) return 'Ontem';
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}
