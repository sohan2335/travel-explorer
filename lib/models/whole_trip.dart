import 'trip_draft.dart';
import 'day_plan.dart';

String tripDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// A multi-day city trip reuses the familiar editable day inputs.
class WholeTrip {
  const WholeTrip({
    required this.cityId,
    required this.startDate,
    required this.days,
  });
  final String cityId;
  final DateTime startDate;
  final List<TripDraft> days;
  WholeTrip copyWith({DateTime? startDate, List<TripDraft>? days}) => WholeTrip(
    cityId: cityId,
    startDate: startDate ?? this.startDate,
    days: List.unmodifiable(days ?? this.days),
  );
  Map<String, Object> toJson() => {
    'cityId': cityId,
    'startDate': tripDate(startDate),
    'days': days.map((d) => d.toJson()).toList(),
  };
  factory WholeTrip.fromJson(Map<String, dynamic> json) {
    final city = json['cityId'];
    final date = DateTime.tryParse(
      json['startDate'] is String ? json['startDate'] : '',
    );
    final entries = json['days'];
    if (city is! String ||
        city.isEmpty ||
        date == null ||
        date.isBefore(DateTime(2020)) ||
        date.isAfter(DateTime(2100)) ||
        tripDate(date) != json['startDate'] ||
        entries is! List ||
        entries.length < 2 ||
        entries.length > 7) {
      throw const FormatException('Invalid whole trip');
    }
    final days = entries
        .map((d) => TripDraft.fromJson(Map<String, dynamic>.from(d as Map)))
        .toList();
    if (days.any(
      (d) =>
          d.destinationId != city ||
          d.attraction.trim().isEmpty ||
          d.hotel.trim().isEmpty,
    )) {
      throw const FormatException('Trip city mismatch');
    }
    return WholeTrip(
      cityId: city,
      startDate: date,
      days: List.unmodifiable(days),
    );
  }
}

List<DayPlanStop> wholeTripDayPlan(TripDraft day) => buildDayPlan(
  arrivalMinutes: day.arrivalMinutes,
  origin: day.hotel,
  hotel: day.hotel,
  attraction: day.attraction,
  restMinutes: day.restMinutes,
  travelMinutes: day.travelMinutes,
  pace: day.pace,
  mealPlace: day.restaurant,
  additionalPlaces: day.additionalPlaces,
  visitMinutesOverride: day.visitMinutes == 0 ? null : day.visitMinutes,
  includeArrival: false,
);
