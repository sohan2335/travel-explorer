import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/travel_links.dart';
import '../widgets/destination_image.dart';
import '../widgets/travel_link_button.dart';

Future<void> showPlaceInformation(BuildContext context, Destination destination,
    {Attraction? attraction}) {
  final name = attraction?.name ?? destination.name;
  final description = attraction == null
      ? destination.description
      : attraction.description.isEmpty
          ? 'Explore $name in ${destination.name}. Use the background and map links below to learn about the place and its surroundings.'
          : attraction.description;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  tooltip: 'Close place information',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close))),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          Text('${destination.name}, ${destination.country}'),
          const SizedBox(height: 16),
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                  height: 200,
                  child: DestinationImage(
                      url: attraction?.imageUrl ?? destination.imageUrl,
                      label: name))),
          const SizedBox(height: 20),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 16),
          Wrap(spacing: 8, children: [
            TravelLinkButton(
                label: 'Read about this place',
                icon: Icons.menu_book_outlined,
                url: placeInformation(
                    name, '${destination.name}, ${destination.country}')),
            TravelLinkButton(
                label: 'View surroundings',
                icon: Icons.map_outlined,
                url: mapSearch(
                    '$name, ${destination.name}, ${destination.country}')),
            TravelLinkButton(
                label: 'Hotels near this place',
                icon: Icons.hotel_outlined,
                url: hotelSearch(
                    name, '${destination.name}, ${destination.country}', '')),
          ]),
          const SizedBox(height: 20),
          Text('Other places in ${destination.name}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final other in destination.attractions
              .where((item) => item.name != attraction?.name))
            ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined),
                title: Text(other.name),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => showPlaceInformation(context, destination,
                    attraction: other)),
          const SizedBox(height: 16),
          Text('Content: ${destination.source}',
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    ),
  );
}
