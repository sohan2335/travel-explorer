import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/models/day_plan.dart';
import 'package:travel_explorer/models/trip_draft.dart';
import 'package:travel_explorer/models/whole_trip.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/services/whole_trip_store.dart';

TripDraft sampleDay(
  String city, {
  String stop = 'Palolem Beach',
  bool ready = true,
}) => TripDraft(
  destinationId: city,
  origin: 'Home',
  hotel: 'Home',
  arrivalMinutes: 540,
  hotelReadyMinutes: 840,
  restMinutes: 0,
  travelMinutes: 30,
  mode: 'transit',
  attraction: stop,
  pace: 'Balanced',
  hasPlan: ready,
  visitMinutes: 90,
);
WholeTrip sampleTrip(String city) => WholeTrip(
  cityId: city,
  startDate: DateTime(2026, 10, 22),
  days: [
    sampleDay(city),
    sampleDay(city, stop: 'Fort Aguada'),
  ],
);

void main() {
  test(
    'local day begins directly with outings and no arrival/check-in wait',
    () {
      final plan = wholeTripDayPlan(sampleDay('goa'));
      expect(plan.first.startMinutes, 540);
      expect(plan.first.title, 'Travel to your attraction');
      expect(plan.map((s) => s.title), isNot(contains('Arrive & settle in')));
      expect(
        plan.map((s) => s.title),
        isNot(contains('Time before room access')),
      );
      expect(plan.last.title, 'Return to starting point');
      expect(plan.last.timeRange, '12:00 - 12:30');
    },
  );
  test('local day still rejects a schedule past midnight', () {
    expect(
      () => buildDayPlan(
        arrivalMinutes: 1380,
        origin: 'Home',
        hotel: 'Home',
        attraction: 'Beach',
        restMinutes: 0,
        travelMinutes: 30,
        includeArrival: false,
      ),
      throwsArgumentError,
    );
  });
  test('whole trip round-trip preserves dates and independent day details', () {
    final restored = WholeTrip.fromJson(
      jsonDecode(jsonEncode(sampleTrip('goa').toJson())),
    );
    expect(restored.cityId, 'goa');
    expect(tripDate(restored.startDate), '2026-10-22');
    expect(restored.days[0].attraction, 'Palolem Beach');
    expect(restored.days[1].attraction, 'Fort Aguada');
    expect(() => restored.days.add(sampleDay('goa')), throwsUnsupportedError);
  });
  test('invalid dates, cities and day counts cannot become a whole trip', () {
    final json = sampleTrip('goa').toJson();
    expect(
      () => WholeTrip.fromJson({
        ...json,
        'days': [sampleDay('goa').toJson()],
      }),
      throwsFormatException,
    );
    expect(
      () => WholeTrip.fromJson({...json, 'startDate': '2026-02-31'}),
      throwsFormatException,
    );
    expect(
      () => WholeTrip.fromJson({...json, 'startDate': '2200-01-01'}),
      throwsFormatException,
    );
    expect(
      () => WholeTrip.fromJson({
        ...json,
        'days': [sampleDay('goa').toJson(), sampleDay('paris').toJson()],
      }),
      throwsFormatException,
    );
  });
  test(
    'saving city trips concurrently preserves both and leaves day drafts alone',
    () async {
      final store = MemoryStore();
      store.values['travel_explorer.drafts.v1'] = 'existing day draft';
      final trips = WholeTripStore(store);
      expect(
        await Future.wait([
          trips.save(sampleTrip('goa')),
          trips.save(sampleTrip('paris')),
        ]),
        [true, true],
      );
      final reopened = await WholeTripStore(store).load();
      expect(reopened.keys, containsAll(['goa', 'paris']));
      expect(store.values['travel_explorer.drafts.v1'], 'existing day draft');
    },
  );
  test(
    'damaged trip storage is reported and never overwritten by a save',
    () async {
      final store = MemoryStore();
      store.values[WholeTripStore.key] = 'broken';
      final trips = WholeTripStore(store);
      await expectLater(trips.load(), throwsFormatException);
      expect(await trips.save(sampleTrip('goa')), isFalse);
      expect(store.values[WholeTripStore.key], 'broken');
    },
  );
}
