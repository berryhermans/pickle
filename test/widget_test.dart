// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pickle/main.dart';

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

void main() {
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
    expect(find.text('Add one more option to use this method.'), findsNWidgets(2));
    await tester.tap(find.text('Random'));
    await tester.pumpAndSettle();

    expect(find.text('Only choice'), findsNWidgets(2));
    expect(find.text('Your pickle is solved!'), findsOneWidget);
  });

  testWidgets('tournament advances through the selected bracket', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(
      tester,
      ['Choice A', 'Choice B', 'Choice C', 'Choice D'],
    );
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

  testWidgets('king of the hill advances to each new challenger', (
    WidgetTester tester,
  ) async {
    await _openCollectionWithOptions(tester, ['Choice A', 'Choice B', 'Choice C']);
    await tester.tap(find.text("I'm in a pickle!"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('King of the hill'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Who stays on top?'), findsOneWidget);
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();

    expect(find.text('Your pickle is solved!'), findsOneWidget);
  });
}
