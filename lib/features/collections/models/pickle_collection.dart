enum CollectionType { movie, tv, custom }

extension CollectionTypeLabel on CollectionType {
  String get label => switch (this) {
    CollectionType.movie => 'Movie',
    CollectionType.tv => 'TV',
    CollectionType.custom => 'Custom',
  };
}

class PickleCollection {
  PickleCollection({
    required this.name,
    required this.type,
    List<String>? items,
  }) : items = items ?? [];

  factory PickleCollection.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'];
    final type = CollectionType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => CollectionType.custom,
    );
    final items = json['items'];

    return PickleCollection(
      name: json['name'] as String? ?? '',
      type: type,
      items: items is List ? items.whereType<String>().toList() : [],
    );
  }

  final String name;
  final CollectionType type;
  final List<String> items;

  Map<String, Object?> toJson() => {
    'name': name,
    'type': type.name,
    'items': items,
  };
}
