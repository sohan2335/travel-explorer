import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/place_catalog.dart';

class PickedVenue {
  const PickedVenue(this.id, this.name, this.detail);
  final String id, name, detail;
}

Future<PickedVenue?> pickCityVenue(BuildContext context, Destination city) =>
    showModalBottomSheet<PickedVenue>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (_) => _CityVenuePicker(city: city));

class _CityVenuePicker extends StatefulWidget {
  const _CityVenuePicker({required this.city});
  final Destination city;
  @override
  State<_CityVenuePicker> createState() => _CityVenuePickerState();
}

class _CityVenuePickerState extends State<_CityVenuePicker> {
  late final _catalog = PlaceCatalog.load();
  String _query = '';
  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 0, 20, MediaQuery.viewInsetsOf(context).bottom + 16),
          child: SizedBox(
              height: math.min(
                  MediaQuery.sizeOf(context).height * .65,
                  math.max(
                      0,
                      constraints.maxHeight -
                          MediaQuery.viewInsetsOf(context).bottom -
                          16)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Places in ${widget.city.name}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                        autofocus: true,
                        onChanged: (s) =>
                            setState(() => _query = s.trim().toLowerCase()),
                        decoration: const InputDecoration(
                            labelText: 'Search places in this city',
                            prefixIcon: Icon(Icons.search))),
                    const SizedBox(height: 12),
                    Expanded(
                        child: FutureBuilder<CatalogResult>(
                            future: _catalog,
                            builder: (context, snapshot) {
                              final items = <PickedVenue>[
                                for (final sight in widget.city.attractions)
                                  PickedVenue(
                                      '${widget.city.id}:sight:${sight.name}',
                                      sight.name,
                                      'City guide'),
                                for (final place in snapshot.data?.places ?? [])
                                  if (place.cityId == widget.city.id &&
                                      place.kind != 'hotel')
                                    PickedVenue(
                                        place.id, place.name, place.area),
                              ];
                              final visible = items
                                  .where((p) => '${p.name} ${p.detail}'
                                      .toLowerCase()
                                      .contains(_query))
                                  .toList();
                              return ListView(children: [
                                if (snapshot.connectionState !=
                                    ConnectionState.done)
                                  const LinearProgressIndicator(),
                                if (snapshot.hasError)
                                  const Text(
                                      'The directory is unavailable. City guide places are still listed.'),
                                if (visible.isEmpty)
                                  const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                          'No matching places. Try another name, or add a custom stop from My day.')),
                                for (final place in visible)
                                  ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.place_outlined),
                                      title: Text(place.name),
                                      subtitle: Text(place.detail),
                                      trailing:
                                          const Icon(Icons.add_circle_outline),
                                      onTap: () =>
                                          Navigator.pop(context, place)),
                              ]);
                            })),
                    const Text(
                        'Check each location and route in Maps. Coordinates and opening hours are not supplied for these listings.',
                        style: TextStyle(fontSize: 12)),
                  ]))));
}
