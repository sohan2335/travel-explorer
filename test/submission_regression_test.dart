import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/services/place_catalog.dart';
import 'package:travel_explorer/theme/app_theme.dart';
import 'package:travel_explorer/widgets/city_venue_picker.dart';

void main() {
  test('catalog satisfies the four-stage assignment content requirements', () {
    expect(destinations.length, greaterThanOrEqualTo(3));
    expect(
      destinations.map((d) => d.category).toSet().length,
      greaterThanOrEqualTo(3),
    );
    expect(destinations.map((d) => d.id).toSet().length, destinations.length);
    for (final city in destinations) {
      expect(city.name.trim(), isNotEmpty, reason: city.id);
      expect(city.location.trim(), isNotEmpty, reason: city.id);
      expect(city.category.trim(), isNotEmpty, reason: city.id);
      expect(city.description.trim(), isNotEmpty, reason: city.id);
      expect(city.bestTimeToVisit.trim(), isNotEmpty, reason: city.id);
      expect(city.attractions.length, inInclusiveRange(2, 3), reason: city.id);
      for (final image in [
        city.imageUrl,
        ...city.attractions.map((a) => a.imageUrl),
      ]) {
        if (image.startsWith('assets/')) {
          expect(File(image).existsSync(), isTrue, reason: image);
        } else {
          final uri = Uri.tryParse(image);
          expect(uri?.scheme, 'https', reason: image);
          expect(uri?.host, isNotEmpty, reason: image);
        }
      }
      expect(city.attractions.every((a) => a.name.trim().isNotEmpty), isTrue);
    }
  });

  testWidgets('venue picker remains usable on a small phone with a keyboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.5),
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => pickCityVenue(context, destinations.first),
                child: const Text('Choose a venue'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Choose a venue'));
    await tester.pumpAndSettle();
    expect(find.text('Search places in this city'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Palolem');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Palolem Beach'),
      80,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('city-venue-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Palolem Beach'));
    await tester.pumpAndSettle();
    expect(find.text('Search places in this city'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
