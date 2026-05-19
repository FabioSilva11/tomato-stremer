import 'anime_models.dart';
import 'feed_models.dart';

class SavedAnime {
  const SavedAnime({
    required this.animeId,
    required this.name,
    required this.image,
    required this.description,
    required this.genre,
    required this.year,
    required this.rating,
    required this.episodes,
    required this.updatedAt,
  });

  final int animeId;
  final String name;
  final String image;
  final String description;
  final String genre;
  final String year;
  final String rating;
  final int episodes;
  final DateTime updatedAt;

  factory SavedAnime.fromAnime(AnimeDetails anime) {
    return SavedAnime(
      animeId: anime.id,
      name: anime.name,
      image: anime.capeUrl.isNotEmpty ? anime.capeUrl : anime.coverUrl,
      description: anime.description,
      genre: anime.genre,
      year: anime.year,
      rating: anime.rating,
      episodes: anime.episodes,
      updatedAt: DateTime.now(),
    );
  }

  factory SavedAnime.fromMap(Map<String, Object?> map) {
    return SavedAnime(
      animeId: map['anime_id'] as int,
      name: (map['name'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      genre: (map['genre'] ?? '').toString(),
      year: (map['year'] ?? '').toString(),
      rating: (map['rating'] ?? '').toString(),
      episodes: (map['episodes'] as int?) ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updated_at'] as int?) ?? 0,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'anime_id': animeId,
      'name': name,
      'image': image,
      'description': description,
      'genre': genre,
      'year': year,
      'rating': rating,
      'episodes': episodes,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class WatchHistoryEntry {
  const WatchHistoryEntry({
    required this.episodeId,
    required this.animeId,
    required this.seasonId,
    required this.episodeNumber,
    required this.episodeName,
    required this.animeName,
    required this.thumbnail,
    required this.minutes,
    required this.playbackPosition,
    required this.duration,
    required this.watchedAt,
  });

  final int episodeId;
  final int animeId;
  final int seasonId;
  final int episodeNumber;
  final String episodeName;
  final String animeName;
  final String thumbnail;
  final int minutes;
  final Duration playbackPosition;
  final Duration duration;
  final DateTime watchedAt;

  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (playbackPosition.inMilliseconds / total).clamp(0, 1);
  }

  bool get hasProgress => playbackPosition.inSeconds > 5;

  factory WatchHistoryEntry.fromEpisode({
    required Episode episode,
    required String animeName,
  }) {
    return WatchHistoryEntry(
      episodeId: episode.id,
      animeId: episode.animeId,
      seasonId: episode.seasonId,
      episodeNumber: episode.number,
      episodeName: episode.name,
      animeName: animeName,
      thumbnail: episode.thumbnail,
      minutes: episode.minutes,
      playbackPosition: Duration.zero,
      duration: Duration.zero,
      watchedAt: DateTime.now(),
    );
  }

  factory WatchHistoryEntry.fromStream(EpisodeStream stream) {
    return WatchHistoryEntry(
      episodeId: stream.episodeId,
      animeId: stream.animeId,
      seasonId: 0,
      episodeNumber: stream.episodeNumber,
      episodeName: stream.title,
      animeName: 'Anime #${stream.animeId}',
      thumbnail: '',
      minutes: 0,
      playbackPosition: Duration.zero,
      duration: Duration.zero,
      watchedAt: DateTime.now(),
    );
  }

  factory WatchHistoryEntry.fromFeedItem(FeedItem item) {
    return WatchHistoryEntry(
      episodeId: item.episodeId ?? 0,
      animeId: item.animeId,
      seasonId: 0,
      episodeNumber: 0,
      episodeName: item.episodeName ?? 'Novo episodio',
      animeName: item.animeName ?? 'Anime #${item.animeId}',
      thumbnail: item.thumbnail,
      minutes: 0,
      playbackPosition: Duration.zero,
      duration: Duration.zero,
      watchedAt: DateTime.now(),
    );
  }

  factory WatchHistoryEntry.fromNotification(EpisodeNotification item) {
    return WatchHistoryEntry(
      episodeId: item.episodeId,
      animeId: item.animeId,
      seasonId: 0,
      episodeNumber: 0,
      episodeName: item.episodeName,
      animeName: item.animeName,
      thumbnail: item.thumbnail,
      minutes: 0,
      playbackPosition: Duration.zero,
      duration: Duration.zero,
      watchedAt: DateTime.now(),
    );
  }

  factory WatchHistoryEntry.fromMap(Map<String, Object?> map) {
    return WatchHistoryEntry(
      episodeId: map['episode_id'] as int,
      animeId: (map['anime_id'] as int?) ?? 0,
      seasonId: (map['season_id'] as int?) ?? 0,
      episodeNumber: (map['episode_number'] as int?) ?? 0,
      episodeName: (map['episode_name'] ?? '').toString(),
      animeName: (map['anime_name'] ?? '').toString(),
      thumbnail: (map['thumbnail'] ?? '').toString(),
      minutes: (map['minutes'] as int?) ?? 0,
      playbackPosition: Duration(
        milliseconds: (map['playback_position_ms'] as int?) ?? 0,
      ),
      duration: Duration(milliseconds: (map['duration_ms'] as int?) ?? 0),
      watchedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['watched_at'] as int?) ?? 0,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'episode_id': episodeId,
      'anime_id': animeId,
      'season_id': seasonId,
      'episode_number': episodeNumber,
      'episode_name': episodeName,
      'anime_name': animeName,
      'thumbnail': thumbnail,
      'minutes': minutes,
      'playback_position_ms': playbackPosition.inMilliseconds,
      'duration_ms': duration.inMilliseconds,
      'watched_at': watchedAt.millisecondsSinceEpoch,
    };
  }

  WatchHistoryEntry copyWith({
    Duration? playbackPosition,
    Duration? duration,
    DateTime? watchedAt,
  }) {
    return WatchHistoryEntry(
      episodeId: episodeId,
      animeId: animeId,
      seasonId: seasonId,
      episodeNumber: episodeNumber,
      episodeName: episodeName,
      animeName: animeName,
      thumbnail: thumbnail,
      minutes: minutes,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      duration: duration ?? this.duration,
      watchedAt: watchedAt ?? this.watchedAt,
    );
  }
}

class EpisodeNotification {
  const EpisodeNotification({
    required this.id,
    required this.episodeId,
    required this.animeId,
    required this.animeName,
    required this.episodeName,
    required this.thumbnail,
    required this.dubbed,
    required this.createdAt,
    this.readAt,
  });

  final int id;
  final int episodeId;
  final int animeId;
  final String animeName;
  final String episodeName;
  final String thumbnail;
  final bool dubbed;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get unread => readAt == null;

  factory EpisodeNotification.fromMap(Map<String, Object?> map) {
    final readValue = map['read_at'] as int?;
    return EpisodeNotification(
      id: map['id'] as int,
      episodeId: map['episode_id'] as int,
      animeId: (map['anime_id'] as int?) ?? 0,
      animeName: (map['anime_name'] ?? '').toString(),
      episodeName: (map['episode_name'] ?? '').toString(),
      thumbnail: (map['thumbnail'] ?? '').toString(),
      dubbed: ((map['dubbed'] as int?) ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? 0,
      ),
      readAt: readValue == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(readValue),
    );
  }
}
