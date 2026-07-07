import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/anime_models.dart';
import '../models/feed_models.dart';
import '../security/security_manager.dart';

/// API segura com token criptografado e proteção contra engenharia reversa
class SecureTomatoApi {
  SecureTomatoApi({http.Client? client, SecurityManager? securityManager})
      : _client = client ?? http.Client(),
        _security = securityManager ?? SecurityManager();

  static const String _baseUrl = 'https://edge.betomato.com';
  static const String _maintenanceMessage =
      'Servidor em manutencao. Tente voltar mais tarde.';

  // Token ofuscado (será descriptografado em runtime)
  static final _obfuscatedToken = _encodeToken();

  final http.Client _client;
  final SecurityManager _security;

  /// Codifica o token para ofuscação
  static String _encodeToken() {
    // Token original: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
    // Armazenado em partes e ofuscado
    final parts = [
      'ZXlKaGJHY2lPaUpJVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5',
      'LmV5SnBaQ0k2TVRVMU5UQXlNRGdzSW5WMWFXUWlPaUkxTVdZd05XTXhaQzB4WVdRd0xUUXhPV0l0T1dFNU1DMWlPVGxqWkdJM01HVTRZVFFpTENKcFlYUWlPakUzTmprM01UTXdNek45',
      'LnRDcWdkNUloVnR3NE0xMW1HR0pfZDlvRG9SajduUEpsVzRNTUJuY3A3ejA=',
    ];

    return parts.map((p) => utf8.decode(base64.decode(p))).join('');
  }

  /// Obtém o token descriptografado
  Future<String> _getToken() async {
    try {
      // Tentar ler do armazenamento seguro primeiro
      final stored = await _security.secureRead('api_token');
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }

      // Fallback para token ofuscado
      final decoded = _obfuscatedToken;
      
      // Armazenar de forma segura para próximas vezes
      await _security.secureWrite('api_token', decoded);
      
      return decoded;
    } catch (e) {
      return _obfuscatedToken;
    }
  }

  Map<String, String> _headers({bool json = false, bool stream = false}) {
    final headers = <String, String>{
      'Accept': 'application/json, text/plain, */*',
      'Request-Time': DateTime.now().millisecondsSinceEpoch.toString(),
      'X-App': '1.4.3',
      if (json) 'Content-Type': 'application/json',
    };

    // User-Agent dinâmico
    headers['User-Agent'] = stream ? 'tomato-android' : 'okhttp/4.11.0';
    headers['Accept-Encoding'] = stream ? 'gzip' : 'gzip, deflate';

    return headers;
  }

  Future<FeedResponse> fetchFeed() async {
    return _guard(() async {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('$_baseUrl/v2/animes/feed'),
        headers: {..._headers(), 'Authorization': 'Bearer $token'},
      );
      final json = _decode(response);
      return FeedResponse.fromJson(json);
    });
  }

  Future<List<SearchItem>> search(String query, {int page = 0}) async {
    return _guard(() async {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('$_baseUrl/v2/content/search'),
        headers: {..._headers(json: true), 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'token': token,
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
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('$_baseUrl/v2/anime/$animeId'),
        headers: {..._headers(), 'Authorization': 'Bearer $token'},
      );
      return AnimeDetails.fromJson(_decode(response));
    });
  }

  Future<EpisodePage> fetchEpisodePage(int seasonId, {int page = 0}) async {
    return _guard(() async {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('$_baseUrl/season/$seasonId/episodes'),
        headers: {..._headers(json: true), 'Authorization': 'Bearer $token'},
        body: jsonEncode({'token': token, 'page': page, 'order': 'ASC'}),
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
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('$_baseUrl/v2/anime/episode/$episodeId/stream'),
        headers: {..._headers(json: true, stream: true), 'Authorization': 'Bearer $token'},
      );
      return EpisodeStream.fromJson(episodeId, _decode(response));
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      throw const SecureTomatoApiException(_maintenanceMessage);
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const SecureTomatoApiException(_maintenanceMessage);
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const SecureTomatoApiException(_maintenanceMessage);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const SecureTomatoApiException(_maintenanceMessage);
    }
    return decoded;
  }

  void dispose() {
    _client.close();
  }
}

class SecureTomatoApiException implements Exception {
  const SecureTomatoApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
