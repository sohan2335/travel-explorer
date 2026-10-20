import 'package:flutter/material.dart';
import 'package:travel_explorer/widgets/city_venue_picker.dart';
import 'package:travel_explorer/widgets/destination_image.dart';
import 'package:travel_explorer/services/place_catalog.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/main.dart';
import 'package:travel_explorer/screens/explorer_screen.dart';
import 'package:travel_explorer/screens/my_day_screen.dart';
import 'package:travel_explorer/state/travel_controller.dart';
import 'package:travel_explorer/data/destinations.dart';
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
  testWidgets('My day tab opens a city without requiring a saved draft',
      (tester) async {
    await showApp(tester);
    await tester.tap(find.text('My day'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My day in Goa'));
    await tester.pumpAndSettle();
    expect(find.byType(MyDayScreen), findsOneWidget);
    expect(find.text('Order your stops, then check timing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing photo shows a named placeholder', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
            height: 320, child: DestinationImage(url: '', label: 'Goa'))));
    expect(find.text('Goa'), findsOneWidget);
    expect(find.byIcon(Icons.landscape_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('place information and a simple day plan are reachable',
      (tester) async {
    await showApp(tester);
    await tester.ensureVisible(find.text('Goa').first);
    await tester.tap(find.text('Goa').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explore Goa'));
    await tester.tap(find.text('Explore Goa'));
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
    await tester.ensureVisible(find.text('Explore Goa'));
    await tester.tap(find.text('Explore Goa'));
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
    await tester.tap(find.text('Saved'));
    await tester.pump();
    expect(find.text('1 saved places'), findsOneWidget);
    expect(find.text('Goa'), findsOneWidget);

    await tester.tap(saveButton('Remove Goa'));
    await tester.pump();
    expect(find.text('0 saved places'), findsOneWidget);
    expect(find.text('No saved cities yet'), findsOneWidget);
    expect(find.text('Goa'), findsNothing);
  });

  testWidgets('My day hands ordered picks to planner without saving a draft',
      (tester) async {
    final c = TravelController(destinations, store: MemoryStore());
    await c.addToMyDay('goa', 'Fort Aguada');
    await c.addToMyDay('goa', 'Fontainhas');
    await c.addToMyDay('goa', 'Sample hotel', kind: 'hotel');
    await tester.pumpWidget(MaterialApp(
        home: MyDayScreen(
            destination: destinations.firstWhere((d) => d.id == 'goa'),
            controller: c)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan my day'));
    await tester.pumpAndSettle();
    final planner =
        tester.widget<DayPlannerScreen>(find.byType(DayPlannerScreen));
    expect(planner.initialStops, ['Fort Aguada', 'Fontainhas']);
    expect(planner.initialHotel, 'Sample hotel');
    expect(find.widgetWithText(TextFormField, 'Sample hotel'), findsOneWidget);
    expect(c.drafts, isEmpty);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });

  testWidgets('city place picker searches local data and keeps source ID',
      (tester) async {
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    final c = TravelController(destinations, store: MemoryStore());
    await tester.pumpWidget(MaterialApp(
        home: MyDayScreen(
            destination: destinations.firstWhere((d) => d.id == 'goa'),
            controller: c)));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Add to my day'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Search places in this city'), 'Fort');
    await tester.pumpAndSettle();
    expect(find.text('Charminar'), findsNothing);
    await tester.tap(find.text('Fort Aguada'));
    await tester.pumpAndSettle();
    expect(c.myDayFor('goa').stops, ['Fort Aguada']);
    expect(c.myDayFor('goa').placeIds['Fort Aguada'], 'goa:sight:Fort Aguada');
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });

  testWidgets('venue picker fits above a mobile keyboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => pickCityVenue(context, destinations.first),
                    child: const Text('Pick'))))));
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Search places in this city'), findsOneWidget);
  });

  testWidgets('My day shows the five-stop limit and disables adding',
      (tester) async {
    final c = TravelController(destinations);
    for (var i = 0; i < 5; i++) {
      await c.addToMyDay('goa', 'Stop $i');
    }
    await tester.pumpWidget(MaterialApp(
        home: MyDayScreen(
            destination: destinations.firstWhere((d) => d.id == 'goa'),
            controller: c)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('Limit reached. Remove a stop to add another.'), 400,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Limit reached. Remove a stop to add another.'),
        findsOneWidget);
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Add to my day'))
            .onPressed,
        isNull);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
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

  testWidgets('a city must be chosen before activities are enabled',
      (tester) async {
    await showApp(tester);
    final tile = find.widgetWithText(OutlinedButton, 'Shopping');
    expect(tester.widget<OutlinedButton>(tile).onPressed, isNull);
    await tester.tap(find.text('Goa').first);
    await tester.pumpAndSettle();
    expect(tester.widget<OutlinedButton>(tile).onPressed, isNotNull);
    await tester.ensureVisible(tile);
    await tester.tap(tile);
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
    await tester.ensureVisible(find.text('Explore Goa'));
    await tester.tap(find.text('Explore Goa'));
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
    await tester.tap(find.text('Saved'));
    await tester.pump();
    expect(find.text('No saved cities yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
