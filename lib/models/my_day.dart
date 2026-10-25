/// Picks made while browsing, kept separately from a saved timetable.
class MyDay {
  MyDay({
    List<String> stops = const [],
    this.hotel = '',
    this.restaurant = '',
    Map<String, String> placeIds = const {},
  }) : stops = List.unmodifiable(stops),
       placeIds = Map.unmodifiable(placeIds);
  final List<String> stops;
  final Map<String, String> placeIds;
  final String hotel, restaurant;
  int get count =>
      stops.length + (hotel.isEmpty ? 0 : 1) + (restaurant.isEmpty ? 0 : 1);
  Map<String, Object> toJson() => {
    'stops': stops,
    'hotel': hotel,
    'restaurant': restaurant,
    'placeIds': placeIds,
  };
  factory MyDay.fromJson(Map<String, dynamic> data) {
    final stops = data['stops'];
    bool valid(Object? value) => value is String && value.length <= 500;
    if (stops is! List ||
        stops.length > 5 ||
        stops.any((p) => !valid(p) || (p as String).trim().isEmpty) ||
        !valid(data['hotel']) ||
        !valid(data['restaurant'])) {
      throw const FormatException('Invalid day picks');
    }
    final names = stops.cast<String>();
    if (names.map((p) => p.trim().toLowerCase()).toSet().length !=
        names.length) {
      throw const FormatException('Repeated day picks');
    }
    final ids = data['placeIds'] ?? <String, String>{};
    if (ids is! Map ||
        ids.length > 5 ||
        ids.entries.any(
          (e) =>
              e.key is! String ||
              e.value is! String ||
              (e.value as String).length > 1000 ||
              !names.contains(e.key),
        )) {
      throw const FormatException('Invalid place IDs');
    }
    return MyDay(
      placeIds: Map<String, String>.from(ids),
      stops: names,
      hotel: data['hotel'] as String,
      restaurant: data['restaurant'] as String,
    );
  }
}
