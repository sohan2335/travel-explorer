import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

import '../models/destination.dart';
import '../models/trip_draft.dart';
import '../services/local_store.dart';

/// Holds filters, saved IDs, and one saved trip draft per destination.
class TravelController extends ChangeNotifier {
  TravelController(List<Destination> destinations, {LocalStore? store})
      : _store = store,
        _destinations = List<Destination>.unmodifiable(destinations);

  static const wishlistKey = 'travel_explorer.wishlist.v1';
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
        _savedIds.addAll(saved
            .whereType<String>()
            .where((id) => _destinations.any((place) => place.id == id)));
      }
    } catch (_) {
      storageMessage =
          'Some saved data could not be read. Device storage may be unavailable.';
    }
    try {
      final text = await _store.read(draftsKey);
      if (text != null) {
        final saved = jsonDecode(text);
        if (saved is! Map<String, dynamic>)
          throw const FormatException('Invalid drafts');
        for (final entry in saved.entries) {
          try {
            final draft = TripDraft.fromJson(
                Map<String, dynamic>.from(entry.value as Map));
            if (entry.key == draft.destinationId && _validDraft(draft))
              _drafts[entry.key] = draft;
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

  Future<void> waitForWrites() => _writes;

  Future<bool> saveDraft(TripDraft draft) async {
    if (!_validDraft(draft)) return false;
    _drafts[draft.destinationId] = draft;
    _notify();
    return _persist(
        draftsKey, _drafts.map((id, item) => MapEntry(id, item.toJson())));
  }

  Future<bool> removeDraft(String id) async {
    _drafts.remove(id);
    _notify();
    return _persist(
        draftsKey, _drafts.map((id, item) => MapEntry(id, item.toJson())));
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
  List<String> get countries =>
      (_destinations.map((place) => place.country).toSet().toList()..sort());

  List<Destination> get visibleDestinations {
    final search = _query.trim().toLowerCase();
    return List<Destination>.unmodifiable(
      _destinations.where((destination) {
        final matchesName = destination.name.toLowerCase().contains(search);
        final matchesCategory = _selectedCategory == null ||
            destination.category == _selectedCategory;
        final matchesCountry =
            _selectedCountry == null || destination.country == _selectedCountry;
        return matchesName && matchesCategory && matchesCountry;
      }),
    );
  }

  List<Destination> get wishlist => List<Destination>.unmodifiable(
        _destinations
            .where((destination) => _savedIds.contains(destination.id)),
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

  void toggleWishlist(String id) {
    if (!_destinations.any((destination) => destination.id == id)) return;
    if (!_savedIds.remove(id)) {
      _savedIds.add(id);
    }
    _notify();
    unawaited(_persist(wishlistKey, _savedIds.toList()));
  }
}
