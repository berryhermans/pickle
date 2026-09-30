enum CollectionType { movie, tv, custom }

extension CollectionTypeLabel on CollectionType {
  String get label => switch (this) {
    CollectionType.movie => 'Movie',
    CollectionType.tv => 'TV',
    CollectionType.custom => 'Custom',
  };
}

class PickleCollection {
  PickleCollection({required this.name, required this.type});

  final String name;
  final CollectionType type;
  final List<String> items = [];
}
