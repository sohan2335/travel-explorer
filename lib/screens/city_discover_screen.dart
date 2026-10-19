import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/local_place.dart';
import '../services/place_catalog.dart';
import '../services/travel_links.dart';
import '../state/travel_controller.dart';
import '../widgets/destination_image.dart';
import '../widgets/discovery_shortcuts.dart';
import '../widgets/travel_link_button.dart';
import 'day_planner_screen.dart';
import 'explorer_screen.dart';

class CityDiscoverScreen extends StatefulWidget {
  const CityDiscoverScreen(
      {super.key,
      required this.destination,
      required this.controller,
      this.initialKind = 'hotel'});
  final Destination destination;
  final TravelController controller;
  final String initialKind;
  @override
  State<CityDiscoverScreen> createState() => _CityDiscoverScreenState();
}

class _CityDiscoverScreenState extends State<CityDiscoverScreen> {
  late Destination _city;
  late String _kind;
  String _search = '';
  late Future<CatalogResult> _catalog;
  @override
  void initState() {
    super.initState();
    _city = widget.destination;
    _kind = widget.initialKind;
    _catalog = PlaceCatalog.load();
  }

  void _plan({LocalPlace? place}) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => DayPlannerScreen(
                destination: _city,
                initialVisitMinutes: place != null &&
                        ['adventure', 'waterpark'].contains(place.kind)
                    ? 240
                    : null,
                controller: widget.controller,
                initialHotel: place?.kind == 'hotel' ? place!.name : null,
                initialRestaurant:
                    place?.kind == 'restaurant' ? place!.name : null,
                initialAttraction: place != null &&
                        !['hotel', 'restaurant'].contains(place.kind)
                    ? place.name
                    : null,
              )));
  String get _query => switch (_kind) {
        'hotel' => 'hotels',
        'restaurant' => 'restaurants',
        'adventure' => 'adventure parks',
        'waterpark' => 'water parks',
        'event' => 'events',
        _ => 'shopping malls',
      };
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            leading: IconButton(
                tooltip: 'Close city',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context)),
            title: Text('Discover ${_city.name}')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: SizedBox(
                            height: 235,
                            child: Stack(fit: StackFit.expand, children: [
                              DestinationImage(
                                  url: _city.imageUrl, label: _city.name),
                              const DecoratedBox(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                    Colors.transparent,
                                    Color(0xF20E0E10)
                                  ]))),
                              Positioned(
                                  left: 22,
                                  right: 22,
                                  bottom: 20,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('MAKE A DAY OF IT',
                                            style: TextStyle(
                                                color: Color(0xFFDAC8FF),
                                                letterSpacing: 2,
                                                fontSize: 11)),
                                        Text(_city.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 38,
                                                fontWeight: FontWeight.bold)),
                                        const Text(
                                            'Stay somewhere. Taste something. Try a little adventure.',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ])),
                            ]))),
                    TextButton.icon(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DestinationDetails(
                                    destination: _city,
                                    controller: widget.controller))),
                        icon: const Icon(Icons.landscape_outlined),
                        label: const Text('Sights & city guide')),
                    const SizedBox(height: 22),
                    DiscoveryShortcuts(
                        selected: _kind,
                        onSelected: (kind) {
                          if (kind == 'plan') {
                            _plan();
                          } else {
                            setState(() => _kind = kind);
                          }
                        }),
                    const SizedBox(height: 22),
                    Text('${discoveryLabels[_kind]} in ${_city.name}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    TextField(
                        onChanged: (value) => setState(
                            () => _search = value.trim().toLowerCase()),
                        decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search ${_city.name} venues')),
                    const SizedBox(height: 12),
                    TravelLinkButton(
                        label: 'Explore $_query across ${_city.name}',
                        icon: Icons.map_outlined,
                        url: _kind == 'event'
                            ? Uri.https('www.google.com', '/search', {
                                'q':
                                    'upcoming events in ${_city.name} ${_city.country}'
                              })
                            : mapSearch(
                                '$_query in ${_city.name}, ${_city.country}')),
                    const SizedBox(height: 8),
                    Text(_kind == 'event'
                        ? 'Find current events with organisers. Dates and tickets are confirmed on their websites.'
                        : 'Citywide picks. Check opening hours, prices and availability with the venue.'),
                    const SizedBox(height: 20),
                    FutureBuilder<CatalogResult>(
                        future: _catalog,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            if (snapshot.hasError)
                              return const Text(
                                  'The directory could not load. Use the nearby map search above.');
                            return const Padding(
                                padding: EdgeInsets.all(24),
                                child:
                                    Center(child: CircularProgressIndicator()));
                          }
                          final result = snapshot.data!;
                          final places = result.places
                              .where((p) =>
                                  p.cityId == _city.id &&
                                  p.kind == _kind &&
                                  '${p.name} ${p.area}'
                                      .toLowerCase()
                                      .contains(_search))
                              .toList();
                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(
                                      result.fromCloud
                                          ? Icons.cloud_done_outlined
                                          : Icons.offline_pin_outlined,
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(result.fromCloud
                                          ? 'Cloud directory · Neon'
                                          : 'Bundled directory · cloud unavailable')),
                                  IconButton(
                                      tooltip: 'Refresh directory',
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () => setState(() => _catalog =
                                          PlaceCatalog.load(refresh: true))),
                                ]),
                                if (places.isEmpty)
                                  Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      margin: const EdgeInsets.only(top: 12),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(22)),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(discoveryIcons[_kind],
                                                color: discoveryColors[_kind],
                                                size: 34),
                                            const SizedBox(height: 12),
                                            const Text('No matching picks yet.',
                                                style: TextStyle(
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 6),
                                            Text(
                                                'We have not curated $_query for ${_city.name} yet. Use the citywide search above to explore more listings.'),
                                          ])),
                                for (final place in places)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: _placeCard(place)),
                              ]);
                        }),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                        onPressed: () => _plan(),
                        icon: const Icon(Icons.route),
                        label: Text('Plan my day in ${_city.name}')),
                    const SizedBox(height: 12),
                    const Text(
                        'Keep your first plan to one main outing. A park visit can take most of a day; avoid squeezing far-apart places into short transfer buffers.'),
                  ]),
            ))),
      );
  Widget _placeCard(LocalPlace place) => Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              discoveryColors[_kind]!.withValues(alpha: .23),
              const Color(0xFF202024)
            ])),
            child: Row(children: [
              Icon(discoveryIcons[_kind],
                  size: 46, color: discoveryColors[_kind]),
              const SizedBox(width: 18),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(discoveryLabels[_kind]!,
                        style: TextStyle(
                            color: discoveryColors[_kind],
                            letterSpacing: 1.5,
                            fontSize: 11)),
                    const SizedBox(height: 5),
                    Text(place.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(place.area),
                  ]))
            ])),
        Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(place.description),
              const SizedBox(height: 10),
              Text('Source checked ${place.checkedOn} · availability not live',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                TravelLinkButton(
                    label: 'Official details', url: Uri.parse(place.sourceUrl)),
                TravelLinkButton(
                    label: 'Find venue on Maps',
                    icon: Icons.location_on_outlined,
                    url: mapSearch(
                        '${place.name}, ${place.area}, ${_city.name}, ${_city.country}')),
                FilledButton.tonalIcon(
                    onPressed: () => _plan(place: place),
                    icon: const Icon(Icons.add),
                    label: Text(_kind == 'hotel'
                        ? 'Use this stay'
                        : _kind == 'restaurant'
                            ? 'Use for my meal'
                            : 'Make this my main outing')),
              ]),
            ])),
      ]));
}
