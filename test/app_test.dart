import 'package:flutter/material.dart';
import 'package:travel_explorer/services/place_catalog.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/main.dart';
import 'package:travel_explorer/screens/explorer_screen.dart';
import 'package:travel_explorer/screens/day_planner_screen.dart';

// Photos are bundled assets, so tests do not need internet access.
// Bundled assets let pumpAndSettle finish route and navigation animations.
Finder saveButton(String tooltip) => find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == tooltip,
    );

Future<void> showApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.runAsync(() => PlaceCatalog.load(offline: true));
  await tester.pumpWidget(TravelExplorerApp(store: MemoryStore()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('place information and a simple day plan are reachable',
      (tester) async {
    await showApp(tester);
    await tester.ensureVisible(find.text('Goa').first);
    await tester.tap(find.text('Goa').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sights & city guide'));
    await tester.tap(find.text('Sights & city guide'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('About this city'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About this city'));
    await tester.pumpAndSettle();
    expect(find.text('View surroundings'), findsOneWidget);
    await tester.tap(find.byTooltip('Close place information'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Plan one day here'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan one day here'));
    await tester.pumpAndSettle();
    expect(find.byType(DayPlannerScreen), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Arrival airport / station'),
        'Station');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Hotel / luggage-drop location'),
        'Hotel');
    await tester.ensureVisible(find.text('Create my day plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create my day plan'));
    await tester.pumpAndSettle();
    expect(find.text('Your day, at a glance'), findsOneWidget);
    expect(find.text('Time before room access'), findsOneWidget);
    expect(find.text('19:00 - 20:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details save is reflected in wishlist and removal empties it',
      (tester) async {
    await showApp(tester);
    await tester.ensureVisible(find.text('Goa').first);
    await tester.tap(find.text('Goa').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sights & city guide'));
    await tester.tap(find.text('Sights & city guide'));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationDetails), findsOneWidget);
    expect(find.text('Best time to visit'), findsOneWidget);
    expect(find.text('November to February'), findsOneWidget);
    expect(find.text('Top attractions'), findsOneWidget);

    final detailsSave = find.descendant(
      of: find.byType(DestinationDetails),
      matching: saveButton('Save Goa'),
    );
    await tester.tap(detailsSave);
    await tester.pump();
    expect(
        find.descendant(
          of: find.byType(DestinationDetails),
          matching: saveButton('Remove Goa'),
        ),
        findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close city'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hotlists'));
    await tester.pump();
    expect(find.text('1 saved places'), findsOneWidget);
    expect(find.text('Goa'), findsOneWidget);

    await tester.tap(saveButton('Remove Goa'));
    await tester.pump();
    expect(find.text('0 saved places'), findsOneWidget);
    expect(find.text('Your wishlist is waiting'), findsOneWidget);
    expect(find.text('Goa'), findsNothing);
  });

  testWidgets('city search lives only in Search and does not filter Home',
      (tester) async {
    await showApp(tester);
    expect(find.widgetWithText(TextField, 'Find your city'), findsNothing);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Find your city'), 'Paris');
    await tester.pumpAndSettle();
    expect(find.text('1 cities to explore'), findsOneWidget);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Find your city'), findsNothing);
    expect(find.text('10 cities to explore'), findsOneWidget);
  });

  testWidgets('activity selection opens that category for a city',
      (tester) async {
    await showApp(tester);
    expect(find.widgetWithText(ChoiceChip, 'Beaches'), findsNothing);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Shopping'));
    await tester.pump();
    await tester.ensureVisible(find.text('Goa').first);
    await tester.tap(find.text('Goa').first);
    await tester.pumpAndSettle();
    expect(find.text('Shopping in Goa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone layout supports large text through details and wishlist',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    await tester.pumpWidget(TravelExplorerApp(store: MemoryStore()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Goa'), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Goa').first);
    await tester.tap(find.text('Goa').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Sights & city guide'));
    await tester.tap(find.text('Sights & city guide'));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationDetails), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -1000));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close city'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hotlists'));
    await tester.pump();
    expect(find.text('Your wishlist is waiting'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
