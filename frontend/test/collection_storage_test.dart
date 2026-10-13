import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pickle/features/collections/data/collection_storage.dart';
import 'package:pickle/features/collections/models/collection_item.dart';
import 'package:pickle/features/collections/models/pickle_collection.dart';
import 'package:pickle/features/collections/models/random_selection_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'loads legacy collections and persists generated entry identities',
    () async {
      SharedPreferences.setMockInitialValues({
        'pickle.collections': jsonEncode([
          {
            'name': 'Legacy',
            'type': 'custom',
            'items': ['Same title', 'Same title'],
          },
        ]),
      });
      final storage = CollectionStorage();

      final collections = await storage.load();
      final ids = collections.single.items.map((item) => item.id).toList();
      final persistedCollections = await storage.load();

      expect(ids, hasLength(2));
      expect(ids.toSet(), hasLength(2));
      expect(
        persistedCollections.single.items.map((item) => item.id).toList(),
        ids,
      );
    },
  );

  test('round trips policies and Random pick state', () async {
    final storage = CollectionStorage();
    final collection = PickleCollection(
      name: 'Saved',
      type: CollectionType.custom,
      items: [CollectionItem.manual('Option')],
      randomPolicyOverride: RandomSelectionPolicy.avoidPrevious,
      previousRandomEntryId: 'entry-1',
      randomCycleEntryIds: ['entry-1'],
    );

    await storage.save([collection]);
    final restored = (await storage.load()).single;

    expect(restored.items.single.id, collection.items.single.id);
    expect(restored.randomPolicyOverride, RandomSelectionPolicy.avoidPrevious);
    expect(restored.previousRandomEntryId, 'entry-1');
    expect(restored.randomCycleEntryIds, ['entry-1']);
  });

  test('loads old collections without policy fields as unset state', () async {
    final collection = PickleCollection.fromJson({
      'name': 'Old',
      'type': 'custom',
      'items': ['Old option'],
    });

    expect(collection.randomPolicyOverride, isNull);
    expect(collection.previousRandomEntryId, isNull);
    expect(collection.randomCycleEntryIds, isEmpty);
  });

  test('global policy defaults to uniform and persists changes', () async {
    final storage = CollectionStorage();

    expect(
      await storage.loadGlobalRandomPolicy(),
      RandomSelectionPolicy.uniform,
    );
    await storage.saveGlobalRandomPolicy(
      RandomSelectionPolicy.noRepeatUntilAllUsed,
    );

    expect(
      await storage.loadGlobalRandomPolicy(),
      RandomSelectionPolicy.noRepeatUntilAllUsed,
    );
  });
}
