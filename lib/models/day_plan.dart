/// Minutes since midnight are simpler to add than formatted clock strings.
class DayPlanStop {
  const DayPlanStop(
      this.startMinutes, this.durationMinutes, this.title, this.note,
      {this.origin, this.destination});
  final int startMinutes;
  final int durationMinutes;
  final String title;
  final String note;
  final String? origin;
  final String? destination;

  String get timeRange =>
      '${clockTime(startMinutes)} - ${clockTime(startMinutes + durationMinutes)}';
}

String clockTime(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

const visitMinutesByPace = {'Relaxed': 120, 'Balanced': 90, 'Packed': 60};
const restMinutesByPace = {'Relaxed': 90, 'Balanced': 60, 'Packed': 30};

/// A transparent timetable template, not an AI model or a live route optimiser.
List<DayPlanStop> buildDayPlan({
  required int arrivalMinutes,
  required String origin,
  required String hotel,
  required String attraction,
  required int restMinutes,
  required int travelMinutes,
  int hotelReadyMinutes = 0,
  bool includeArrival = true,
  String pace = 'Balanced',
  String mealPlace = '',
  int? visitMinutesOverride,
  List<String> additionalPlaces = const [],
}) {
  if (additionalPlaces.length > 4 ||
      additionalPlaces
          .any((name) => name.trim().isEmpty || name.length > 500) ||
      {
            attraction.trim().toLowerCase(),
            ...additionalPlaces.map((p) => p.trim().toLowerCase())
          }.length !=
          additionalPlaces.length + 1)
    throw ArgumentError('Choose up to five different outings.');
  final paceMinutes = visitMinutesByPace[pace];
  final visitMinutes = visitMinutesOverride ?? paceMinutes;
  if (paceMinutes == null || visitMinutes == null)
    throw ArgumentError('Choose a supported sightseeing pace.');
  if (![30, 60, 90, 120, 180, 240, 360, 480].contains(visitMinutes))
    throw ArgumentError(
        'Choose a visit duration between 30 minutes and 8 hours.');
  if (origin.trim().isEmpty ||
      hotel.trim().isEmpty ||
      attraction.trim().isEmpty) {
    throw ArgumentError('Enter an arrival point, hotel and attraction.');
  }
  if (arrivalMinutes < 0 ||
      arrivalMinutes >= 1440 ||
      restMinutes < 0 ||
      restMinutes > 180 ||
      travelMinutes < 15 ||
      travelMinutes > 180 ||
      hotelReadyMinutes < 0 ||
      hotelReadyMinutes >= 1440) {
    throw ArgumentError('Choose valid arrival, rest and travel times.');
  }
  // Arrival 30 + hotel 30 + meal 60 = 120, plus the visit, rest and transfers.
  final hotelArrival = arrivalMinutes + 30 + travelMinutes;
  final waitingMinutes =
      includeArrival && hotelReadyMinutes > hotelArrival ? hotelReadyMinutes - hotelArrival : 0;
  final mealTransfer = mealPlace.trim().isEmpty ? 0 : travelMinutes;
  final end = arrivalMinutes +
      additionalPlaces.length * (travelMinutes + visitMinutes) +
      mealTransfer +
      (includeArrival ? 120 : 60) +
      visitMinutes +
      restMinutes +
      (includeArrival ? 3 : 2) * travelMinutes +
      waitingMinutes;
  if (end > 1440) {
    throw ArgumentError(
        includeArrival ? 'This plan would go past midnight. Choose an earlier arrival or shorter rest/travel buffers.' : 'This plan would go past midnight. Choose an earlier start time or shorter breaks and transfer buffers.');
  }
  var time = arrivalMinutes;
  final stops = <DayPlanStop>[];
  void add(int duration, String title, String note,
      {String? from, String? to}) {
    stops.add(DayPlanStop(time, duration, title, note,
        origin: from, destination: to));
    time += duration;
  }

  if (includeArrival) {
  add(30, 'Arrive & settle in',
      'Allow time for arrival formalities at $origin.');
  add(travelMinutes, 'Travel to your hotel',
      'Your chosen travel buffer; check the actual route.',
      from: origin, to: hotel);
  if (waitingMinutes > 0) {
    add(waitingMinutes, 'Time before room access',
        'Room access is set to ${clockTime(hotelReadyMinutes)}. Confirm luggage storage and use this time for a meal or arrival arrangements.');
  }
  add(30, 'Check in or arrange luggage drop',
      'Confirm check-in time and luggage arrangements with $hotel.');
  }
  if (restMinutes > 0)
    add(restMinutes, includeArrival ? 'Rest & refresh' : 'Take a break',
        includeArrival ? 'Rest at your accommodation if access is available.' : 'Your optional break before exploring.');
  add(travelMinutes, 'Travel to your attraction',
      'Use directions to check travel time and the available modes.',
      from: hotel, to: attraction);
  add(visitMinutes, 'Explore $attraction',
      '$pace pace: $visitMinutes minutes for this visit. Confirm opening hours and entry tickets.');
  var lastPlace = attraction;
  for (final place in additionalPlaces) {
    add(travelMinutes, 'Travel to $place',
        'Your transfer buffer; check the route and opening hours.',
        from: lastPlace, to: place);
    add(visitMinutes, 'Explore $place',
        '$visitMinutes minutes for this stop. Confirm availability and any tickets.');
    lastPlace = place;
  }
  if (mealTransfer > 0) {
    add(mealTransfer, 'Travel to your meal stop',
        'Your transfer buffer; check the route to ${mealPlace.trim()}.',
        from: lastPlace, to: mealPlace.trim());
  }
  add(
      60,
      'Meal & a break',
      mealPlace.trim().isEmpty
          ? 'Choose a suitable meal stop close to the attraction.'
          : 'Meal stop: ${mealPlace.trim()}. Check the route from $lastPlace and allow extra transfer time if needed.');
  add(travelMinutes, includeArrival ? 'Return to your hotel' : 'Return to starting point',
      'Check the return route and last public-transport service.',
      from: mealPlace.trim().isEmpty ? lastPlace : mealPlace.trim(), to: hotel);
  return List.unmodifiable(stops);
}
