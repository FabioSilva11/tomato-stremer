import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/feed_models.dart';
import '../models/library_models.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get _db async {
    final existing = _database;
    if (existing != null) return existing;
    final path = p.join(await getDatabasesPath(), 'tomato_streaming.db');
    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            anime_id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            image TEXT NOT NULL,
            description TEXT NOT NULL,
            genre TEXT NOT NULL,
            year TEXT NOT NULL,
            rating TEXT NOT NULL,
            episodes INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE watch_history (
            episode_id INTEGER PRIMARY KEY,
            anime_id INTEGER NOT NULL,
            season_id INTEGER NOT NULL,
            episode_number INTEGER NOT NULL,
            episode_name TEXT NOT NULL,
            anime_name TEXT NOT NULL,
            thumbnail TEXT NOT NULL,
            minutes INTEGER NOT NULL,
            watched_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE known_episodes (
            episode_id INTEGER PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE episode_notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            episode_id INTEGER NOT NULL UNIQUE,
            anime_id INTEGER NOT NULL,
            anime_name TEXT NOT NULL,
            episode_name TEXT NOT NULL,
            thumbnail TEXT NOT NULL,
            dubbed INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            read_at INTEGER
          )
        ''');
        await _createAnimeTitlesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAnimeTitlesTable(db);
        }
      },
    );
    _database = db;
    return db;
  }

  Future<void> _createAnimeTitlesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS anime_titles (
        anime_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<List<SavedAnime>> loadFavorites() async {
    final db = await _db;
    final rows = await db.query('favorites', orderBy: 'updated_at DESC');
    return rows.map(SavedAnime.fromMap).toList();
  }

  Future<bool> isFavorite(int animeId) async {
    final db = await _db;
    final rows = await db.query(
      'favorites',
      columns: ['anime_id'],
      where: 'anime_id = ?',
      whereArgs: [animeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<Map<int, String>> loadAnimeTitles(Iterable<int> animeIds) async {
    final ids = animeIds.where((id) => id > 0).toSet().toList();
    if (ids.isEmpty) return const {};
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.query(
      'anime_titles',
      columns: ['anime_id', 'name'],
      where: 'anime_id IN ($placeholders)',
      whereArgs: ids,
    );
    return {
      for (final row in rows)
        (row['anime_id'] as int): (row['name'] ?? '').toString(),
    };
  }

  Future<void> saveAnimeTitle({
    required int animeId,
    required String name,
    required String image,
  }) async {
    if (animeId <= 0 || name.trim().isEmpty) return;
    final db = await _db;
    await db.insert('anime_titles', {
      'anime_id': animeId,
      'name': name.trim(),
      'image': image,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> saveFavorite(SavedAnime anime) async {
    final db = await _db;
    await db.insert(
      'favorites',
      anime.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(int animeId) async {
    final db = await _db;
    await db.delete('favorites', where: 'anime_id = ?', whereArgs: [animeId]);
  }

  Future<List<WatchHistoryEntry>> loadHistory() async {
    final db = await _db;
    final rows = await db.query('watch_history', orderBy: 'watched_at DESC');
    return rows.map(WatchHistoryEntry.fromMap).toList();
  }

  Future<void> saveHistory(WatchHistoryEntry entry) async {
    final db = await _db;
    final existingRows = await db.query(
      'watch_history',
      where: 'episode_id = ?',
      whereArgs: [entry.episodeId],
      limit: 1,
    );
    var values = entry.toMap();
    if (existingRows.isNotEmpty) {
      final existing = WatchHistoryEntry.fromMap(existingRows.first);
      values = {
        ...values,
        if (entry.thumbnail.isEmpty && existing.thumbnail.isNotEmpty)
          'thumbnail': existing.thumbnail,
        if (entry.animeName.startsWith('Anime #') &&
            existing.animeName.isNotEmpty)
          'anime_name': existing.animeName,
        if (entry.episodeName.isEmpty && existing.episodeName.isNotEmpty)
          'episode_name': existing.episodeName,
        if (entry.minutes == 0 && existing.minutes > 0)
          'minutes': existing.minutes,
        if (entry.seasonId == 0 && existing.seasonId > 0)
          'season_id': existing.seasonId,
      };
    }
    await db.insert(
      'watch_history',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearHistory() async {
    final db = await _db;
    await db.delete('watch_history');
  }

  Future<List<EpisodeNotification>> loadNotifications() async {
    final db = await _db;
    final rows = await db.query(
      'episode_notifications',
      orderBy: 'created_at DESC',
    );
    return rows.map(EpisodeNotification.fromMap).toList();
  }

  Future<void> markNotificationsRead() async {
    final db = await _db;
    await db.update('episode_notifications', {
      'read_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'read_at IS NULL');
  }

  Future<int> syncNewEpisodes(FeedResponse feed) async {
    final episodes = <FeedItem>[];
    for (final section in feed.sections) {
      if (!section.isEpisodeSection) continue;
      episodes.addAll(section.items.where((item) => item.episodeId != null));
    }
    if (episodes.isEmpty) return 0;

    final db = await _db;
    final initialScanDone = await _getMeta('initial_episode_scan_done') == '1';
    var newCount = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      for (final item in episodes) {
        final episodeId = item.episodeId!;
        final known = await txn.query(
          'known_episodes',
          columns: ['episode_id'],
          where: 'episode_id = ?',
          whereArgs: [episodeId],
          limit: 1,
        );
        if (known.isNotEmpty) continue;

        await txn.insert('known_episodes', {'episode_id': episodeId});
        if (!initialScanDone) continue;

        newCount++;
        await txn.insert('episode_notifications', {
          'episode_id': episodeId,
          'anime_id': item.animeId,
          'anime_name': item.animeName ?? 'Anime #${item.animeId}',
          'episode_name': item.episodeName ?? 'Novo episodio',
          'thumbnail': item.thumbnail,
          'dubbed': item.dubbed == true ? 1 : 0,
          'created_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      if (!initialScanDone) {
        await txn.insert('meta', {
          'key': 'initial_episode_scan_done',
          'value': '1',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    return newCount;
  }

  Future<String?> _getMeta(String key) async {
    final db = await _db;
    final rows = await db.query(
      'meta',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value']?.toString();
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }
}
