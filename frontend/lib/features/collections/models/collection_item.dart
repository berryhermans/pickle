enum CollectionItemSource { manual, tmdb, tvdb }

class CollectionItem {
  const CollectionItem({
    required this.title,
    required this.source,
    this.providerId,
    this.posterUrl,
    this.durationMinutes,
    this.genres = const [],
  });

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

  final String title;
  final CollectionItemSource source;
  final String? providerId;
  final String? posterUrl;
  final int? durationMinutes;
  final List<String> genres;

  Map<String, Object?> toJson() => {
    'title': title,
    'source': source.name,
    'providerId': providerId,
    'posterUrl': posterUrl,
    'durationMinutes': durationMinutes,
    'genres': genres,
  };
}