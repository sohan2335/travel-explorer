import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/place_catalog.dart';
import '../state/travel_controller.dart';
import '../widgets/discovery_shortcuts.dart';
import '../widgets/my_day_actions.dart';
import '../widgets/travel_link_button.dart';

/// Deterministic matching of real directory categories, not an AI recommendation.
class InterestVenues extends StatefulWidget {
  const InterestVenues({
    super.key,
    required this.city,
    required this.interests,
    required this.travel,
  });
  final Destination city;
  final Set<String> interests;
  final TravelController travel;
  @override
  State<InterestVenues> createState() => _InterestVenuesState();
}

class _InterestVenuesState extends State<InterestVenues> {
  late final _catalog = PlaceCatalog.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<CatalogResult>(
    future: _catalog,
    builder: (context, snapshot) {
      final matches =
          snapshot.data?.places
              .where(
                (p) =>
                    p.cityId == widget.city.id &&
                    widget.interests.contains(p.kind),
              )
              .take(3)
              .toList() ??
          [];
      if (matches.length < 2) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your interests',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'From the ${widget.city.name} directory. Check details with the venue.',
            ),
            const SizedBox(height: 16),
            for (final place in matches)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              discoveryIcons[place.kind],
                              color: discoveryColors[place.kind],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                place.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(place.area),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TravelLinkButton(
                              label: 'View source',
                              icon: Icons.open_in_new,
                              url: Uri.parse(place.sourceUrl),
                            ),
                            MyDayActions(
                              destination: widget.city,
                              controller: widget.travel,
                              name: place.name,
                              placeId: place.id,
                              kind: ['hotel', 'restaurant'].contains(place.kind)
                                  ? place.kind
                                  : 'outing',
                              showReview: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
