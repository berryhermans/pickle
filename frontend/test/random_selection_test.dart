import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pickle/features/collections/models/collection_item.dart';
import 'package:pickle/features/collections/models/random_selection.dart';
import 'package:pickle/features/collections/models/random_selection_policy.dart';

void main() {
  final first = CollectionItem(
    id: 'first',
    title: 'First',
    source: CollectionItemSource.manual,
  );
  final second = CollectionItem(
    id: 'second',
    title: 'Second',
    source: CollectionItemSource.manual,
  );
  final third = CollectionItem(
    id: 'third',
    title: 'Third',
    source: CollectionItemSource.manual,
  );

  group('RandomSelection.pick', () {
    test('uniform policy keeps every current entry eligible', () {
      final winners = [
        for (var index = 0; index < 3; index++)
          RandomSelection.pick(
            items: [first, second, third],
            policy: RandomSelectionPolicy.uniform,
            previousEntryId: null,
            cycleEntryIds: const [],
            random: _IndexRandom(index),
          ).winner.id,
      ];

      expect(winners, ['first', 'second', 'third']);
    });

    test('avoid-previous excludes only the previous entry', () {
      final result = RandomSelection.pick(
        items: [first, second, third],
        policy: RandomSelectionPolicy.avoidPrevious,
        previousEntryId: 'first',
        cycleEntryIds: const [],
        random: _IndexRandom(0),
      );

      expect(result.winner.id, 'second');
      expect(result.previousEntryId, 'second');
      expect(result.cycleEntryIds, ['second']);
    });

    test('avoid-previous still selects the only entry', () {
      final result = RandomSelection.pick(
        items: [first],
        policy: RandomSelectionPolicy.avoidPrevious,
        previousEntryId: 'first',
        cycleEntryIds: const [],
        random: _IndexRandom(0),
      );

      expect(result.winner.id, 'first');
      expect(result.previousEntryId, 'first');
      expect(result.cycleEntryIds, isEmpty);
    });

    test('no-repeat excludes used entries and resets after the last pick', () {
      final result = RandomSelection.pick(
        items: [first, second],
        policy: RandomSelectionPolicy.noRepeatUntilAllUsed,
        previousEntryId: 'first',
        cycleEntryIds: const ['first'],
        random: _IndexRandom(0),
      );

      expect(result.winner.id, 'second');
      expect(result.previousEntryId, 'second');
      expect(result.cycleEntryIds, isEmpty);
    });

    for (final policy in RandomSelectionPolicy.values) {
      test('$policy advances shared cycle state', () {
        final result = RandomSelection.pick(
          items: [first, second, third],
          policy: policy,
          previousEntryId: 'first',
          cycleEntryIds: const ['first'],
          random: _IndexRandom(policy == RandomSelectionPolicy.uniform ? 1 : 0),
        );

        expect(result.winner.id, 'second');
        expect(result.previousEntryId, 'second');
        expect(result.cycleEntryIds, ['first', 'second']);
      });
    }

    test('uniform completes and immediately resets the cycle', () {
      final result = RandomSelection.pick(
        items: [first, second],
        policy: RandomSelectionPolicy.uniform,
        previousEntryId: null,
        cycleEntryIds: const ['first'],
        random: _IndexRandom(1),
      );

      expect(result.winner.id, 'second');
      expect(result.cycleEntryIds, isEmpty);
    });

    test('does not share or mutate cycle progress between collections', () {
      final firstCollectionCycle = ['first'];

      final firstCollectionPick = RandomSelection.pick(
        items: [first, second, third],
        policy: RandomSelectionPolicy.noRepeatUntilAllUsed,
        previousEntryId: null,
        cycleEntryIds: firstCollectionCycle,
        random: _IndexRandom(0),
      );
      final secondCollectionPick = RandomSelection.pick(
        items: [first, second, third],
        policy: RandomSelectionPolicy.noRepeatUntilAllUsed,
        previousEntryId: null,
        cycleEntryIds: const [],
        random: _IndexRandom(0),
      );

      expect(firstCollectionPick.winner.id, 'second');
      expect(firstCollectionPick.cycleEntryIds, ['first', 'second']);
      expect(secondCollectionPick.winner.id, 'first');
      expect(secondCollectionPick.cycleEntryIds, ['first']);
      expect(firstCollectionCycle, ['first']);
    });
  });

  group('RandomSelection.reconcileCycle', () {
    test('removes deleted IDs and leaves added entries unpicked', () {
      final reconciled = RandomSelection.reconcileCycle(
        items: [first, third],
        cycleEntryIds: const ['first', 'second'],
      );

      expect(reconciled, ['first']);
    });

    test('resets when removing entries completes the current cycle', () {
      final reconciled = RandomSelection.reconcileCycle(
        items: [first, second],
        cycleEntryIds: const ['first', 'second', 'third'],
      );

      expect(reconciled, isEmpty);
    });
  });
}

class _IndexRandom implements Random {
  _IndexRandom(this.index);

  final int index;

  @override
  bool nextBool() => index.isOdd;

  @override
  double nextDouble() => index.toDouble();

  @override
  int nextInt(int max) => index % max;
}
