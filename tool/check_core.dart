// Run without Flutter's socket-based test runner:
// dart tool/check_core.dart
import '../lib/models/day_plan.dart';
import '../lib/models/trip_draft.dart';
import '../lib/data/hyderabad_demo.dart';
import 'dart:convert';
import 'dart:io';
import '../lib/models/local_place.dart';
import '../lib/services/travel_links.dart';
import '../lib/data/destinations.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  check(!palaceOpenOn(DateTime(2026, 10, 23)),
      'Friday must flag palace closure.');
  check(palaceOpenOn(DateTime(2026, 10, 22)),
      'Thursday allows the example route.');
  for (var i = 1; i < hyderabadDemo.length; i++) {
    check(
        hyderabadDemo[i].startMinutes ==
            hyderabadDemo[i - 1].startMinutes +
                hyderabadDemo[i - 1].durationMinutes,
        'Demo stops must be contiguous.');
  }
  for (final pace in visitMinutesByPace.keys) {
    final paced = buildDayPlan(
        arrivalMinutes: 540,
        origin: 'Station',
        hotel: 'Hotel',
        attraction: 'Fort',
        restMinutes: restMinutesByPace[pace]!,
        travelMinutes: 30,
        pace: pace);
    check(
        paced.firstWhere((s) => s.title == 'Explore Fort').durationMinutes ==
            visitMinutesByPace[pace],
        'Visit duration must match pace.');
  }
  const draft = TripDraft(
      destinationId: 'goa',
      origin: 'Station',
      hotel: 'Hotel',
      arrivalMinutes: 540,
      hotelReadyMinutes: 840,
      restMinutes: 90,
      travelMinutes: 60,
      mode: 'transit',
      attraction: 'Palolem Beach',
      pace: 'Relaxed',
      hasPlan: true);
  final restored = TripDraft.fromJson(
      jsonDecode(jsonEncode(draft.toJson())) as Map<String, dynamic>);
  check(
      restored.pace == 'Relaxed' &&
          restored.hasPlan &&
          restored.hotel == 'Hotel',
      'Draft inputs must survive JSON round trip.');
  var badDrafts = 0;
  for (final invalid in [
    {'version': 99},
    {...draft.toJson(), 'restMinutes': -1},
    {...draft.toJson(), 'mode': 'teleport'}
  ]) {
    try {
      TripDraft.fromJson(invalid);
    } on FormatException {
      badDrafts++;
    }
  }
  check(badDrafts == 3, 'Malformed and unsupported drafts must be rejected.');
  final places =
      (jsonDecode(File('assets/data/places.json').readAsStringSync()) as List)
          .map((r) => LocalPlace.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
  check(
      places.length == 24, 'Twenty-four sourced directory entries must load.');
  check(places.map((p) => p.id).toSet().length == places.length,
      'Place IDs must be unique.');
  check(places.every((p) => destinations.any((d) => d.id == p.cityId)),
      'Places need a known city.');
  check(
      places
          .where((p) => p.cityId == 'hyderabad')
          .map((p) => p.kind)
          .toSet()
          .containsAll(placeKinds.keys),
      'Hyderabad demonstrates every directory category.');
  check(
      destinations.every((d) => ['hotel', 'restaurant'].every(
          (kind) => places.any((p) => p.cityId == d.id && p.kind == kind))),
      'Every city needs a sourced stay and dining example.');
  final legacy = Map<String, dynamic>.from(draft.toJson())
    ..remove('restaurant')
    ..remove('visitMinutes');
  check(
      TripDraft.fromJson(legacy).restaurant.isEmpty &&
          TripDraft.fromJson(legacy).visitMinutes == 0,
      'Old drafts must remain readable.');
  final selected = TripDraft.fromJson(
      {...draft.toJson(), 'restaurant': 'Sample cafe', 'visitMinutes': 240});
  check(selected.restaurant == 'Sample cafe' && selected.visitMinutes == 240,
      'Food and custom duration must restore.');
  final outing = buildDayPlan(
      arrivalMinutes: 420,
      origin: 'Station',
      hotel: 'Hotel',
      attraction: 'Park',
      restMinutes: 0,
      travelMinutes: 30,
      visitMinutesOverride: 240,
      mealPlace: 'Sample cafe');
  check(
      outing.firstWhere((s) => s.title == 'Explore Park').durationMinutes ==
          240,
      'Longer outings must use the selected duration.');
  check(
      outing
          .firstWhere((s) => s.title == 'Meal & a break')
          .note
          .contains('Sample cafe'),
      'The selected restaurant must appear in the plan.');
  check(
      outing
              .firstWhere((s) => s.title == 'Travel to your meal stop')
              .destination ==
          'Sample cafe',
      'A selected restaurant needs its own transfer.');
  check(outing.last.origin == 'Sample cafe',
      'The return route must start at the meal stop.');
  for (var i = 1; i < outing.length; i++) {
    check(
        outing[i].startMinutes ==
            outing[i - 1].startMinutes + outing[i - 1].durationMinutes,
        'Meal transfers must keep the schedule contiguous.');
  }
  final withCheckIn = buildDayPlan(
      arrivalMinutes: 540,
      origin: 'Station',
      hotel: 'Hotel',
      attraction: 'Fort',
      restMinutes: 60,
      travelMinutes: 60,
      hotelReadyMinutes: 840);
  check(withCheckIn.any((stop) => stop.title == 'Time before room access'),
      'Early hotel arrivals need a waiting slot.');
  check(
      withCheckIn
              .firstWhere((stop) => stop.title == 'Rest & refresh')
              .startMinutes >=
          840,
      'Rest must wait for confirmed room access.');
  check(withCheckIn.last.timeRange == '19:00 - 20:00',
      'Waiting must shift the remainder of the plan.');
  final plan = buildDayPlan(
      arrivalMinutes: 540,
      origin: 'Airport',
      hotel: 'My hotel',
      attraction: 'Palolem Beach',
      restMinutes: 60,
      travelMinutes: 60);
  check(plan.length == 8, 'All eight arrival-day steps must be present.');
  check(plan.first.timeRange == '09:00 - 09:30',
      'Arrival starts at the selected time.');
  check(plan.last.startMinutes + plan.last.durationMinutes == 990,
      'The plan ends at 16:30.');
  for (var index = 1; index < plan.length; index++) {
    check(
        plan[index].startMinutes ==
            plan[index - 1].startMinutes + plan[index - 1].durationMinutes,
        'The timetable must have no overlapping steps.');
  }
  final noRest = buildDayPlan(
      arrivalMinutes: 540,
      origin: 'Station',
      hotel: 'Hotel',
      attraction: 'Fort',
      restMinutes: 0,
      travelMinutes: 30);
  check(noRest.length == 7, 'Zero rest does not create a zero-length step.');
  var rejected = 0;
  for (final arrival in [-1, 1400, 1440]) {
    try {
      buildDayPlan(
          arrivalMinutes: arrival,
          origin: 'Station',
          hotel: 'Hotel',
          attraction: 'Fort',
          restMinutes: 60,
          travelMinutes: 60);
    } on ArgumentError {
      rejected++;
    }
  }
  check(rejected == 3, 'Invalid or overnight plans must be rejected.');
  var blankRejected = false;
  try {
    buildDayPlan(
        arrivalMinutes: 540,
        origin: ' ',
        hotel: 'Hotel',
        attraction: 'Fort',
        restMinutes: 60,
        travelMinutes: 60);
  } on ArgumentError {
    blankRejected = true;
  }
  check(blankRejected, 'Blank arrival points must be rejected.');
  final route =
      directions(origin: 'A & B', destination: 'Café, Paris', mode: 'transit');
  check(route.queryParameters['origin'] == 'A & B',
      'URL encoding must preserve origin text.');
  check(route.queryParameters['destination'] == 'Café, Paris',
      'URL encoding must preserve accents.');
  check(route.queryParameters['api'] == '1', 'Maps URLs require api=1.');
  check(!directions(destination: 'Goa').queryParameters.containsKey('origin'),
      'Blank origin lets the traveller choose a starting point in Maps.');
  check(
      hotelSearch('Eiffel Tower', 'Paris, France', 'Budget')
              .queryParameters['query'] ==
          'Budget hotels near Eiffel Tower, Paris, France',
      'Hotel searches must include the attraction and city.');
  check(
      destinations.map((place) => place.id).toSet().length ==
          destinations.length,
      'Destination IDs must be unique.');
  check(destinations.map((place) => place.country).toSet().length == 3,
      'The catalog includes India, France, and Italy.');
  check(destinations.every((place) => place.attractions.length >= 2),
      'Every destination needs two or more attractions.');
  print(
      'Core checks passed: day-plan arithmetic and validation, URL encoding, and destination integrity.');
}
