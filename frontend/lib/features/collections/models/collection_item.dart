import 'dart:math';

enum CollectionItemSource { manual, omdb }

class CollectionItem {
  CollectionItem({
    String? id,
    required this.title,
    required this.source,
    this.providerId,
    this.posterUrl,
    this.durationMinutes,
    this.genres = const [],
  }) : id = id == null || id.isEmpty ? _newId() : id;

  factory CollectionItem.manual(String title) => CollectionItem(
    title: title,
    source: CollectionItemSource.manual,
  );

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    final rawSource = json['source'];
    final source = CollectionItemSource.values.firstWhere(
      (value) => value.name == rawSource,
      orElse: () => CollectionItemSource.manual,
    );
    final rawGenres = json['genres'];
    final rawDuration = json['durationMinutes'];

    return CollectionItem(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      source: source,
      providerId: json['providerId']?.toString(),
      posterUrl: json['posterUrl'] as String?,
      durationMinutes: rawDuration is num ? rawDuration.round() : null,
      genres: rawGenres is List ? rawGenres.whereType<String>().toList() : [],
    );
  }

  static CollectionItem? fromStorage(Object? value) {
    if (value is String) return CollectionItem.manual(value);
    if (value is Map<String, dynamic>) return CollectionItem.fromJson(value);
    return null;
  }

  static final _random = Random.secure();

  static String _newId() => List<int>.generate(
    16,
    (_) => _random.nextInt(256),
  ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

  final String id;
  final String title;
  final CollectionItemSource source;
  final String? providerId;
  final String? posterUrl;
  final int? durationMinutes;
  final List<String> genres;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'source': source.name,
    'providerId': providerId,
    'posterUrl': posterUrl,
    'durationMinutes': durationMinutes,
    'genres': genres,
  };
}