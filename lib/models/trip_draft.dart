/// Save the inputs, then rebuild the timetable when the traveller returns.
class TripDraft {
  const TripDraft(
      {required this.destinationId,
      required this.origin,
      required this.hotel,
      required this.arrivalMinutes,
      required this.hotelReadyMinutes,
      required this.restMinutes,
      required this.travelMinutes,
      required this.mode,
      required this.attraction,
      required this.pace,
      required this.hasPlan,
      this.restaurant = '',
      this.visitMinutes = 0});

  final String destinationId;
  final String origin;
  final String hotel;
  final String restaurant;
  final int visitMinutes;
  final int arrivalMinutes;
  final int hotelReadyMinutes;
  final int restMinutes;
  final int travelMinutes;
  final String mode;
  final String attraction;
  final String pace;
  final bool hasPlan;

  Map<String, Object> toJson() => {
        'version': 1,
        'destinationId': destinationId,
        'origin': origin,
        'hotel': hotel,
        'restaurant': restaurant,
        'visitMinutes': visitMinutes,
        'arrivalMinutes': arrivalMinutes,
        'hotelReadyMinutes': hotelReadyMinutes,
        'restMinutes': restMinutes,
        'travelMinutes': travelMinutes,
        'mode': mode,
        'attraction': attraction,
        'pace': pace,
        'hasPlan': hasPlan,
      };

  factory TripDraft.fromJson(Map<String, dynamic> data) {
    String text(String key) {
      final value = data[key];
      if (value is! String || value.length > 500)
        throw const FormatException('Invalid saved text');
      return value;
    }

    int number(String key, int min, int max) {
      final value = data[key];
      if (value is! int || value < min || value > max)
        throw const FormatException('Invalid saved time');
      return value;
    }

    final mode = text('mode');
    final pace = text('pace');
    final rest = number('restMinutes', 0, 180);
    final travel = number('travelMinutes', 15, 180);
    final visit =
        data.containsKey('visitMinutes') ? number('visitMinutes', 0, 480) : 0;
    if (![0, 30, 60, 90, 120, 180, 240, 360, 480].contains(visit) ||
        data['version'] != 1 ||
        data['hasPlan'] is! bool ||
        !['transit', 'driving', 'walking', 'bicycling'].contains(mode) ||
        !['Relaxed', 'Balanced', 'Packed'].contains(pace) ||
        ![0, 30, 60, 90, 120, 180].contains(rest) ||
        ![15, 30, 60, 90, 120, 180].contains(travel)) {
      throw const FormatException('Unsupported saved draft');
    }
    return TripDraft(
        destinationId: text('destinationId'),
        origin: text('origin'),
        hotel: text('hotel'),
        restaurant: data.containsKey('restaurant') ? text('restaurant') : '',
        arrivalMinutes: number('arrivalMinutes', 0, 1439),
        hotelReadyMinutes: number('hotelReadyMinutes', 0, 1439),
        visitMinutes: visit,
        restMinutes: rest,
        travelMinutes: travel,
        mode: mode,
        attraction: text('attraction'),
        pace: pace,
        hasPlan: data['hasPlan'] as bool);
  }
}
