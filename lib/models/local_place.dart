const placeKinds = <String, String>{
  'hotel': 'Stays',
  'restaurant': 'Food',
  'adventure': 'Adventure',
  'waterpark': 'Water parks',
  'mall': 'Shopping',
};

/// A directory entry, not a live booking or availability result.
class LocalPlace {
  const LocalPlace({
    required this.id,
    required this.cityId,
    required this.kind,
    required this.name,
    required this.area,
    required this.description,
    required this.sourceUrl,
    required this.checkedOn,
  });
  final String id, cityId, kind, name, area, description, sourceUrl, checkedOn;
  factory LocalPlace.fromJson(Map<String, dynamic> row) {
    String text(String key) {
      final value = row[key];
      if (value is! String || value.isEmpty || value.length > 1000) {
        throw FormatException('Invalid $key');
      }
      return value;
    }

    final kind = text('kind');
    final source = text('source_url');
    final uri = Uri.tryParse(source);
    if (!placeKinds.containsKey(kind) ||
        uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty) {
      throw const FormatException('Unsupported place');
    }
    return LocalPlace(
      id: text('id'),
      cityId: text('city_id'),
      kind: kind,
      name: text('name'),
      area: text('area'),
      description: text('description'),
      sourceUrl: source,
      checkedOn: text('checked_on'),
    );
  }
}
