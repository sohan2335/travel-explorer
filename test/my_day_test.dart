import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/state/travel_controller.dart';

void main() {
  test(
      'directory IDs persist, attach to old name picks and disappear on removal',
      () async {
    final store = MemoryStore();
    final c = TravelController(destinations, store: store);
    await c.addToMyDay('goa', 'Fort Aguada');
    await c.addToMyDay('goa', 'fort aguada', placeId: 'goa:sight:Fort Aguada');
    await c.addToMyDay('goa', 'Mall', placeId: 'catalog:mall');
    await c.moveDayStop('goa', 1, -1);
    final restored = TravelController(destinations, store: store);
    await restored.restore();
    expect(restored.myDayFor('goa').stops, ['Mall', 'Fort Aguada']);
    expect(restored.myDayFor('goa').placeIds['Fort Aguada'],
        'goa:sight:Fort Aguada');
    await restored.removeFromMyDay('goa', 'Mall');
    expect(restored.myDayFor('goa').placeIds.containsKey('Mall'), isFalse);
    expect(restored.myDayFor('goa').placeIds.length, 1);
    c.dispose();
    restored.dispose();
  });

  test('picks accumulate by city, deduplicate and restore in order', () async {
    final store = MemoryStore();
    final c = TravelController(destinations, store: store);
    await c.addToMyDay('goa', 'Beach');
    await c.addToMyDay('goa', 'Mall');
    await c.addToMyDay('goa', 'beach');
    await c.addToMyDay('paris', 'Museum');
    expect(c.myDayFor('goa').stops, ['Beach', 'Mall']);
    await c.moveDayStop('goa', 1, -1);
    final restored = TravelController(destinations, store: store);
    await restored.restore();
    expect(restored.myDayFor('goa').stops, ['Mall', 'Beach']);
    expect(restored.myDayFor('paris').stops, ['Museum']);
    expect(restored.drafts, isEmpty);
    c.dispose();
    restored.dispose();
  });
  test('stay and meal replacement preserve all outings', () async {
    final c = TravelController(destinations);
    await c.addToMyDay('goa', 'Park');
    await c.addToMyDay('goa', 'Hotel A', kind: 'hotel');
    await c.addToMyDay('goa', 'Hotel B', kind: 'hotel');
    await c.addToMyDay('goa', 'Cafe', kind: 'restaurant');
    expect(c.myDayFor('goa').hotel, 'Hotel B');
    expect(c.myDayFor('goa').restaurant, 'Cafe');
    expect(c.myDayFor('goa').stops, ['Park']);
    expect(c.myDayFor('goa').count, 3);
    await c.removeFromMyDay('goa', 'Cafe', kind: 'restaurant');
    expect(c.myDayFor('goa').restaurant, isEmpty);
    expect(c.myDayFor('goa').stops, ['Park']);
    c.dispose();
  });
  test('five-outing limit, invalid inputs and reorder bounds are enforced',
      () async {
    final c = TravelController(destinations);
    for (var i = 0; i < 5; i++) {
      expect(await c.addToMyDay('goa', 'Stop $i'), isTrue);
    }
    expect(await c.addToMyDay('goa', 'Sixth'), isFalse);
    expect(await c.addToMyDay('missing', 'Stop'), isFalse);
    expect(await c.addToMyDay('goa', ' '), isFalse);
    expect(await c.moveDayStop('goa', 0, -1), isFalse);
    expect(await c.moveDayStop('goa', 4, 1), isFalse);
    await c.removeFromMyDay('goa', 'Stop 2');
    expect(await c.addToMyDay('goa', 'New stop'), isTrue);
    expect(c.myDayFor('goa').stops.last, 'New stop');
    c.dispose();
  });
  test('bad city picks do not prevent other cities from restoring', () async {
    final store = MemoryStore();
    store.values[TravelController.myDayKey] =
        '{"goa":{"stops":["Mall","mall"],"hotel":"","restaurant":""},"paris":{"stops":["Museum"],"hotel":"","restaurant":""}}';
    final c = TravelController(destinations, store: store);
    await c.restore();
    expect(c.myDayFor('goa').stops, isEmpty);
    expect(c.myDayFor('paris').stops, ['Museum']);
    expect(c.storageMessage, isNotNull);
    c.dispose();
  });
}
