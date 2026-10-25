import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/data/destination_match_profiles.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/models/destination_match.dart';

void main() {
  List<DestinationMatch> match(MatchPreferences preferences) =>
      matchDestinations(destinations, destinationMatchProfiles, preferences);

  test('every city has a valid, explicitly sampled planning profile', () {
    expect(
      destinationMatchProfiles.keys.toSet(),
      destinations.map((d) => d.id).toSet(),
    );
    for (final profile in destinationMatchProfiles.values) {
      expect(profile.budgets, isNotEmpty);
      expect(profile.minDays, inInclusiveRange(1, 7));
      expect(profile.maxDays, inInclusiveRange(profile.minDays, 7));
    }
  });

  test('no choices means no invented recommendation', () {
    expect(match(const MatchPreferences()), isEmpty);
    expect(
      matchDestinations(
        const [],
        destinationMatchProfiles,
        const MatchPreferences(days: 2),
      ),
      isEmpty,
    );
  });

  test('three preferences rank exact matches before partial matches', () {
    final results = match(
      const MatchPreferences(
        travelType: 'Mountains',
        budget: TripBudget.budget,
        days: 4,
      ),
    );
    expect(results.first.destination.id, 'manali');
    expect(results.first.score, 3);
    expect(results.first.isExact, isTrue);
    expect(results.first.reasons, hasLength(3));
    expect(results.first.differences, isEmpty);
    final munnar = results.firstWhere((r) => r.destination.id == 'munnar');
    expect(munnar.score, 2);
    expect(munnar.differences.single, contains('Mid-range, Premium'));
  });

  test('category-only matches are alphabetical and repeatable', () {
    final preferences = const MatchPreferences(travelType: 'Beaches');
    final first = match(preferences);
    expect(first.where((r) => r.isExact).map((r) => r.destination.id), [
      'goa',
      'varkala',
    ]);
    expect(
      first.map((r) => r.destination.id),
      match(preferences).map((r) => r.destination.id),
    );
  });

  test('budget alone and duration alone can each drive suggestions', () {
    final budgetMatches = match(
      const MatchPreferences(budget: TripBudget.budget),
    ).where((r) => r.isExact);
    expect(budgetMatches.map((r) => r.destination.id), contains('varkala'));
    expect(
      budgetMatches.map((r) => r.destination.id),
      isNot(contains('paris')),
    );
    final dayMatches = match(
      const MatchPreferences(days: 1),
    ).where((r) => r.isExact).map((r) => r.destination.id);
    expect(dayMatches, ['agra', 'hyderabad']);
  });

  test('visit length includes both boundaries', () {
    DestinationMatch goa(int days) => match(
      MatchPreferences(days: days),
    ).firstWhere((r) => r.destination.id == 'goa');
    expect(goa(1).isExact, isFalse);
    expect(goa(2).isExact, isTrue);
    expect(goa(5).isExact, isTrue);
    expect(goa(6).isExact, isFalse);
  });

  test('no exact match keeps honest partial scores and differences', () {
    final results = match(
      const MatchPreferences(
        travelType: 'Beaches',
        budget: TripBudget.budget,
        days: 7,
      ),
    );
    expect(results.any((r) => r.isExact), isFalse);
    expect(results.first.destination.id, 'goa');
    expect(results.first.score, 2);
    expect(results.first.preferenceCount, 3);
    expect(results.first.differences.single, 'Sample visit length: 2–5 days');
  });

  test('missing profiles do not claim budget or duration matches', () {
    final results = matchDestinations(
      destinations.take(1).toList(),
      const {},
      const MatchPreferences(budget: TripBudget.budget, days: 2),
    );
    expect(results.single.score, 0);
    expect(results.single.isExact, isFalse);
    expect(results.single.differences, hasLength(2));
  });

  test('invalid trip lengths are rejected', () {
    expect(() => match(const MatchPreferences(days: 0)), throwsRangeError);
    expect(() => match(const MatchPreferences(days: 8)), throwsRangeError);
  });
}
