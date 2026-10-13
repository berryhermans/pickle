import 'collection_item.dart';
import 'random_selection_policy.dart';

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
    List<CollectionItem>? items,
    this.randomPolicyOverride,
    this.previousRandomEntryId,
    List<String>? randomCycleEntryIds,
  }) : items = items ?? [],
       randomCycleEntryIds = randomCycleEntryIds ?? [];

  factory PickleCollection.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'];
    final type = CollectionType.values.firstWhere(
      (value) => value.name == typeName,
      orElse: () => CollectionType.custom,
    );
    final items = json['items'];
    final randomCycleEntryIds = json['randomCycleEntryIds'];

    return PickleCollection(
      name: json['name'] as String? ?? '',
      type: type,
      randomPolicyOverride: json['randomPolicyOverride'] == null
          ? null
          : RandomSelectionPolicy.fromStorage(json['randomPolicyOverride']),
      previousRandomEntryId: json['previousRandomEntryId'] as String?,
      randomCycleEntryIds: randomCycleEntryIds is List
          ? randomCycleEntryIds.whereType<String>().toList()
          : [],
      items: items is List
          ? items
            .map(CollectionItem.fromStorage)
            .whereType<CollectionItem>()
            .toList()
          : [],
    );
  }

  String name;
  final CollectionType type;
  final List<CollectionItem> items;
  RandomSelectionPolicy? randomPolicyOverride;
  String? previousRandomEntryId;
  final List<String> randomCycleEntryIds;

  Map<String, Object?> toJson() => {
    'name': name,
    'type': type.name,
    'items': items.map((item) => item.toJson()).toList(),
    'randomPolicyOverride': randomPolicyOverride?.name,
    'previousRandomEntryId': previousRandomEntryId,
    'randomCycleEntryIds': randomCycleEntryIds,
  };
}
