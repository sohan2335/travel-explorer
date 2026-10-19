import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/travel_links.dart';
import 'travel_link_button.dart';

/// A few search/direction links, rather than a booking system or live API.
class TravelTools extends StatefulWidget {
  const TravelTools({super.key, required this.destination, this.initialPlace});
  final Destination destination;
  final String? initialPlace;

  @override
  State<TravelTools> createState() => _TravelToolsState();
}

class _TravelToolsState extends State<TravelTools> {
  late String _place;
  String _stayStyle = 'Budget';
  String _mode = 'transit';
  final _origin = TextEditingController();

  @override
  void initState() {
    super.initState();
    _place = widget.initialPlace ?? widget.destination.attractions.first.name;
  }

  @override
  void dispose() {
    _origin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = '${widget.destination.name}, ${widget.destination.country}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Stay nearby & get around',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _place,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Near which attraction?'),
        items: widget.destination.attractions
            .map((place) =>
                DropdownMenuItem(value: place.name, child: Text(place.name)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _place = value);
        },
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _stayStyle,
        decoration: const InputDecoration(labelText: 'Hotel search preference'),
        items: const ['Budget', 'Comfort', 'Family-friendly']
            .map((style) => DropdownMenuItem(value: style, child: Text(style)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _stayStyle = value);
        },
      ),
      const SizedBox(height: 8),
      TravelLinkButton(
          label: 'Find nearby hotels',
          icon: Icons.hotel_outlined,
          url: hotelSearch(_place, city, _stayStyle)),
      const Text(
          'Opens hotel search results. Check reviews, location, check-in time, prices and availability with the property.'),
      const SizedBox(height: 20),
      TextField(
          controller: _origin,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
              labelText: 'Starting point (optional)',
              hintText: 'Your hotel or arrival station')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        initialValue: _mode,
        isExpanded: true,
        decoration:
            const InputDecoration(labelText: 'How would you like to travel?'),
        items: transportModes.entries
            .map((entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _mode = value);
        },
      ),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 4, children: [
        TravelLinkButton(
            label: 'Get directions',
            icon: Icons.directions_outlined,
            url: directions(
                destination: '$_place, $city',
                origin: _origin.text.trim().isEmpty
                    ? ''
                    : '${_origin.text.trim()}, $city',
                mode: _mode)),
        if (_mode == 'driving')
          TravelLinkButton(
              label: 'Open Uber', url: Uri.parse('https://m.uber.com/')),
        if (_mode == 'bicycling')
          TravelLinkButton(
              label: 'Find bicycle rentals',
              url: mapSearch('bicycle rental near $_place, $city')),
      ]),
      const Text(
          'Maps provides routes where supported. Compare current fares yourself; this app does not claim a cheapest fare. Cab and bicycle availability varies by city.'),
    ]);
  }
}
