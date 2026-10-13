import 'dart:math';

import 'collection_item.dart';
import 'random_selection_policy.dart';

class RandomPickResult {
  const RandomPickResult({
    required this.winner,
    required this.previousEntryId,
    required this.cycleEntryIds,
  });

  final CollectionItem winner;
  final String previousEntryId;
  final List<String> cycleEntryIds;
}

class RandomSelection {
  static RandomPickResult pick({
    required List<CollectionItem> items,
    required RandomSelectionPolicy policy,
    required String? previousEntryId,
    required List<String> cycleEntryIds,
    required Random random,
  }) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Must contain at least one entry');
    }

    var cycle = reconcileCycle(items: items, cycleEntryIds: cycleEntryIds);
    var candidates = switch (policy) {
      RandomSelectionPolicy.uniform => List<CollectionItem>.of(items),
      RandomSelectionPolicy.avoidPrevious when items.length > 1 =>
        items.where((item) => item.id != previousEntryId).toList(),
      RandomSelectionPolicy.avoidPrevious => List<CollectionItem>.of(items),
      RandomSelectionPolicy.noRepeatUntilAllUsed =>
        items.where((item) => !cycle.contains(item.id)).toList(),
    };

    if (candidates.isEmpty) {
      cycle = [];
      candidates = List<CollectionItem>.of(items);
    }

    final winner = candidates[random.nextInt(candidates.length)];
    if (!cycle.contains(winner.id)) cycle.add(winner.id);
    if (cycle.length == items.map((item) => item.id).toSet().length) {
      cycle = [];
    }

    return RandomPickResult(
      winner: winner,
      previousEntryId: winner.id,
      cycleEntryIds: List.unmodifiable(cycle),
    );
  }

  static List<String> reconcileCycle({
    required List<CollectionItem> items,
    required List<String> cycleEntryIds,
  }) {
    final currentIds = items.map((item) => item.id).toSet();
    final reconciled = <String>[];
    for (final id in cycleEntryIds) {
      if (currentIds.contains(id) && !reconciled.contains(id)) {
        reconciled.add(id);
      }
    }
    if (currentIds.isNotEmpty && reconciled.length == currentIds.length) {
      return [];
    }
    return reconciled;
  }
}
