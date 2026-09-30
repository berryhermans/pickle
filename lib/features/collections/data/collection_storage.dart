import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pickle_collection.dart';

class CollectionStorage {
  static const _storageKey = 'pickle.collections';

  Future<List<PickleCollection>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final storedCollections = preferences.getString(_storageKey);
    if (storedCollections == null) return [];

    try {
      final decoded = jsonDecode(storedCollections);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PickleCollection.fromJson)
          .toList();
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
}
