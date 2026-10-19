import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/models/day_plan.dart';
import 'package:travel_explorer/services/travel_links.dart';

void main() {
  test('rest waits until the confirmed hotel access time', () {
    final plan = buildDayPlan(
        arrivalMinutes: 540,
        origin: 'Station',
        hotel: 'Hotel',
        attraction: 'Fort',
        restMinutes: 60,
        travelMinutes: 60,
        hotelReadyMinutes: 840);
    expect(
        plan.firstWhere((stop) => stop.title == 'Rest & refresh').startMinutes,
        greaterThanOrEqualTo(840));
    expect(plan.last.timeRange, '19:00 - 20:00');
  });
  test('arrival plan is contiguous and has three travel legs', () {
    final plan = buildDayPlan(
        arrivalMinutes: 540,
        origin: 'Airport',
        hotel: 'Hotel',
        attraction: 'Fort',
        restMinutes: 60,
        travelMinutes: 60);
    expect(plan, hasLength(8));
    expect(plan.where((stop) => stop.destination != null), hasLength(3));
    for (var index = 1; index < plan.length; index++) {
      expect(plan[index].startMinutes,
          plan[index - 1].startMinutes + plan[index - 1].durationMinutes);
    }
    expect(plan.last.timeRange, '15:30 - 16:30');
  });
  test('late arrivals are rejected rather than silently rolling into tomorrow',
      () {
    expect(
        () => buildDayPlan(
            arrivalMinutes: 1380,
            origin: 'Airport',
            hotel: 'Hotel',
            attraction: 'Fort',
            restMinutes: 60,
            travelMinutes: 60),
        throwsArgumentError);
  });
  test('maps query safely encodes traveller-entered place names', () {
    final url = directions(
        origin: 'A & B', destination: 'Café, Paris', mode: 'walking');
    expect(url.queryParameters['origin'], 'A & B');
    expect(url.queryParameters['destination'], 'Café, Paris');
    expect(url.queryParameters['travelmode'], 'walking');
  });
}
