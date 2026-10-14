// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickle/app/pickle_app.dart';
import 'package:pickle/features/collections/models/collection_item.dart';
import 'package:pickle/features/collections/models/pickle_collection.dart';
import 'package:pickle/features/collections/models/random_selection_policy.dart';
import 'package:pickle/features/collections/screens/collection_page.dart';

Future<void> _openCollectionWithOptions(
  WidgetTester tester,
  List<String> options,
) async {
  await tester.pumpWidget(const PickleApp());
  await tester.tap(find.text('Add collection'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Tonight');
  await tester.tap(find.text('Custom'));
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();

  for (final option in options) {
    await tester.tap(find.text('Add an option'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), option);
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
  }
}

Future<void> _finishCollectionEditor(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).last, const Offset(0, -600));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

Future<void> _expectReducedMotionWinner(
  WidgetTester tester, {
  required TargetPlatform platform,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: CollectionPage(
        collection: PickleCollection(
          name: 'Reduced motion',
          type: CollectionType.custom,
          items: [CollectionItem.manual('Only choice')],
        ),
        globalRandomPolicy: RandomSelectionPolicy.uniform,
        onChanged: () async {},
        onDeleted: (_) async {},
      ),
    ),
  );

  await tester.tap(find.text("I'm in a pickle!"));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Random'));
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.text('Your pickle is solved!').evaluate().isNotEmpty) break;
  }

  expect(find.text('Your pickle is solved!'), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(Dialog),
      matching: find.text('Only choice'),
    ),
    findsOneWidget,
  );
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('creates a collection and resolves a random pick', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, ['Choice A', 'Choice B']);
    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Add an option'), findsOneWidget);

    await tester.tap(find.text("I'm in a pickle!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Random'));
    await tester.pumpAndSettle();

    expect(find.text('Your pickle is solved!'), findsOneWidget);
    expect(
      find.text('Choice A').evaluate().isNotEmpty ||
          find.text('Choice B').evaluate().isNotEmpty,
      isTrue,
    );
  });

  testWidgets('random can choose the only option in a collection', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, ['Only choice']);
    await tester.tap(find.text("I'm in a pickle!"));
    await tester.pumpAndSettle();

    expect(find.text('Tournament'), findsOneWidget);
    expect(
      find.text('Add one more option to use this method.'),
      findsNWidgets(2),
    );
    await tester.tap(find.text('Random'));
    await tester.pumpAndSettle();

    expect(find.text('Only choice'), findsNWidgets(2));
    expect(find.text('Your pickle is solved!'), findsOneWidget);
  });

  testWidgets('tournament advances through the selected bracket', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, [
      'Choice A',
      'Choice B',
      'Choice C',
      'Choice D',
    ]);
    await tester.tap(find.text("I'm in a pickle!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tournament'));
    await tester.pumpAndSettle();

    expect(find.text('Match 1 of 2'), findsOneWidget);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Match 2 of 2'), findsOneWidget);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Match 1 of 1'), findsOneWidget);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Your pickle is solved!'), findsOneWidget);
  });

  testWidgets('king of the hill preserves the winner position', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, [
      'Choice A',
      'Choice B',
      'Choice C',
      'Choice D',
      'Choice E',
    ]);
    await tester.tap(find.text("I'm in a pickle!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('King of the hill'));
    await tester.pumpAndSettle();

    String optionLabel(int index) =>
        (tester.widget<FilledButton>(find.byType(FilledButton).at(index)).child
                as Text)
            .data!;

    final firstRightWinner = optionLabel(1);
    await tester.tap(find.byType(FilledButton).at(1));
    await tester.pumpAndSettle();
    expect(find.text('Who stays on top?'), findsOneWidget);
    expect(optionLabel(1), firstRightWinner);

    final nextLeftWinner = optionLabel(0);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(optionLabel(0), nextLeftWinner);

    expect(find.text('Who stays on top?'), findsOneWidget);
  });

  testWidgets('collections and options restore after app recreation', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, ['Choice A', 'Choice B']);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pumpWidget(const PickleApp(key: ValueKey('restarted')));
    await tester.pumpAndSettle();

    expect(find.text('Tonight'), findsOneWidget);
    expect(find.textContaining('2 options'), findsOneWidget);
  });

  testWidgets('Random settings are reachable, selectable, and persistent', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PickleApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Random selection'), findsOneWidget);
    expect(find.text('Uniform random'), findsOneWidget);
    expect(find.text('Avoid previous pick'), findsOneWidget);
    expect(find.text('No repeat until all used'), findsOneWidget);

    final uniform = tester.widget<RadioGroup<RandomSelectionPolicy>>(
      find.byType(RadioGroup<RandomSelectionPolicy>),
    );
    expect(uniform.groupValue, RandomSelectionPolicy.uniform);

    await tester.tap(find.text('Avoid previous pick').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pumpWidget(const PickleApp(key: ValueKey('settings-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    final avoidPrevious = tester.widget<RadioGroup<RandomSelectionPolicy>>(
      find.byType(RadioGroup<RandomSelectionPolicy>),
    );
    expect(avoidPrevious.groupValue, RandomSelectionPolicy.avoidPrevious);
  });

  testWidgets('collection Random override persists and can be cleared', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, []);
    await tester.tap(find.byTooltip('Edit collection'));
    await tester.pumpAndSettle();

    final inheritSwitch = find.byKey(
      const ValueKey('inherit-global-random-policy'),
    );
    expect(tester.widget<SwitchListTile>(inheritSwitch).value, isTrue);
    await tester.tap(inheritSwitch);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('explicit-random-policy-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('No repeat until all used').last);
    await tester.pumpAndSettle();
    await _finishCollectionEditor(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avoid previous pick').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pumpWidget(const PickleApp(key: ValueKey('override-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tonight'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit collection'));
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(inheritSwitch).value, isFalse);
    final dropdown = tester
        .widget<DropdownButtonFormField<RandomSelectionPolicy>>(
          find.byKey(const ValueKey('explicit-random-policy-dropdown')),
        );
    expect(dropdown.initialValue, RandomSelectionPolicy.noRepeatUntilAllUsed);
    expect(
      find.text('Current global default: Avoid previous pick'),
      findsOneWidget,
    );

    await tester.tap(inheritSwitch);
    await tester.pumpAndSettle();
    await _finishCollectionEditor(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const PickleApp(key: ValueKey('inherit-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tonight'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit collection'));
    await tester.pumpAndSettle();

    expect(tester.widget<SwitchListTile>(inheritSwitch).value, isTrue);
    expect(
      find.text('Current global default: Avoid previous pick'),
      findsOneWidget,
    );
  });

  testWidgets('production Random pick uses the letter decoder', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, ['Choice A', 'Choice B']);
    await tester.tap(find.text("I'm in a pickle!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Random'));
    var decoderVisible = false;
    for (var attempt = 0; attempt < 100 && !decoderVisible; attempt++) {
      await tester.pump(const Duration(milliseconds: 50));
      decoderVisible = find.text('DECODING YOUR DESTINY').evaluate().isNotEmpty;
    }

    expect(decoderVisible, isTrue);
    expect(find.byTooltip('Next animation'), findsNothing);
  });

  testWidgets(
    'Random flow applies the collection override over global uniform',
    (WidgetTester tester) async {
      await _openCollectionWithOptions(tester, ['Choice A', 'Choice B']);
      await tester.tap(find.byTooltip('Edit collection'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('inherit-global-random-policy')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('explicit-random-policy-dropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('No repeat until all used').last);
      await tester.pumpAndSettle();
      await _finishCollectionEditor(tester);

      Future<String> pickWinner() async {
        await tester.tap(find.text("I'm in a pickle!"));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Random'));
        await tester.pumpAndSettle();
        final winner =
            find
                .descendant(
                  of: find.byType(Dialog),
                  matching: find.text('Choice A'),
                )
                .evaluate()
                .isNotEmpty
            ? 'Choice A'
            : 'Choice B';
        await tester.tap(find.text('Lovely'));
        await tester.pumpAndSettle();
        return winner;
      }

      final firstWinner = await pickWinner();
      expect(await pickWinner(), isNot(firstWinner));
    },
  );

  testWidgets('Random no-repeat state persists after an app restart', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PickleApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No repeat until all used').first);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await _openCollectionWithOptions(tester, ['Choice A', 'Choice B']);
    Future<String> pickWinner() async {
      await tester.tap(find.text("I'm in a pickle!"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Random'));
      await tester.pumpAndSettle();
      final winner =
          find
              .descendant(
                of: find.byType(Dialog),
                matching: find.text('Choice A'),
              )
              .evaluate()
              .isNotEmpty
          ? 'Choice A'
          : 'Choice B';
      await tester.tap(find.text('Lovely'));
      await tester.pumpAndSettle();
      return winner;
    }

    final firstWinner = await pickWinner();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const PickleApp(key: ValueKey('random-restart')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tonight'));
    await tester.pumpAndSettle();

    expect(await pickWinner(), isNot(firstWinner));
  });

  testWidgets('Android remove-animations preference skips the decoder', (
    WidgetTester tester,
  ) async {
    await _expectReducedMotionWinner(
      tester,
      platform: TargetPlatform.android,
      disableAnimations: true,
    );
  });

  testWidgets('iOS reduce-motion preference skips the decoder', (
    WidgetTester tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(reduceMotion: true);

    await _expectReducedMotionWinner(tester, platform: TargetPlatform.iOS);
  });

  testWidgets('editing a collection updates and persists its title', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, []);
    await tester.tap(find.byTooltip('Edit collection'));
    await tester.pumpAndSettle();
    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
    expect(find.byType(SegmentedButton), findsNothing);
    await tester.enterText(find.byType(TextField), 'Movie night');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Movie night'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Movie night'), findsOneWidget);
    expect(find.text('Custom  ·  0 options'), findsOneWidget);
  });

  testWidgets('deleting a collection requires confirmation', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, []);
    await tester.tap(find.byTooltip('Edit collection'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete collection'));
    await tester.pumpAndSettle();
    expect(find.text('Delete collection?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Edit collection'), findsOneWidget);

    await tester.tap(find.text('Delete collection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Tonight'), findsNothing);
    expect(find.text('A list for every little pickle.'), findsOneWidget);
  });
}
