import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/models/destination.dart';
import 'package:travel_explorer/state/travel_controller.dart';

Destination destination(String id, String name, String category) => Destination(
      id: id,
      name: name,
      location: 'India',
      category: category,
      imageUrl: 'https://example.com/$id.jpg',
      description: 'A sample destination.',
      bestTimeToVisit: 'October',
      attractions: const [],
    );

void main() {
  late TravelController controller;

  setUp(() {
    controller = TravelController([
      destination('goa', 'Goa', 'Beach'),
      destination('gokarna', 'Gokarna', 'Beach'),
      destination('gulmarg', 'Gulmarg', 'Mountain'),
    ]);
  });

  tearDown(() => controller.dispose());

  test('starts with every destination and an empty wishlist', () {
    expect(controller.query, isEmpty);
    expect(controller.selectedCategory, isNull);
    expect(controller.visibleDestinations, hasLength(3));
    expect(controller.wishlist, isEmpty);
  });

  test('name search ignores case and surrounding whitespace', () {
    controller.setQuery('  GOA  ');
    expect(controller.visibleDestinations.map((item) => item.id), ['goa']);
    controller.setQuery('   ');
    expect(controller.visibleDestinations, hasLength(3));
  });

  test('search and category must both match; null resets category', () {
    controller.setQuery('g');
    controller.setCategory('Beach');
    expect(controller.visibleDestinations.map((item) => item.id),
        ['goa', 'gokarna']);
    controller.setQuery('gul');
    expect(controller.visibleDestinations, isEmpty);
    controller.setCategory(null);
    expect(controller.visibleDestinations.single.id, 'gulmarg');
    controller.setCategory('mountain');
    expect(controller.visibleDestinations, isEmpty);
  });

  test('wishlist toggles items and ignores unknown IDs', () {
    controller.toggleWishlist('goa');
    expect(controller.isSaved('goa'), isTrue);
    expect(controller.wishlist.single.id, 'goa');
    controller.setQuery('gul');
    expect(controller.wishlist.single.id, 'goa');
    controller.toggleWishlist('unknown');
    expect(controller.isSaved('unknown'), isFalse);
    expect(controller.wishlist, hasLength(1));
    controller.toggleWishlist('goa');
    expect(controller.isSaved('goa'), isFalse);
    expect(controller.wishlist, isEmpty);
  });

  test('notifies only when a valid state change occurs', () {
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.setQuery('go');
    controller.setQuery('go');
    controller.setCategory('Beach');
    controller.setCategory('Beach');
    controller.toggleWishlist('unknown');
    expect(notifications, 2);
    controller.toggleWishlist('goa');
    controller.toggleWishlist('goa');
    controller.setCategory(null);
    expect(notifications, 5);
  });

  test('country is combined with category and name without changing saved IDs',
      () {
    final global = TravelController([
      destination('goa', 'Goa', 'Beach'),
      const Destination(
          id: 'paris',
          name: 'Paris',
          location: 'Paris, France',
          country: 'France',
          category: 'Heritage',
          imageUrl: '',
          description: '',
          bestTimeToVisit: '',
          attractions: []),
    ]);
    addTearDown(global.dispose);
    global.toggleWishlist('goa');
    global.setCountry('France');
    expect(global.visibleDestinations.single.id, 'paris');
    expect(global.wishlist.single.id, 'goa');
    global.setQuery('GOA');
    expect(global.visibleDestinations, isEmpty);
    global.setCountry(null);
    expect(global.visibleDestinations.single.id, 'goa');
    expect(global.countries, ['France', 'India']);
  });
}
