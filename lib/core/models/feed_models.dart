class FeedResponse {
  FeedResponse({required this.sections});

  final List<FeedSection> sections;

  FeedResponse copyWith({List<FeedSection>? sections}) {
    return FeedResponse(sections: sections ?? this.sections);
  }

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return FeedResponse(
      sections: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) => FeedSection.fromJson(item.cast<String, dynamic>()),
                )
                .where((section) => section.isRenderable)
                .toList()
          : const [],
    );
  }
}

class FeedSection {
  FeedSection({
    required this.type,
    required this.title,
    required this.items,
    this.hyperTitle,
    this.banner,
    this.text,
    this.tags,
    this.year,
    this.rating,
    this.animeId,
    this.episodeId,
  });

  final int type;
  final String title;
  final List<FeedItem> items;
  final String? hyperTitle;
  final String? banner;
  final String? text;
  final String? tags;
  final String? year;
  final String? rating;
  final int? animeId;
  final int? episodeId;

  bool get isFeature => type == 6 && banner != null && animeId != null;
  bool get isEpisodeSection => type == 7;
  bool get isBannerSection => type == 3;
  bool get isPosterSection => type == 5 || type == 3;
  bool get isRenderable => isFeature || items.isNotEmpty;

  FeedSection copyWith({List<FeedItem>? items}) {
    return FeedSection(
      type: type,
      title: title,
      items: items ?? this.items,
      hyperTitle: hyperTitle,
      banner: banner,
      text: text,
      tags: tags,
      year: year,
      rating: rating,
      animeId: animeId,
      episodeId: episodeId,
    );
  }

  factory FeedSection.fromJson(Map<String, dynamic> json) {
    final rawItems = json['data'];
    return FeedSection(
      type: (json['type'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map((item) => FeedItem.fromJson(item.cast<String, dynamic>()))
                .where((item) => item.thumbnail.isNotEmpty)
                .toList()
          : const [],
      hyperTitle: json['hyper_title']?.toString(),
      banner: json['banner']?.toString(),
      text: json['text']?.toString(),
      tags: json['tags']?.toString(),
      year: json['year']?.toString(),
      rating: json['rating']?.toString(),
      animeId: (json['anime_id'] as num?)?.toInt(),
      episodeId: (json['episode_id'] as num?)?.toInt(),
    );
  }
}

class FeedItem {
  FeedItem({
    required this.animeId,
    required this.thumbnail,
    this.episodeId,
    this.animeName,
    this.episodeName,
    this.dubbed,
    this.tagId,
  });

  final int animeId;
  final String thumbnail;
  final int? episodeId;
  final String? animeName;
  final String? episodeName;
  final bool? dubbed;
  final int? tagId;

  String get title {
    final name = animeName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return animeId > 0 ? 'Anime #$animeId' : 'Anime';
  }

  FeedItem copyWith({String? animeName}) {
    return FeedItem(
      animeId: animeId,
      thumbnail: thumbnail,
      episodeId: episodeId,
      animeName: animeName ?? this.animeName,
      episodeName: episodeName,
      dubbed: dubbed,
      tagId: tagId,
    );
  }

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      animeId:
          (json['anime_id'] as num?)?.toInt() ??
          (json['ep_anime_id'] as num?)?.toInt() ??
          0,
      thumbnail:
          (json['thumbnail'] ?? json['ep_thumbnail'] ?? json['image'] ?? '')
              .toString(),
      episodeId: (json['ep_id'] as num?)?.toInt(),
      animeName: json['anime_name']?.toString(),
      episodeName: json['ep_name']?.toString(),
      dubbed: json['dubbed'] is bool ? json['dubbed'] as bool : null,
      tagId: (json['tag_id'] as num?)?.toInt(),
    );
  }
}

class SearchItem {
  SearchItem({
    required this.id,
    required this.type,
    required this.name,
    required this.episodes,
    required this.date,
    required this.image,
    required this.tags,
  });

  final int id;
  final String type;
  final String name;
  final int episodes;
  final String date;
  final String image;
  final String tags;

  factory SearchItem.fromJson(Map<String, dynamic> json) {
    return SearchItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      episodes: (json['episodes'] as num?)?.toInt() ?? 0,
      date: (json['date'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      tags: (json['tags'] ?? '').toString(),
    );
  }
}
