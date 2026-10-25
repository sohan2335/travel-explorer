import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/main.dart';
import 'package:travel_explorer/screens/city_discover_screen.dart';
import 'package:travel_explorer/screens/destination_matcher_screen.dart';
import 'package:travel_explorer/screens/explorer_screen.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/services/place_catalog.dart';
import 'package:travel_explorer/state/travel_controller.dart';
import 'package:travel_explorer/theme/app_theme.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> showSearch(
  WidgetTester tester,
  TravelController controller,
) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    TravelExplorerApp(
      controller: controller,
      store: MemoryStore(),
      showLaunchFlow: false,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Search'));
  await tester.pumpAndSettle();
}

void main() {
  test('all assignment categories filter the actual destination list', () {
    final controller = TravelController(destinations, store: MemoryStore());
    addTearDown(controller.dispose);
    expect(controller.categories, [
      'Beaches',
      'Mountains',
      'Heritage',
      'Adventure',
    ]);
    for (final category in controller.categories) {
      controller.setCategory(category);
      expect(controller.visibleDestinations, isNotEmpty);
      expect(
        controller.visibleDestinations.every((d) => d.category == category),
        isTrue,
      );
    }
    controller.setCategory('Heritage');
    controller.setCountry('France');
    controller.setQuery('  PaR  ');
    expect(controller.visibleDestinations.single.id, 'paris');
    controller.setCategory('Adventure');
    expect(controller.visibleDestinations, isEmpty);
  });

  test('reset clears all filters once and preserves saved cities', () {
    final controller = TravelController(destinations, store: MemoryStore());
    addTearDown(controller.dispose);
    controller.toggleWishlist('goa');
    controller.setQuery(' Goa ');
    controller.setCategory('Mountains');
    controller.setCountry('France');
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.clearFilters();
    expect(controller.hasFilters, isFalse);
    expect(controller.visibleDestinations, hasLength(destinations.length));
    expect(controller.isSaved('goa'), isTrue);
    controller.clearFilters();
    expect(notifications, 1);
  });

  testWidgets(
    'Search combines city, category and country, then resets the UI',
    (tester) async {
      final controller = TravelController(destinations, store: MemoryStore());
      addTearDown(controller.dispose);
      await showSearch(tester, controller);
      final search = find.widgetWithText(TextField, 'Find your city');
      await tester.enterText(search, '  gOA  ');
      await tester.pumpAndSettle();
      expect(controller.visibleDestinations.single.id, 'goa');
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Mountains'));
      expect(controller.visibleDestinations, isEmpty);
      await tapVisible(tester, find.byTooltip('Clear city search'));
      expect(controller.query, isEmpty);
      expect(controller.visibleDestinations.map((d) => d.id), [
        'manali',
        'munnar',
      ]);
      await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.text('France').last);
      await tester.pumpAndSettle();
      expect(controller.visibleDestinations, isEmpty);
      await tester.scrollUntilVisible(
        find.text('No destinations found'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('No destinations found'), findsOneWidget);
      // Return to the top before using the reset control.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Reset filters'));
      expect(controller.visibleDestinations, hasLength(10));
      expect(controller.selectedCountry, isNull);
      expect(controller.selectedCategory, isNull);
      expect(tester.widget<TextField>(search).controller!.text, isEmpty);
      expect(find.text('All countries'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Search filters survive tab changes without filtering Home or Saved',
    (tester) async {
      final controller = TravelController(destinations, store: MemoryStore());
      addTearDown(controller.dispose);
      controller.toggleWishlist('goa');
      await showSearch(tester, controller);
      await tester.enterText(
        find.widgetWithText(TextField, 'Find your city'),
        'MAN',
      );
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Mountains'));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('10 cities to explore'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Mountains'), findsNothing);
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('1 saved places'), findsOneWidget);
      expect(find.text('Goa'), findsOneWidget);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(controller.visibleDestinations.single.id, 'manali');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'MAN',
      );
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Mountains'))
            .selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Search opens matcher with its travel type selected', (
    tester,
  ) async {
    final controller = TravelController(destinations, store: MemoryStore());
    addTearDown(controller.dispose);
    await showSearch(tester, controller);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Beaches'));
    await tapVisible(tester, find.text('Match my trip'));
    expect(find.byType(DestinationMatcherScreen), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('matcher-type-Beaches')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets(
    'matcher explains results, shares saves, and opens the chosen city',
    (tester) async {
      await tester.runAsync(() => PlaceCatalog.load(offline: true));
      await tester.binding.setSurfaceSize(const Size(1000, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = TravelController(destinations, store: MemoryStore());
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: DestinationMatcherScreen(controller: controller)),
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('matcher-type-Mountains')),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('matcher-budget-budget')),
      );
      await tapVisible(tester, find.byType(DropdownButtonFormField<int>));
      await tester.tap(find.text('4 days').last);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Find my matches'));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('matcher-save-manali')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('3/3 preferences matched'), findsOneWidget);
      expect(find.text('✓ Mountains travel type'), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('matcher-save-manali')),
      );
      expect(controller.isSaved('manali'), isTrue);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('matcher-explore-manali')),
      );
      expect(find.byType(CityDiscoverScreen), findsOneWidget);
      expect(
        tester
            .widget<CityDiscoverScreen>(find.byType(CityDiscoverScreen))
            .destination
            .id,
        'manali',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Search filters fit a small phone with larger text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = TravelController(destinations, store: MemoryStore());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: ExplorerScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Adventure'));
    expect(controller.visibleDestinations.single.id, 'rishikesh');
    await tapVisible(tester, find.text('Match my trip'));
    expect(find.byType(DestinationMatcherScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'small matcher clears stale results and labels partial suggestions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = TravelController(destinations, store: MemoryStore());
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: DestinationMatcherScreen(
            controller: controller,
            initialTravelType: 'Beaches',
          ),
        ),
      );
      await tapVisible(tester, find.byType(DropdownButtonFormField<int>));
      await tester.tap(find.text('7 days').last);
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Find my matches'));
      await tester.scrollUntilVisible(
        find.text('Closest options'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Closest options'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('No city matches every choice'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('No city matches every choice'),
        findsOneWidget,
      );
      await tester.drag(find.byType(ListView), const Offset(0, 1800));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Reset preferences'));
      expect(find.byKey(const ValueKey('match-results')), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton).first).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
