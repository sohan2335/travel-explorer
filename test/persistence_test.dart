import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/models/trip_draft.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/state/travel_controller.dart';

const draft = TripDraft(
  destinationId: 'goa',
  origin: 'Station',
  hotel: 'Hotel',
  arrivalMinutes: 540,
  hotelReadyMinutes: 840,
  restMinutes: 90,
  travelMinutes: 60,
  mode: 'transit',
  attraction: 'Palolem Beach',
  pace: 'Relaxed',
  hasPlan: true,
);

class FailingStore implements LocalStore {
  @override
  Future<String?> read(String key) async => throw StateError('Unavailable');
  @override
  Future<void> write(String key, String value) async =>
      throw StateError('Full');
}

void main() {
  test('directory outings, meals and longer visits restore', () async {
    final store = MemoryStore();
    final first = TravelController(destinations, store: store);
    final custom = TripDraft.fromJson({
      ...draft.toJson(),
      'attraction': 'Custom main outing',
      'restaurant': 'Sample cafe',
      'visitMinutes': 240,
    });
    expect(await first.saveDraft(custom), isTrue);
    final next = TravelController(destinations, store: store);
    await next.restore();
    expect(next.draftFor('goa')!.attraction, 'Custom main outing');
    expect(next.draftFor('goa')!.restaurant, 'Sample cafe');
    expect(next.draftFor('goa')!.visitMinutes, 240);
    first.dispose();
    next.dispose();
  });

  test('new controller restores wishlist and typed draft', () async {
    final store = MemoryStore();
    final first = TravelController(destinations, store: store);
    first.toggleWishlist('goa');
    expect(await first.saveDraft(draft), isTrue);
    await first.waitForWrites();
    first.dispose();
    final next = TravelController(destinations, store: store);
    await next.restore();
    expect(next.isSaved('goa'), isTrue);
    expect(next.draftFor('goa')!.pace, 'Relaxed');
    expect(next.draftFor('goa')!.hasPlan, isTrue);
    await next.removeDraft('goa');
    final afterDelete = TravelController(destinations, store: store);
    await afterDelete.restore();
    expect(afterDelete.drafts, isEmpty);
    next.dispose();
    afterDelete.dispose();
  });

  test('rapid wishlist taps persist the final selection', () async {
    final store = MemoryStore();
    final controller = TravelController(destinations, store: store);
    controller.toggleWishlist('goa');
    controller.toggleWishlist('goa');
    controller.toggleWishlist('paris');
    await controller.waitForWrites();
    final restored = TravelController(destinations, store: store);
    await restored.restore();
    expect(restored.isSaved('goa'), isFalse);
    expect(restored.isSaved('paris'), isTrue);
    controller.dispose();
    restored.dispose();
  });

  test('bad draft does not prevent valid draft restoration', () async {
    final store = MemoryStore();
    store.values[TravelController.wishlistKey] = '["goa","missing-city"]';
    store.values[TravelController.draftsKey] = jsonEncode({
      'goa': draft.toJson(),
      'broken': {'version': 99},
    });
    final controller = TravelController(destinations, store: store);
    await controller.restore();
    expect(controller.wishlist.length, 1);
    expect(controller.drafts.length, 1);
    expect(controller.storageMessage, isNotNull);
    controller.dispose();
  });

  test('storage failure is visible and save reports failure', () async {
    final controller = TravelController(destinations, store: FailingStore());
    await controller.restore();
    expect(controller.storageMessage, isNotNull);
    expect(await controller.saveDraft(draft), isFalse);
    expect(controller.storageMessage, contains('could not be saved'));
    controller.dispose();
  });
}
