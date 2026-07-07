enum StreambertMediaType {
  movie,
  tv;

  String get tmdbPath => this == StreambertMediaType.movie ? 'movie' : 'tv';

  String get label => this == StreambertMediaType.movie ? 'Filme' : 'Serie';
}

class StreambertCatalog {
  const StreambertCatalog({required this.sections});

  final List<StreambertCategory> sections;

  bool get isEmpty => sections.every((section) => section.items.isEmpty);
}

class StreambertCategory {
  const StreambertCategory({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<StreambertMediaItem> items;
}

class StreambertMediaItem {
  const StreambertMediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  final int id;
  final StreambertMediaType type;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final String releaseDate;
  final double voteAverage;

  String get key => '${type.tmdbPath}_$id';

  String get posterUrl => _imageUrl(posterPath, 'w500');

  String get backdropUrl => _imageUrl(backdropPath, 'w780');

  String get year => releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';

  String get ratingLabel =>
      voteAverage <= 0 ? 'TMDB' : voteAverage.toStringAsFixed(1);

  factory StreambertMediaItem.fromJson(
    Map<String, dynamic> json,
    StreambertMediaType fallbackType,
  ) {
    final rawType = json['media_type']?.toString();
    final type = rawType == 'tv'
        ? StreambertMediaType.tv
        : rawType == 'movie'
        ? StreambertMediaType.movie
        : fallbackType;
    return StreambertMediaItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: type,
      title: (json['title'] ?? json['name'] ?? '').toString(),
      overview: (json['overview'] ?? '').toString(),
      posterPath: (json['poster_path'] ?? '').toString(),
      backdropPath: (json['backdrop_path'] ?? '').toString(),
      releaseDate: (json['release_date'] ?? json['first_air_date'] ?? '')
          .toString(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    );
  }
}

class StreambertMediaDetails {
  const StreambertMediaDetails({
    required this.item,
    required this.genres,
    required this.runtimeMinutes,
    required this.seasons,
  });

  final StreambertMediaItem item;
  final List<String> genres;
  final int runtimeMinutes;
  final List<StreambertSeason> seasons;

  String get genresLabel => genres.join(', ');

  factory StreambertMediaDetails.fromJson(
    Map<String, dynamic> json,
    StreambertMediaType type,
  ) {
    final rawGenres = json['genres'];
    final rawSeasons = json['seasons'];
    final episodeRunTime = json['episode_run_time'];
    final runtime = type == StreambertMediaType.movie
        ? (json['runtime'] as num?)?.toInt() ?? 0
        : episodeRunTime is List && episodeRunTime.isNotEmpty
        ? (episodeRunTime.first as num?)?.toInt() ?? 0
        : 0;
    return StreambertMediaDetails(
      item: StreambertMediaItem.fromJson(json, type),
      genres: rawGenres is List
          ? rawGenres
                .whereType<Map>()
                .map((item) => (item['name'] ?? '').toString())
                .where((name) => name.isNotEmpty)
                .toList()
          : const [],
      runtimeMinutes: runtime,
      seasons: rawSeasons is List
          ? rawSeasons
                .whereType<Map>()
                .map(
                  (item) =>
                      StreambertSeason.fromJson(item.cast<String, dynamic>()),
                )
                .where((season) => season.episodeCount > 0)
                .toList()
          : const [],
    );
  }
}

class StreambertSeason {
  const StreambertSeason({
    required this.id,
    required this.name,
    required this.seasonNumber,
    required this.episodeCount,
    required this.posterPath,
    required this.airDate,
  });

  final int id;
  final String name;
  final int seasonNumber;
  final int episodeCount;
  final String posterPath;
  final String airDate;

  String get label => seasonNumber == 0 ? 'Especiais' : 'T$seasonNumber';

  factory StreambertSeason.fromJson(Map<String, dynamic> json) {
    return StreambertSeason(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
      posterPath: (json['poster_path'] ?? '').toString(),
      airDate: (json['air_date'] ?? '').toString(),
    );
  }
}

class StreambertEpisode {
  const StreambertEpisode({
    required this.id,
    required this.name,
    required this.overview,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.stillPath,
    required this.airDate,
    required this.runtimeMinutes,
  });

  final int id;
  final String name;
  final String overview;
  final int episodeNumber;
  final int seasonNumber;
  final String stillPath;
  final String airDate;
  final int runtimeMinutes;

  String get stillUrl => _imageUrl(stillPath, 'w500');

  String get displayTitle => 'E$episodeNumber. $name';

  factory StreambertEpisode.fromJson(Map<String, dynamic> json) {
    return StreambertEpisode(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      overview: (json['overview'] ?? '').toString(),
      episodeNumber: (json['episode_number'] as num?)?.toInt() ?? 0,
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      stillPath: (json['still_path'] ?? '').toString(),
      airDate: (json['air_date'] ?? '').toString(),
      runtimeMinutes: (json['runtime'] as num?)?.toInt() ?? 0,
    );
  }
}

class StreambertSeasonEpisodes {
  const StreambertSeasonEpisodes({required this.episodes});

  final List<StreambertEpisode> episodes;

  factory StreambertSeasonEpisodes.fromJson(Map<String, dynamic> json) {
    final raw = json['episodes'];
    return StreambertSeasonEpisodes(
      episodes: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) =>
                      StreambertEpisode.fromJson(item.cast<String, dynamic>()),
                )
                .where((episode) => episode.episodeNumber > 0)
                .toList()
          : const [],
    );
  }
}

class StreambertPlayerSource {
  const StreambertPlayerSource({
    required this.id,
    required this.label,
    this.note,
  });

  final String id;
  final String label;
  final String? note;

  static const sources = [
    StreambertPlayerSource(id: 'videasy', label: 'Videasy'),
    StreambertPlayerSource(id: 'vidsrc', label: 'VidSrc'),
    StreambertPlayerSource(id: '2embed', label: '2Embed', note: 'instavel'),
  ];

  Uri buildUrl({
    required StreambertMediaType type,
    required int tmdbId,
    int? season,
    int? episode,
  }) {
    return switch (id) {
      'vidsrc' => Uri.parse(
        type == StreambertMediaType.movie
            ? 'https://vidsrc.to/embed/movie/$tmdbId'
            : 'https://vidsrc.to/embed/tv/$tmdbId/$season/$episode',
      ),
      '2embed' => Uri.parse(
        type == StreambertMediaType.movie
            ? 'https://www.2embed.online/embed/movie/$tmdbId'
            : 'https://www.2embed.online/embed/tv/$tmdbId/$season/$episode',
      ),
      _ => Uri.parse(
        type == StreambertMediaType.movie
            ? 'https://player.videasy.net/movie/$tmdbId'
            : 'https://player.videasy.net/tv/$tmdbId/$season/$episode',
      ),
    };
  }
}

String _imageUrl(String path, String size) {
  if (path.isEmpty) return '';
  return 'https://image.tmdb.org/t/p/$size$path';
}
