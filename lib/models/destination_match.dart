import 'destination.dart';

enum TripBudget {
  budget('Budget'),
  midRange('Mid-range'),
  premium('Premium');

  const TripBudget(this.label);
  final String label;
}

/// Editorial planning tags, not a price feed or a promise of affordability.
class DestinationMatchProfile {
  const DestinationMatchProfile({
    required this.budgets,
    required this.minDays,
    required this.maxDays,
  });

  final Set<TripBudget> budgets;
  final int minDays;
  final int maxDays;

  String get durationLabel => '$minDays–$maxDays days';
}

class MatchPreferences {
  const MatchPreferences({this.travelType, this.budget, this.days});

  final String? travelType;
  final TripBudget? budget;
  final int? days;

  int get count =>
      (travelType == null ? 0 : 1) +
      (budget == null ? 0 : 1) +
      (days == null ? 0 : 1);
}

class DestinationMatch {
  const DestinationMatch({
    required this.destination,
    required this.profile,
    required this.reasons,
    required this.differences,
    required this.preferenceCount,
  });

  final Destination destination;
  final DestinationMatchProfile? profile;
  final List<String> reasons;
  final List<String> differences;
  final int preferenceCount;

  int get score => reasons.length;
  bool get isExact => score == preferenceCount;
}

/// One point per matching preference. Stable alphabetical ties are easy to explain.
/// Returns all ranked candidates; the screen shows up to three exact matches,
/// or clearly labelled closest options if no candidate matches every choice.
List<DestinationMatch> matchDestinations(
  List<Destination> destinations,
  Map<String, DestinationMatchProfile> profiles,
  MatchPreferences preferences,
) {
  final days = preferences.days;
  if (days != null && (days < 1 || days > 7)) {
    throw RangeError.range(days, 1, 7, 'days');
  }
  if (preferences.count == 0) return const [];

  final matches = destinations.map((destination) {
    final profile = profiles[destination.id];
    final reasons = <String>[];
    final differences = <String>[];
    if (preferences.travelType != null) {
      if (destination.category == preferences.travelType) {
        reasons.add('${destination.category} travel type');
      } else {
        differences.add('Travel type: ${destination.category}');
      }
    }
    if (preferences.budget != null) {
      if (profile?.budgets.contains(preferences.budget) ?? false) {
        reasons.add('${preferences.budget!.label} sample budget style');
      } else {
        differences.add(
          profile == null
              ? 'No sample budget guide available'
              : 'Sample budget styles: ${profile.budgets.map((b) => b.label).join(', ')}',
        );
      }
    }
    if (days != null) {
      if (profile != null &&
          days >= profile.minDays &&
          days <= profile.maxDays) {
        reasons.add('$days-day trip fits the sample visit length');
      } else {
        differences.add(
          profile == null
              ? 'No sample visit length available'
              : 'Sample visit length: ${profile.durationLabel}',
        );
      }
    }
    return DestinationMatch(
      destination: destination,
      profile: profile,
      reasons: List.unmodifiable(reasons),
      differences: List.unmodifiable(differences),
      preferenceCount: preferences.count,
    );
  }).toList();
  matches.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byName = a.destination.name.compareTo(b.destination.name);
    return byName != 0 ? byName : a.destination.id.compareTo(b.destination.id);
  });
  return List.unmodifiable(matches);
}
