import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hw_40/screens/list_screen.dart';
import 'package:hw_40/repositories/items_repository.dart';

void main() {
  testWidgets('empty -> loading -> display items', (WidgetTester tester) async {
    final repo = InMemoryItemsRepository();
    // pre-seed items that will be returned on fetch
    await repo.addItem('First');
    await repo.addItem('Second');

    await tester.pumpWidget(MaterialApp(home: ListScreen(repository: repo)));

    // starts idle with empty label (even if repository has items, load not called)
    expect(find.byKey(const Key('list_empty')), findsOneWidget);
    expect(find.byKey(const Key('list_loading')), findsNothing);

    // tap load -> loading indicator -> items shown
    await tester.tap(find.byKey(const Key('load_button')));
    await tester.pump(); // start async
    expect(find.byKey(const Key('list_loading')), findsOneWidget);

    // wait for repository artificial delay
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('list_items')), findsOneWidget);
    expect(find.byKey(const Key('item_tile_0')), findsWidgets); // at least one
  });

  testWidgets('add button: enter text -> item appears', (WidgetTester tester) async {
    final repo = InMemoryItemsRepository();
    await tester.pumpWidget(MaterialApp(home: ListScreen(repository: repo)));

    // load first to go to loaded state (with empty list)
    await tester.tap(find.byKey(const Key('load_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('list_items')), findsOneWidget);

    // open add dialog
    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('add_text_field')), 'New item');
    await tester.tap(find.byKey(const Key('add_confirm_button')));
    // after closing dialog there is an async add; wait
    await tester.pump(); // start
    await tester.pumpAndSettle();
    // item should appear
    expect(find.text('New item'), findsOneWidget);
  });

  testWidgets('show error on fetch and display error widget', (WidgetTester tester) async {
    final repo = InMemoryItemsRepository();
    repo.simulateFetchError = true;
    await tester.pumpWidget(MaterialApp(home: ListScreen(repository: repo)));

    await tester.tap(find.byKey(const Key('load_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('list_error')), findsOneWidget);
    expect(find.byKey(const Key('retry_button')), findsOneWidget);
  });

  testWidgets('navigation: tap item -> opens detail screen', (WidgetTester tester) async {
    final repo = InMemoryItemsRepository();
    await repo.addItem('Navigate me');
    await tester.pumpWidget(MaterialApp(home: ListScreen(repository: repo)));

    // load items
    await tester.tap(find.byKey(const Key('load_button')));
    await tester.pumpAndSettle();

    // tap first item
    await tester.tap(find.byKey(const Key('item_tile_0')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('detail_screen')), findsOneWidget);
    expect(find.text('Navigate me'), findsOneWidget);
  });

  testWidgets('show snackbar on add error', (WidgetTester tester) async {
    final repo = InMemoryItemsRepository();
    repo.simulateAddError = true;
    await tester.pumpWidget(MaterialApp(home: ListScreen(repository: repo)));

    // load to get to loaded state
    await tester.tap(find.byKey(const Key('load_button')));
    await tester.pumpAndSettle();

    // add
    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('add_text_field')), 'Bad add');
    await tester.tap(find.byKey(const Key('add_confirm_button')));
    await tester.pump(); // start async add
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('snackbar_error')), findsOneWidget);
  });
}