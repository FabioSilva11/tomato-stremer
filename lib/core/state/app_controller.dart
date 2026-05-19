import 'package:flutter/foundation.dart';

import '../api/tomato_api.dart';
import '../models/anime_models.dart';
import '../models/feed_models.dart';
import '../models/library_models.dart';
import '../storage/app_database.dart';

class AppController extends ChangeNotifier {
  AppController({required TomatoApi api, required AppDatabase database})
    : _api = api,
      _database = database;

  final TomatoApi _api;
  final AppDatabase _database;

  bool loading = false;
  String? error;
  FeedResponse? feed;
  List<SavedAnime> favorites = const [];
  List<WatchHistoryEntry> history = const [];
  List<EpisodeNotification> notifications = const [];
  int lastNewEpisodeCount = 0;

  int get unreadNotifications =>
      notifications.where((item) => item.unread).length;

  Set<int> get watchedEpisodeIds =>
      history.map((entry) => entry.episodeId).toSet();

  Map<int, WatchHistoryEntry> get historyByEpisode => {
    for (final entry in history) entry.episodeId: entry,
  };

  Future<void> initialize() async {
    await loadLibrary();
    await loadHome();
  }

  Future<void> loadHome() async {
    loading = true;
    error = null;
    lastNewEpisodeCount = 0;
    notifyListeners();

    try {
      feed = await _enrichFeedTitles(await _api.fetchFeed());
      lastNewEpisodeCount = await _database.syncNewEpisodes(feed!);
      await loadLibrary(notify: false);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadLibrary({bool notify = true}) async {
    favorites = await _database.loadFavorites();
    history = await _database.loadHistory();
    notifications = await _database.loadNotifications();
    if (notify) notifyListeners();
  }

  bool isFavorite(int animeId) {
    return favorites.any((item) => item.animeId == animeId);
  }

  Future<void> toggleFavorite(AnimeDetails anime) async {
    if (isFavorite(anime.id)) {
      await _database.removeFavorite(anime.id);
    } else {
      await _database.saveFavorite(SavedAnime.fromAnime(anime));
    }
    await loadLibrary();
  }

  Future<void> addHistory({
    required Episode episode,
    required String animeName,
  }) async {
    await _database.saveHistory(
      WatchHistoryEntry.fromEpisode(episode: episode, animeName: animeName),
    );
    await loadLibrary();
  }

  Future<void> addStreamHistory(EpisodeStream stream) async {
    await _database.saveHistory(WatchHistoryEntry.fromStream(stream));
    await loadLibrary();
  }

  Future<void> addFeedHistory(FeedItem item) async {
    if (item.episodeId == null) return;
    await _database.saveHistory(WatchHistoryEntry.fromFeedItem(item));
    await loadLibrary();
  }

  Future<void> addNotificationHistory(EpisodeNotification item) async {
    await _database.saveHistory(WatchHistoryEntry.fromNotification(item));
    await loadLibrary();
  }

  WatchHistoryEntry? historyForEpisode(int episodeId) {
    for (final entry in history) {
      if (entry.episodeId == episodeId) return entry;
    }
    return null;
  }

  Future<WatchHistoryEntry?> loadHistoryForEpisode(int episodeId) async {
    return _database.findHistory(episodeId);
  }

  Future<void> savePlaybackProgress({
    required int episodeId,
    required Duration position,
    required Duration duration,
    bool notify = false,
  }) async {
    await _database.savePlaybackProgress(
      episodeId: episodeId,
      position: position,
      duration: duration,
    );
    await loadLibrary(notify: notify);
  }

  Future<void> clearHistory() async {
    await _database.clearHistory();
    await loadLibrary();
  }

  Future<void> markNotificationsRead() async {
    await _database.markNotificationsRead();
    await loadLibrary();
  }

  Future<FeedResponse> _enrichFeedTitles(FeedResponse source) async {
    final missingIds = <int>{};
    for (final section in source.sections) {
      for (final item in section.items) {
        final hasName = (item.animeName ?? '').trim().isNotEmpty;
        if (!hasName && item.animeId > 0) {
          missingIds.add(item.animeId);
        }
      }
    }
    if (missingIds.isEmpty) return source;

    final titles = await _database.loadAnimeTitles(missingIds);
    final uncachedIds = missingIds
        .where((id) => !titles.containsKey(id))
        .toList();
    final loadedTitles = await _loadMissingTitles(uncachedIds);
    final resolvedTitles = {...titles, ...loadedTitles};

    return source.copyWith(
      sections: [
        for (final section in source.sections)
          section.copyWith(
            items: [
              for (final item in section.items)
                _withResolvedTitle(item, resolvedTitles),
            ],
          ),
      ],
    );
  }

  FeedItem _withResolvedTitle(FeedItem item, Map<int, String> titles) {
    final currentName = item.animeName?.trim();
    if (currentName != null && currentName.isNotEmpty) return item;
    final title = titles[item.animeId];
    if (title == null || title.trim().isEmpty) return item;
    return item.copyWith(animeName: title);
  }

  Future<Map<int, String>> _loadMissingTitles(List<int> animeIds) async {
    final titles = <int, String>{};
    var cursor = 0;
    final workerCount = animeIds.length < 6 ? animeIds.length : 6;

    Future<void> worker() async {
      while (cursor < animeIds.length) {
        final id = animeIds[cursor++];
        try {
          final anime = await _api.fetchAnime(id);
          final image = anime.capeUrl.isNotEmpty
              ? anime.capeUrl
              : anime.coverUrl;
          if (anime.name.trim().isEmpty) continue;
          titles[id] = anime.name;
          await _database.saveAnimeTitle(
            animeId: id,
            name: anime.name,
            image: image,
          );
        } catch (error) {
          debugPrint('Falha ao carregar nome do anime $id: $error');
        }
      }
    }

    if (workerCount == 0) return titles;
    await Future.wait([for (var i = 0; i < workerCount; i++) worker()]);
    return titles;
  }
}
