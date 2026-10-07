import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../app/app_config.dart';
import '../models/collection_item.dart';
import '../models/pickle_collection.dart';

class MediaSearchService {
  static List<CollectionItem> parseResults({
    required CollectionType type,
    required Object payload,
  }) {
    final source = _sourceForType(type);
    final results = payload is List ? payload : const <Object>[];

    return results
        .whereType<Map>()
        .map((item) => _buildItem(item.cast<String, dynamic>(), source))
        .whereType<CollectionItem>()
        .toList();
  }

  static CollectionItemSource _sourceForType(CollectionType type) =>
      switch (type) {
        CollectionType.movie => CollectionItemSource.tmdb,
        CollectionType.tv => CollectionItemSource.tvdb,
        CollectionType.custom => CollectionItemSource.manual,
      };

  static CollectionItem? _buildItem(
    Map<String, dynamic> map,
    CollectionItemSource source,
  ) {
    final title = (map['title'] ?? map['name']) as String? ?? '';
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) return null;

    final rawGenres = map['genres'];
    final rawDuration = map['durationMinutes'] ?? map['runtime'];

    return CollectionItem(
      title: normalizedTitle,
      source: source,
      providerId: (map['providerId'] ?? map['id'])?.toString(),
      posterUrl: (map['posterUrl'] ?? map['poster_url']) as String?,
      durationMinutes: rawDuration is num ? rawDuration.round() : null,
      genres: rawGenres is List
          ? rawGenres
                .map((genre) {
                  if (genre is Map) {
                    final name = genre['name'];
                    return name is String ? name : null;
                  }
                  return genre is String ? genre : null;
                })
                .whereType<String>()
                .toList()
          : const <String>[],
    );
  }

  static Future<List<CollectionItem>> search(
    CollectionType type,
    String query,
  ) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final uri = AppConfig.current.searchEndpoint.replace(
        queryParameters: {'type': type.name, 'query': trimmed},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return const [];

      final body = jsonDecode(response.body);
      if (body is Map && body['results'] is List) {
        return parseResults(type: type, payload: body['results']);
      }
      if (body is List) {
        return parseResults(type: type, payload: body);
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}
