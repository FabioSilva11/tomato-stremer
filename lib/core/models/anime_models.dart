class AnimeDetails {
  AnimeDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.releaseDay,
    required this.episodes,
    required this.year,
    required this.coverUrl,
    required this.capeUrl,
    required this.bannerUrl,
    required this.genre,
    required this.dubAvailable,
    required this.liked,
    required this.favorited,
    required this.notify,
    required this.notifyCapable,
    required this.seasons,
    required this.commentsCount,
  });

  final int id;
  final String name;
  final String description;
  final String rating;
  final String releaseDay;
  final int episodes;
  final String year;
  final String coverUrl;
  final String capeUrl;
  final String bannerUrl;
  final String genre;
  final bool dubAvailable;
  final bool liked;
  final bool favorited;
  final bool notify;
  final bool notifyCapable;
  final List<AnimeSeason> seasons;
  final int commentsCount;

  factory AnimeDetails.fromJson(Map<String, dynamic> json) {
    final details =
        (json['anime_details'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawSeasons = json['anime_seasons'];
    return AnimeDetails(
      id: (details['anime_id'] as num?)?.toInt() ?? 0,
      name: (details['anime_name'] ?? '').toString(),
      description: (details['anime_description'] ?? '').toString(),
      rating: (details['anime_parental_rating'] ?? '').toString(),
      releaseDay: (details['release_day'] ?? '').toString(),
      episodes: (details['anime_episodes'] as num?)?.toInt() ?? 0,
      year: (details['anime_date'] ?? '').toString(),
      coverUrl: (details['anime_cover_url'] ?? '').toString(),
      capeUrl: (details['anime_cape_url'] ?? '').toString(),
      bannerUrl: (details['anime_banner_url'] ?? '').toString(),
      genre: (details['anime_genre'] ?? '').toString(),
      dubAvailable: details['dub_available'] == true,
      liked: json['liked'] == true,
      favorited: json['favorited'] == true,
      notify: json['notify'] == true,
      notifyCapable: json['notify_capable'] == true,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      seasons: rawSeasons is List
          ? rawSeasons
                .whereType<Map>()
                .map(
                  (item) => AnimeSeason.fromJson(item.cast<String, dynamic>()),
                )
                .toList()
          : const [],
    );
  }
}

class AnimeSeason {
  AnimeSeason({
    required this.id,
    required this.name,
    required this.number,
    required this.dubbed,
  });

  final int id;
  final String name;
  final int number;
  final bool dubbed;

  factory AnimeSeason.fromJson(Map<String, dynamic> json) {
    return AnimeSeason(
      id: (json['season_id'] as num?)?.toInt() ?? 0,
      name: (json['season_name'] ?? '').toString(),
      number: (json['season_number'] as num?)?.toInt() ?? 0,
      dubbed: ((json['season_dubbed'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

class Episode {
  Episode({
    required this.id,
    required this.name,
    required this.number,
    required this.animeId,
    required this.seasonId,
    required this.thumbnail,
    required this.minutes,
  });

  final int id;
  final String name;
  final int number;
  final int animeId;
  final int seasonId;
  final String thumbnail;
  final int minutes;

  String get displayTitle => '$number. $name';

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: (json['ep_id'] as num?)?.toInt() ?? 0,
      name: (json['ep_name'] ?? '').toString(),
      number: (json['ep_number'] as num?)?.toInt() ?? 0,
      animeId: (json['ep_anime_id'] as num?)?.toInt() ?? 0,
      seasonId: (json['ep_season_id'] as num?)?.toInt() ?? 0,
      thumbnail: (json['ep_thumbnail'] ?? '').toString(),
      minutes: (json['ep_lenght_minutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class EpisodePage {
  const EpisodePage({required this.total, required this.items});

  final int total;
  final List<Episode> items;
}

class EpisodeStream {
  EpisodeStream({
    required this.title,
    required this.animeId,
    required this.episodeId,
    required this.episodeNumber,
    required this.streams,
    this.nextEpisodeId,
    this.nextEpisodeTitle,
  });

  final String title;
  final int animeId;
  final int episodeId;
  final int episodeNumber;
  final Map<String, String> streams;
  final int? nextEpisodeId;
  final String? nextEpisodeTitle;

  String? get bestUrl => streams['fhd'] ?? streams['mhd'] ?? streams['shd'];

  factory EpisodeStream.fromJson(int episodeId, Map<String, dynamic> json) {
    final rawStreams = (json['streams'] as Map?)?.cast<String, dynamic>() ?? {};
    final streams = <String, String>{};
    for (final entry in rawStreams.entries) {
      final value = entry.value?.toString();
      if (value != null && value.trim().isNotEmpty && value != 'null') {
        streams[entry.key] = value;
      }
    }
    return EpisodeStream(
      title: (json['episodeName'] ?? '').toString(),
      animeId: (json['episodeAnimeID'] as num?)?.toInt() ?? 0,
      episodeId: episodeId,
      episodeNumber: (json['episodeNumber'] as num?)?.toInt() ?? 0,
      streams: streams,
      nextEpisodeId: (json['nextEpisodeID'] as num?)?.toInt(),
      nextEpisodeTitle: json['nextEpisodeTitle']?.toString(),
    );
  }
}
