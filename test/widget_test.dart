import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jotly/main.dart';

const _testNotesKey = 'jotly.notes.v1';
const _testDarkKey = 'jotly.dark.v1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> openNotes(
    WidgetTester tester, {
    Size? surfaceSize,
  }) async {
    if (surfaceSize != null) {
      await tester.binding.setSurfaceSize(surfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    await tester.pumpWidget(const JotlyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Notes'));
    await tester.pumpAndSettle();
  }

  Future<void> createNote(
    WidgetTester tester, {
    required String title,
    required String body,
  }) async {
    final emptyCreateButton = find.text('Create Note');
    if (emptyCreateButton.evaluate().isNotEmpty) {
      await tester.tap(emptyCreateButton);
    } else {
      await tester.tap(find.byIcon(Icons.add_rounded).last);
    }
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), title);
    await tester.enterText(find.byType(TextField).at(1), body);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  Future<List<dynamic>> storedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(_testNotesKey) ?? '[]') as List<dynamic>;
  }

  testWidgets('empty state and search handle small screens',
      (WidgetTester tester) async {
    await openNotes(tester, surfaceSize: const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Write your first quick idea, plan, or reminder.'),
        findsOneWidget);

    await createNote(
      tester,
      title: 'Grocery list',
      body: 'Buy milk and bread',
    );
    await createNote(
      tester,
      title: 'Project plan',
      body: 'Draft the release checklist',
    );

    await tester.enterText(find.byType(TextField).first, 'milk');
    await tester.pumpAndSettle();

    expect(find.text('Grocery list'), findsOneWidget);
    expect(find.text('Project plan'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'missing');
    await tester.pumpAndSettle();

    expect(find.text('No matches found'), findsOneWidget);
    expect(find.text('Try a different word or clear search to see all your notes.'),
        findsOneWidget);
  });

  testWidgets('notes persist, edit, pin, and favorite locally',
      (WidgetTester tester) async {
    await openNotes(tester);

    await createNote(tester, title: 'Alpha', body: 'First body');
    await createNote(tester, title: 'Beta', body: 'Second body');

    var notes = await storedNotes();
    expect(notes, hasLength(2));
    expect(notes.map((note) => note['title']), containsAll(['Alpha', 'Beta']));

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Alpha edited');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha edited'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);

    await tester.tap(find.byTooltip('Pin note').last);
    await tester.pumpAndSettle();

    final alphaPosition = tester.getTopLeft(find.text('Alpha edited'));
    final betaPosition = tester.getTopLeft(find.text('Beta'));
    expect(alphaPosition.dy <= betaPosition.dy, isTrue);

    await tester.tap(find.byTooltip('Add to favorites').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha edited'), findsOneWidget);
    expect(find.text('Beta'), findsNothing);

    notes = await storedNotes();
    final alpha = notes.cast<Map<String, dynamic>>().singleWhere(
          (note) => note['title'] == 'Alpha edited',
        );
    expect(alpha['pinned'], isTrue);
    expect(alpha['favorite'], isTrue);
  });

  testWidgets('delete confirmation removes notes and undo restores them',
      (WidgetTester tester) async {
    await openNotes(tester);
    await createNote(tester, title: 'Delete me', body: 'Temporary note');

    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this note?'), findsOneWidget);
    expect(find.textContaining('You can undo the delete'), findsOneWidget);

    await tester.tap(find.text('Delete note'));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsNothing);
    expect(await storedNotes(), isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsOneWidget);
    final notes = await storedNotes();
    expect(notes, hasLength(1));
    expect(notes.single['title'], 'Delete me');
  });

  testWidgets('dark mode persists and settings expose version/legal pages',
      (WidgetTester tester) async {
    await openNotes(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('App Version'), findsOneWidget);
    expect(find.text('Version 1.0.0 (1)'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(_testDarkKey), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const JotlyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Notes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    final darkModeTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(darkModeTile.value, isTrue);

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.text('Information We Store'), findsOneWidget);
    expect(find.text('No Analytics'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terms & Conditions'));
    await tester.pumpAndSettle();

    expect(find.text('User Responsibilities'), findsOneWidget);
    expect(find.text('Limitation of Liability'), findsOneWidget);
  });
}
