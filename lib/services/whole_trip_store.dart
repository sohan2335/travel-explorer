import 'dart:convert';
import '../data/destinations.dart';
import '../models/whole_trip.dart';
import 'local_store.dart';

/// A separate key leaves existing day drafts, picks and account storage intact.
class WholeTripStore {
  WholeTripStore(this.store);
  final LocalStore store;
  static const key = 'travel_explorer.whole_trips.v1';
  static Future<void> _writes = Future.value();
  Future<Map<String, WholeTrip>> load() async {
    final raw = await store.read(key).timeout(const Duration(seconds: 3));
    if (raw == null) return {};
    final json = jsonDecode(raw);
    if (json is! Map || json['version'] != 1 || json['trips'] is! Map) {
      throw const FormatException('Unreadable trip storage');
    }
    final trips = <String, WholeTrip>{};
    for (final entry in (json['trips'] as Map).entries) {
      final trip = WholeTrip.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
      if (trip.cityId != entry.key ||
          !destinations.any((d) => d.id == trip.cityId)) {
        throw const FormatException('Unknown trip city');
      }
      trips[trip.cityId] = trip;
    }
    return trips;
  }

  Future<bool> save(WholeTrip trip) async {
    var success = false;
    final task = _writes.then((_) async {
      try {
        WholeTrip.fromJson(trip.toJson());
        if (!destinations.any((d) => d.id == trip.cityId)) {
          return;
        }
        final trips = await load();
        trips[trip.cityId] = trip;
        await store
            .write(
              key,
              jsonEncode({
                'version': 1,
                'trips': trips.map((id, plan) => MapEntry(id, plan.toJson())),
              }),
            )
            .timeout(const Duration(seconds: 3));
        success = true;
      } catch (_) {
        /* Preserve unreadable storage and keep the in-memory plan. */
      }
    });
    _writes = task.catchError((Object _) {});
    await task;
    return success;
  }
}
