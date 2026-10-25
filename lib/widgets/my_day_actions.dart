import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../state/travel_controller.dart';
import '../screens/my_day_screen.dart';

/// Every browsing screen reads the same controller, so the count stays in sync.
class MyDayActions extends StatelessWidget {
  const MyDayActions({
    super.key,
    required this.destination,
    required this.controller,
    this.name,
    this.placeId,
    this.kind = 'outing',
    this.showReview = true,
  });
  final Destination destination;
  final TravelController controller;
  final String? name;
  final String? placeId;
  final String kind;
  final bool showReview;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final day = controller.myDayFor(destination.id);
      final selected =
          name != null &&
          (kind == 'hotel'
              ? day.hotel == name
              : kind == 'restaurant'
              ? day.restaurant == name
              : day.stops.any((p) => p.toLowerCase() == name!.toLowerCase()));
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (name != null)
            FilledButton.tonalIcon(
              icon: Icon(selected ? Icons.check_circle_outline : Icons.add),
              label: Text(selected ? 'Added to my day' : 'Add to my day'),
              onPressed: () async {
                final ok = await controller.addToMyDay(
                  destination.id,
                  name!,
                  kind: kind,
                  placeId: placeId,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? (selected
                                  ? 'Already in My day'
                                  : 'Added to my day')
                            : 'Could not add this pick. Choose up to five outings and check device storage.',
                      ),
                    ),
                  );
              },
            ),
          if (showReview)
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyDayScreen(
                    destination: destination,
                    controller: controller,
                  ),
                ),
              ),
              icon: const Icon(Icons.playlist_add_check),
              label: Text('My day (${day.count})'),
            ),
        ],
      );
    },
  );
}
