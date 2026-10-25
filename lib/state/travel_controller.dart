import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

import '../models/destination.dart';
import '../models/trip_draft.dart';
import '../models/my_day.dart';
import '../services/local_store.dart';

/// Holds filters, saved IDs, and one saved trip draft per destination.
class TravelController extends ChangeNotifier {
  TravelController(List<Destination> destinations, {LocalStore? store})
    : _store = store,
      _destinations = List<Destination>.unmodifiable(destinations);

  static const wishlistKey = 'travel_explorer.wishlist.v1';
  static const myDayKey = 'travel_explorer.my_day.v1';
  final _dayPicks = <String, MyDay>{};
  MyDay myDayFor(String cityId) => _dayPicks[cityId] ?? MyDay();
  List<String> get pickedCities =>
      List.unmodifiable(_dayPicks.keys.where((id) => _dayPicks[id]!.count > 0));

  static const draftsKey = 'travel_explorer.drafts.v1';
  final LocalStore? _store;
  final _drafts = <String, TripDraft>{};
  Future<void> _writes = Future.value();
  bool _disposed = false;
  String? storageMessage;

  List<TripDraft> get drafts => List.unmodifiable(_drafts.values);
  TripDraft? draftFor(String id) => _drafts[id];

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> restore() async {
    if (_store == null) return;
    try {
      final text = await _store.read(wishlistKey);
      if (text != null) {
        final saved = jsonDecode(text);
        if (saved is! List) throw const FormatException('Invalid wishlist');
        _savedIds.addAll(
          saved.whereType<String>().where(
            (id) => _destinations.any((place) => place.id == id),
          ),
        );
      }
    } catch (_) {
      storageMessage =
          'Some saved data could not be read. Device storage may be unavailable.';
    }
    try {
      final text = await _store.read(draftsKey);
      if (text != null) {
        final saved = jsonDecode(text);
        if (saved is! Map<String, dynamic>) {
          throw const FormatException('Invalid drafts');
        }
        for (final entry in saved.entries) {
          try {
            final draft = TripDraft.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
            if (entry.key == draft.destinationId && _validDraft(draft)) {
              _drafts[entry.key] = draft;
            }
          } catch (_) {
            storageMessage =
                'An unreadable trip draft was skipped. Other saved trips are still available.';
          }
        }
      }
    } catch (_) {
      storageMessage =
          'Trip storage could not be read. You can still plan in this session.';
    }
    try {
      final text = await _store.read(myDayKey);
      if (text != null) {
        final decoded = jsonDecode(text);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid day picks');
        }
        for (final entry in decoded.entries) {
          if (!_destinations.any((d) => d.id == entry.key)) continue;
          try {
            _dayPicks[entry.key] = MyDay.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            );
          } catch (_) {
            storageMessage =
                'Some My day picks could not be read. Other saved data is available.';
          }
        }
      }
    } catch (_) {
      storageMessage =
          'My day could not be restored. You can still collect places this session.';
    }
    _notify();
  }

  bool _validDraft(TripDraft draft) =>
      _destinations.any((place) => place.id == draft.destinationId) &&
      draft.attraction.trim().isNotEmpty &&
      draft.attraction.length <= 500;

  // Serial writes prevent an older quick tap from overwriting a newer one.
  Future<bool> _persist(String key, Object value) async {
    if (_store == null) return true;
    final text = jsonEncode(value);
    final task = _writes.then((_) => _store.write(key, text));
    _writes = task.catchError((Object _) {});
    try {
      await task;
      return true;
    } catch (_) {
      storageMessage =
          'Changes could not be saved on this device. Keep this session open or copy your plan.';
      _notify();
      return false;
    }
  }

  Future<bool> _saveDay(String cityId, MyDay day) async {
    final ids = {...myDayFor(cityId).placeIds, ...day.placeIds}
      ..removeWhere((name, id) => !day.stops.contains(name));
    _dayPicks[cityId] = MyDay(
      stops: day.stops,
      hotel: day.hotel,
      restaurant: day.restaurant,
      placeIds: ids,
    );
    _notify();
    return _persist(
      myDayKey,
      _dayPicks.map((id, day) => MapEntry(id, day.toJson())),
    );
  }

  Future<bool> addToMyDay(
    String cityId,
    String name, {
    String kind = 'outing',
    String? placeId,
  }) async {
    name = name.trim();
    if (!_destinations.any((d) => d.id == cityId) ||
        name.isEmpty ||
        name.length > 500) {
      return false;
    }
    final day = myDayFor(cityId);
    if (kind == 'hotel') {
      return _saveDay(
        cityId,
        MyDay(stops: day.stops, hotel: name, restaurant: day.restaurant),
      );
    }
    if (kind == 'restaurant') {
      return _saveDay(
        cityId,
        MyDay(stops: day.stops, hotel: day.hotel, restaurant: name),
      );
    }
    final existing = day.stops.where(
      (p) => p.toLowerCase() == name.toLowerCase(),
    );
    if (existing.isNotEmpty) {
      if (placeId != null) {
        return _saveDay(
          cityId,
          MyDay(
            stops: day.stops,
            hotel: day.hotel,
            restaurant: day.restaurant,
            placeIds: {existing.first: placeId},
          ),
        );
      }
      return true;
    }
    if (day.stops.length >= 5) return false;
    return _saveDay(
      cityId,
      MyDay(
        placeIds: {if (placeId != null) name: placeId},
        stops: [...day.stops, name],
        hotel: day.hotel,
        restaurant: day.restaurant,
      ),
    );
  }

  Future<bool> removeFromMyDay(
    String cityId,
    String name, {
    String kind = 'outing',
  }) {
    final day = myDayFor(cityId);
    return _saveDay(
      cityId,
      MyDay(
        stops: kind == 'outing'
            ? day.stops.where((p) => p != name).toList()
            : day.stops,
        hotel: kind == 'hotel' ? '' : day.hotel,
        restaurant: kind == 'restaurant' ? '' : day.restaurant,
      ),
    );
  }

  Future<bool> moveDayStop(String cityId, int index, int offset) async {
    final day = myDayFor(cityId);
    final target = index + offset;
    if (index < 0 ||
        index >= day.stops.length ||
        target < 0 ||
        target >= day.stops.length) {
      return false;
    }
    final stops = List<String>.of(day.stops);
    final item = stops.removeAt(index);
    stops.insert(target, item);
    return _saveDay(
      cityId,
      MyDay(stops: stops, hotel: day.hotel, restaurant: day.restaurant),
    );
  }

  Future<void> waitForWrites() => _writes;

  Future<bool> saveDraft(TripDraft draft) async {
    if (!_validDraft(draft)) return false;
    _drafts[draft.destinationId] = draft;
    _notify();
    return _persist(
      draftsKey,
      _drafts.map((id, item) => MapEntry(id, item.toJson())),
    );
  }

  Future<bool> removeDraft(String id) async {
    _drafts.remove(id);
    _notify();
    return _persist(
      draftsKey,
      _drafts.map((id, item) => MapEntry(id, item.toJson())),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final List<Destination> _destinations;
  final Set<String> _savedIds = <String>{};
  String _query = '';
  String? _selectedCategory;
  String? _selectedCountry;

  String get query => _query;
  String? get selectedCategory => _selectedCategory;
  String? get selectedCountry => _selectedCountry;
  List<String> get categories =>
      List.unmodifiable(_destinations.map((place) => place.category).toSet());
  bool get hasFilters =>
      _query.isNotEmpty ||
      _selectedCategory != null ||
      _selectedCountry != null;
  List<String> get countries =>
      (_destinations.map((place) => place.country).toSet().toList()..sort());

  List<Destination> get visibleDestinations {
    final search = _query.trim().toLowerCase();
    return List<Destination>.unmodifiable(
      _destinations.where((destination) {
        final matchesName = destination.name.toLowerCase().contains(search);
        final matchesCategory =
            _selectedCategory == null ||
            destination.category == _selectedCategory;
        final matchesCountry =
            _selectedCountry == null || destination.country == _selectedCountry;
        return matchesName && matchesCategory && matchesCountry;
      }),
    );
  }

  List<Destination> get wishlist => List<Destination>.unmodifiable(
    _destinations.where((destination) => _savedIds.contains(destination.id)),
  );

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    _notify();
  }

  /// Pass null to show all categories.
  void setCategory(String? value) {
    if (_selectedCategory == value) return;
    _selectedCategory = value;
    _notify();
  }

  bool isSaved(String id) => _savedIds.contains(id);

  void setCountry(String? value) {
    if (_selectedCountry == value) return;
    _selectedCountry = value;
    _notify();
  }

  void clearFilters() {
    if (!hasFilters) return;
    _query = '';
    _selectedCategory = null;
    _selectedCountry = null;
    _notify();
  }

  void toggleWishlist(String id) {
    if (!_destinations.any((destination) => destination.id == id)) return;
    if (!_savedIds.remove(id)) {
      _savedIds.add(id);
    }
    _notify();
    unawaited(_persist(wishlistKey, _savedIds.toList()));
  }
}
