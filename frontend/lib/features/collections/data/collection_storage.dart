import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pickle_collection.dart';
import '../models/random_selection_policy.dart';

class CollectionStorage {
  static const _storageKey = 'pickle.collections';
  static const _globalRandomPolicyKey = 'pickle.randomPolicy';

  Future<List<PickleCollection>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedCollections = preferences.getString(_storageKey);
    if (storedCollections == null) return [];

    try {
      final decoded = jsonDecode(storedCollections);
      if (decoded is! List) return [];
      final collectionJson = decoded.whereType<Map<String, dynamic>>().toList();
      final collections = collectionJson
          .map(PickleCollection.fromJson)
          .toList();
      if (_needsIdentityMigration(collectionJson)) {
        await preferences.setString(
          _storageKey,
          jsonEncode(collections.map((collection) => collection.toJson()).toList()),
        );
      }
      return collections;
    } on FormatException {
      return [];
    }
  }

  Future<void> save(List<PickleCollection> collections) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      collections.map((collection) => collection.toJson()).toList(),
    );
    await preferences.setString(_storageKey, encoded);
  }

  Future<RandomSelectionPolicy> loadGlobalRandomPolicy() async {
    final preferences = await SharedPreferences.getInstance();
    return RandomSelectionPolicy.fromStorage(
      preferences.getString(_globalRandomPolicyKey),
    );
  }

  Future<void> saveGlobalRandomPolicy(RandomSelectionPolicy policy) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_globalRandomPolicyKey, policy.name);
  }

  bool _needsIdentityMigration(List<Map<String, dynamic>> collections) =>
      collections.any((collection) {
        final items = collection['items'];
        if (items is! List) return false;
        return items.any((item) {
          if (item is String) return true;
          if (item is! Map<String, dynamic>) return false;
          final id = item['id'];
          return id is! String || id.isEmpty;
        });
      });
}
