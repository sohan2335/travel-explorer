import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/models/trip_draft.dart';
import 'package:travel_explorer/experience/experience_controller.dart';
import 'package:travel_explorer/experience/interest_venues.dart';
import 'package:travel_explorer/screens/day_planner_screen.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/services/place_catalog.dart';
import 'package:travel_explorer/state/travel_controller.dart';
import 'package:travel_explorer/widgets/discovery_shortcuts.dart';

void main() {
  testWidgets('saved draft settings win over a newly changed preference', (
    tester,
  ) async {
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    final experience = ExperienceController(MemoryStore());
    final travel = TravelController(destinations);
    addTearDown(experience.dispose);
    addTearDown(travel.dispose);
    await experience.savePreferences({}, 'Relaxed', null);
    await travel.saveDraft(
      TripDraft(
        destinationId: 'goa',
        origin: 'Station',
        hotel: 'Hotel',
        arrivalMinutes: 540,
        hotelReadyMinutes: 840,
        restMinutes: 30,
        travelMinutes: 30,
        mode: 'transit',
        attraction: 'Palolem Beach',
        pace: 'Packed',
        hasPlan: false,
        visitMinutes: 60,
      ),
    );
    await tester.pumpWidget(
      ExperienceScope(
        controller: experience,
        homeBuilder: () => const SizedBox(),
        child: MaterialApp(
          home: DayPlannerScreen(
            destination: destinations.first,
            controller: travel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pace = find.byWidgetPredicate(
      (w) =>
          w is DropdownButtonFormField<String> &&
          w.decoration.labelText == 'Sightseeing pace',
    );
    await tester.scrollUntilVisible(
      pace,
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester.widget<DropdownButtonFormField<String>>(pace).initialValue,
      'Packed',
    );
    expect(travel.draftFor('goa')!.visitMinutes, 60);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected interests come first without hiding other categories', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DiscoveryShortcuts(
            preferred: const {'movie'},
            onSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Movies')).dx,
      lessThan(tester.getTopLeft(find.text('Dining')).dx),
    );
    expect(find.text('Shopping'), findsOneWidget);
  });
  testWidgets('interest section hides when fewer than two city venues match', (
    tester,
  ) async {
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    final travel = TravelController(destinations);
    addTearDown(travel.dispose);
    Widget section(Set<String> interests) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: InterestVenues(
            city: destinations.firstWhere((d) => d.id == 'goa'),
            interests: interests,
            travel: travel,
          ),
        ),
      ),
    );
    await tester.pumpWidget(section({'movie'}));
    await tester.pumpAndSettle();
    expect(find.text('Based on your interests'), findsNothing);
    await tester.pumpWidget(section({'hotel', 'restaurant'}));
    await tester.pumpAndSettle();
    expect(find.text('Based on your interests'), findsOneWidget);
    expect(find.text('Taj Fort Aguada Resort & Spa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('preference sets a changeable pace for a new plan', (
    tester,
  ) async {
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    final experience = ExperienceController(MemoryStore());
    final travel = TravelController(destinations);
    addTearDown(experience.dispose);
    addTearDown(travel.dispose);
    await experience.savePreferences({}, 'Relaxed', null);
    await tester.pumpWidget(
      ExperienceScope(
        controller: experience,
        homeBuilder: () => const SizedBox(),
        child: MaterialApp(
          home: DayPlannerScreen(
            destination: destinations.first,
            controller: travel,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pace = find.byWidgetPredicate(
      (w) =>
          w is DropdownButtonFormField<String> &&
          w.decoration.labelText == 'Sightseeing pace',
    );
    await tester.scrollUntilVisible(
      pace,
      350,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester.widget<DropdownButtonFormField<String>>(pace).initialValue,
      'Relaxed',
    );
    final duration = find.byWidgetPredicate(
      (w) =>
          w is DropdownButtonFormField<int> &&
          w.decoration.labelText == 'Visit duration per outing',
    );
    expect(
      tester.widget<DropdownButtonFormField<int>>(duration).initialValue,
      120,
    );
    await tester.tap(pace);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Packed').last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<DropdownButtonFormField<int>>(duration).initialValue,
      60,
    );
    expect(tester.takeException(), isNull);
  });
}
