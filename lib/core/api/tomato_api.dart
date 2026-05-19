import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/anime_models.dart';
import '../models/feed_models.dart';

class TomatoApi {
  TomatoApi({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://edge.betomato.com';
  static const String maintenanceMessage =
      'Servidor em manutencao. Tente voltar mais tarde.';
  static const String devToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTU1NTAyMDgsInV1aWQiOiI1MWYwNWMxZC0xYWQwLTQxOWItOWE5MC1iOTljZGI3MGU4YTQiLCJpYXQiOjE3Njk3MTMwMzN9.tCqgd5IhVtw4M11mGGJ_d9oDoRj7nPJlW4MMBncp7z0';

  final http.Client _client;

  Map<String, String> _headers({bool json = false, bool stream = false}) {
    final headers = <String, String>{
      'Authorization': 'Bearer $devToken',
      'Accept': 'application/json, text/plain, */*',
      'Request-Time': DateTime.now().millisecondsSinceEpoch.toString(),
      'X-App': '1.4.3',
      if (json) 'Content-Type': 'application/json',
    };

    // Navegadores bloqueiam alguns headers como User-Agent e Accept-Encoding.
    // No Android/desktop eles ajudam a aproximar o comportamento do curl.
    if (!kIsWeb) {
      headers['User-Agent'] = stream ? 'tomato-android' : 'okhttp/4.11.0';
      headers['Accept-Encoding'] = stream ? 'gzip' : 'gzip, deflate';
    }
    return headers;
  }

  Future<FeedResponse> fetchFeed() async {
    return _guard(() async {
      final response = await _client.get(
        Uri.parse('$baseUrl/v2/animes/feed'),
        headers: _headers(),
      );
      final json = _decode(response);
      return FeedResponse.fromJson(json);
    });
  }

  Future<List<SearchItem>> search(String query, {int page = 0}) async {
    return _guard(() async {
      final response = await _client.post(
        Uri.parse('$baseUrl/v2/content/search'),
        headers: _headers(json: true),
        body: jsonEncode({
          'token': devToken,
          'search': query,
          'content_type': 'all',
          'page': page,
        }),
      );
      final json = _decode(response);
      final raw = json['result'];
      return raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (item) => SearchItem.fromJson(item.cast<String, dynamic>()),
                )
                .toList()
          : const [];
    });
  }

  Future<AnimeDetails> fetchAnime(int animeId) async {
    return _guard(() async {
      final response = await _client.get(
        Uri.parse('$baseUrl/v2/anime/$animeId'),
        headers: _headers(),
      );
      return AnimeDetails.fromJson(_decode(response));
    });
  }

  Future<EpisodePage> fetchEpisodePage(int seasonId, {int page = 0}) async {
    return _guard(() async {
      final response = await _client.post(
        Uri.parse('$baseUrl/season/$seasonId/episodes'),
        headers: _headers(json: true),
        body: jsonEncode({'token': devToken, 'page': page, 'order': 'ASC'}),
      );
      final json = _decode(response);
      final raw = json['data'];
      final List<Episode> items = raw is List
          ? raw
                .whereType<Map>()
                .map((item) => Episode.fromJson(item.cast<String, dynamic>()))
                .toList()
          : const <Episode>[];
      return EpisodePage(
        total: (json['episodes'] as num?)?.toInt() ?? items.length,
        items: items,
      );
    });
  }

  Future<List<Episode>> fetchEpisodes(int seasonId, {int page = 0}) async {
    return (await fetchEpisodePage(seasonId, page: page)).items;
  }

  Future<EpisodeStream> fetchStream(int episodeId) async {
    return _guard(() async {
      final response = await _client.get(
        Uri.parse('$baseUrl/v2/anime/episode/$episodeId/stream'),
        headers: _headers(json: true, stream: true),
      );
      return EpisodeStream.fromJson(episodeId, _decode(response));
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (_) {
      throw const TomatoApiException(maintenanceMessage);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const TomatoApiException(maintenanceMessage);
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const TomatoApiException(maintenanceMessage);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const TomatoApiException(maintenanceMessage);
    }
    return decoded;
  }

  void dispose() {
    _client.close();
  }
}

class TomatoApiException implements Exception {
  const TomatoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
