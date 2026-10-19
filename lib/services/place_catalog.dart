import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/local_place.dart';
import 'catalog_http.dart';

class CatalogResult {
  const CatalogResult(this.places, this.fromCloud);
  final List<LocalPlace> places;
  final bool fromCloud;
}

/// Public endpoints only. Database passwords never belong in Flutter code.
class PlaceCatalog {
  static const authUrl =
      'https://ep-gentle-wildflower-a1i7b8z3.neonauth.ap-southeast-1.aws.neon.tech/travel_explorer/auth';
  static const dataUrl =
      'https://ep-gentle-wildflower-a1i7b8z3.apirest.ap-southeast-1.aws.neon.tech/travel_explorer/rest/v1';
  static Future<CatalogResult>? _cached;
  static CatalogResult? _loaded;
  static Future<CatalogResult> load(
      {bool refresh = false, bool offline = false}) {
    if (refresh) {
      _cached = null;
      _loaded = null;
    }
    if (offline)
      return _cached = rootBundle
          .loadString('assets/data/places.json')
          .then((text) => _loaded = CatalogResult(_decode(text), false));
    if (_loaded != null) return Future.value(_loaded);
    return _cached ??= _load().then((result) => _loaded = result);
  }

  static List<LocalPlace> _decode(String text) {
    final rows = jsonDecode(text);
    if (rows is! List || rows.length > 500)
      throw const FormatException('Invalid catalog');
    return List.unmodifiable(rows.map(
        (row) => LocalPlace.fromJson(Map<String, dynamic>.from(row as Map))));
  }

  static Future<CatalogResult> _load() async {
    try {
      // Neon supplies a short-lived guest token. No user account is created.
      final auth =
          jsonDecode(await catalogGet(Uri.parse('$authUrl/token/anonymous')))
              as Map<String, dynamic>;
      final token = auth['token'];
      if (token is! String || token.isEmpty)
        throw const FormatException('Missing guest token');
      final text = await catalogGet(
          Uri.parse('$dataUrl/places?select=*&order=name.asc&limit=500'),
          headers: {'Authorization': 'Bearer $token'});
      return CatalogResult(_decode(text), true);
    } catch (_) {
      return CatalogResult(
          _decode(await rootBundle.loadString('assets/data/places.json')),
          false);
    }
  }
}
