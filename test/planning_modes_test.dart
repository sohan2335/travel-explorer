import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/experience/experience_controller.dart';
import 'package:travel_explorer/screens/day_planner_screen.dart';
import 'package:travel_explorer/screens/whole_trip_screen.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/services/place_catalog.dart';
import 'package:travel_explorer/services/whole_trip_store.dart';
import 'package:travel_explorer/state/travel_controller.dart';

void main() {
  testWidgets(
    'mobile planner changes modes, saves two independent days, and reopens whole trip',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.runAsync(() => PlaceCatalog.load(offline: true));
      final store = MemoryStore();
      final experience = ExperienceController(store);
      final travel = TravelController(destinations, store: store);
      addTearDown(experience.dispose);
      addTearDown(travel.dispose);
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
      expect(find.text('Plan a day'), findsOneWidget);
      expect(find.text('Arrival airport / station'), findsNothing);
      await tester.tap(find.text('Plan whole trip'));
      await tester.pumpAndSettle();
      expect(find.byType(WholeTripScreen), findsOneWidget);
      for (var day = 1; day <= 2; day++) {
        await tester.scrollUntilVisible(
          find.text('Edit day $day'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit day $day'));
        await tester.pumpAndSettle();
        expect(find.text('Arrival airport / station'), findsNothing);
        await tester.ensureVisible(find.text('Create my day plan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Create my day plan'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Save this day'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save this day'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      final saved = (await WholeTripStore(store).load())['goa']!;
      expect(saved.days.length, 2);
      expect(saved.days.every((d) => d.hasPlan), isTrue);
      expect(saved.days[0].attraction, isNot(saved.days[1].attraction));
      expect(travel.draftFor('goa'), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          home: WholeTripScreen(
            destination: destinations.first,
            controller: travel,
            store: store,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('View timetable'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'mode cards and trip day controls fit small screens with larger text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final travel = TravelController(destinations);
      addTearDown(travel.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: WholeTripScreen(
            destination: destinations.first,
            controller: travel,
            store: MemoryStore(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('7 days'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('7 days'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Edit day 7'),
        350,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Save whole trip'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
