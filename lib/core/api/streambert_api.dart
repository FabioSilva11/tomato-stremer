import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/streambert_models.dart';

class StreambertApi {
  StreambertApi({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String defaultToken = String.fromEnvironment('TMDB_READ_TOKEN');

  final http.Client _client;

  Future<StreambertCatalog> fetchCatalog(String token) async {
    final clean = cleanToken(token);
    if (clean.isEmpty) {
      throw const StreambertApiException(
        'Informe o token TMDB para carregar as categorias Streambert.',
      );
    }

    final sections = await Future.wait([
      _fetchCategory(
        token: clean,
        id: 'trending_movies',
        title: 'Filmes em alta',
        path: '/trending/movie/week',
        type: StreambertMediaType.movie,
      ),
      _fetchCategory(
        token: clean,
        id: 'trending_tv',
        title: 'Series em alta',
        path: '/trending/tv/week',
        type: StreambertMediaType.tv,
      ),
      _fetchMergedTopRated(clean),
      _fetchCategory(
        token: clean,
        id: 'anime_tv',
        title: 'Anime no TMDB',
        path: '/discover/tv',
        type: StreambertMediaType.tv,
        query: const {
          'with_genres': '16',
          'with_origin_country': 'JP',
          'sort_by': 'popularity.desc',
        },
      ),
      _fetchCategory(
        token: clean,
        id: 'movie_releases',
        title: 'Lancamentos de filmes',
        path: '/movie/now_playing',
        type: StreambertMediaType.movie,
      ),
      _fetchCategory(
        token: clean,
        id: 'tv_on_air',
        title: 'Series lancando agora',
        path: '/tv/on_the_air',
        type: StreambertMediaType.tv,
      ),
    ]);

    return StreambertCatalog(
      sections: sections.where((section) => section.items.isNotEmpty).toList(),
    );
  }

  Future<List<StreambertMediaItem>> search(
    String query, {
    required String token,
    int page = 1,
  }) async {
    final clean = cleanToken(token);
    if (clean.isEmpty || query.trim().isEmpty) return const [];
    final json = await _get(
      '/search/multi',
      token: clean,
      query: {'query': query.trim(), 'page': page.toString()},
    );
    return _parseItems(json, StreambertMediaType.movie)
        .where(
          (item) =>
              item.type == StreambertMediaType.movie ||
              item.type == StreambertMediaType.tv,
        )
        .toList();
  }

  Future<StreambertMediaDetails> fetchDetails({
    required String token,
    required StreambertMediaType type,
    required int id,
  }) async {
    final json = await _get('/${type.tmdbPath}/$id', token: cleanToken(token));
    return StreambertMediaDetails.fromJson(json, type);
  }

  Future<StreambertSeasonEpisodes> fetchSeason({
    required String token,
    required int tvId,
    required int seasonNumber,
  }) async {
    final json = await _get(
      '/tv/$tvId/season/$seasonNumber',
      token: cleanToken(token),
    );
    return StreambertSeasonEpisodes.fromJson(json);
  }

  Future<StreambertCategory> _fetchCategory({
    required String token,
    required String id,
    required String title,
    required String path,
    required StreambertMediaType type,
    Map<String, String> query = const {},
  }) async {
    final json = await _get(path, token: token, query: query);
    return StreambertCategory(
      id: id,
      title: title,
      items: _parseItems(json, type).take(20).toList(),
    );
  }

  Future<StreambertCategory> _fetchMergedTopRated(String token) async {
    final results = await Future.wait([
      _get('/movie/top_rated', token: token),
      _get('/tv/top_rated', token: token),
    ]);
    final movies = _parseItems(results[0], StreambertMediaType.movie).take(10);
    final tv = _parseItems(results[1], StreambertMediaType.tv).take(10);
    final merged = <StreambertMediaItem>[];
    final maxLength = movies.length > tv.length ? movies.length : tv.length;
    final movieList = movies.toList();
    final tvList = tv.toList();
    for (var i = 0; i < maxLength; i++) {
      if (i < movieList.length) merged.add(movieList[i]);
      if (i < tvList.length) merged.add(tvList[i]);
    }
    return StreambertCategory(
      id: 'top_rated',
      title: 'Melhores avaliacoes',
      items: merged,
    );
  }

  List<StreambertMediaItem> _parseItems(
    Map<String, dynamic> json,
    StreambertMediaType type,
  ) {
    final raw = json['results'];
    if (raw is! List) return const [];
    final seen = <String>{};
    final items = <StreambertMediaItem>[];
    for (final item in raw.whereType<Map>()) {
      final parsed = StreambertMediaItem.fromJson(
        item.cast<String, dynamic>(),
        type,
      );
      if (parsed.id <= 0 || parsed.title.trim().isEmpty) continue;
      if (parsed.posterPath.isEmpty && parsed.backdropPath.isEmpty) continue;
      if (!seen.add(parsed.key)) continue;
      items.add(parsed);
    }
    return items;
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    required String token,
    Map<String, String> query = const {},
  }) async {
    final clean = cleanToken(token);
    if (clean.isEmpty) {
      throw const StreambertApiException(
        'Informe o token TMDB para carregar as categorias Streambert.',
      );
    }
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: {
        'language': 'pt-BR',
        'include_adult': 'false',
        ...query,
      },
    );
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $clean'},
    );
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw const StreambertApiException(
        'Token TMDB invalido ou sem permissao.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const StreambertApiException(
        'Nao foi possivel carregar o catalogo Streambert agora.',
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const StreambertApiException(
        'Resposta invalida do catalogo Streambert.',
      );
    }
    return decoded;
  }

  static String cleanToken(String token) {
    final clean = token.trim();
    if (clean.toLowerCase().startsWith('bearer ')) {
      return clean.substring(7).trim();
    }
    return clean;
  }

  void dispose() {
    _client.close();
  }
}

class StreambertApiException implements Exception {
  const StreambertApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
