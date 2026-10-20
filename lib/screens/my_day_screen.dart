import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../experience/experience_controller.dart';
import '../state/travel_controller.dart';
import 'day_planner_screen.dart';
import '../widgets/city_venue_picker.dart';
import '../widgets/travel_link_button.dart';
import '../services/travel_links.dart';

class MyDayScreen extends StatefulWidget {
  const MyDayScreen(
      {super.key, required this.destination, required this.controller});
  final Destination destination;
  final TravelController controller;
  @override
  State<MyDayScreen> createState() => _MyDayScreenState();
}

class _MyDayScreenState extends State<MyDayScreen> {
  final _custom = TextEditingController();
  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _notice(bool ok) {
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Could not save this change. Use up to five outings and check device storage.')));
  }

  void _showInfo() => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About My day',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    const Text(
                        'Your picks save on this device. Choose up to five outings, one stay and one meal. Review timing before saving a trip draft. A selected meal comes after your outings. Replacing a stay or meal changes only that role. Check real routes, venue hours and event times yourself. Custom stop locations are unverified.'),
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it')),
                  ]))));
  Future<void> _addCustomStop() async {
    _custom.clear();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Add a custom stop'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                      'This location is not verified. Check it in Maps before planning.'),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _custom,
                      maxLength: 500,
                      decoration:
                          const InputDecoration(labelText: 'Custom stop name'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Add to my day'))
                ]));
    if (accepted == true && _custom.text.trim().isNotEmpty && mounted) {
      _notice(await widget.controller
          .addToMyDay(widget.destination.id, _custom.text));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final day = widget.controller.myDayFor(widget.destination.id);
        final preference = ExperienceScope.maybeOf(context)?.controller;
        return Scaffold(
          appBar: AppBar(
              title: Text('My day in ${widget.destination.name}'),
              actions: [
                IconButton(
                    tooltip: 'About My day',
                    icon: const Icon(Icons.info_outline),
                    onPressed: _showInfo)
              ]),
          bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FilledButton.icon(
                      onPressed: day.stops.isEmpty
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DayPlannerScreen(
                                      destination: widget.destination,
                                      controller: widget.controller,
                                      initialStops: day.stops,
                                      initialHotel:
                                          day.hotel.isEmpty ? null : day.hotel,
                                      initialRestaurant: day.restaurant.isEmpty
                                          ? null
                                          : day.restaurant))),
                      icon: const Icon(Icons.route),
                      label: const Text('Plan my day')))),
          body: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    Text('Your picks, in one place.',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    const Text('Order your stops, then check timing.'),
                    if (preference?.tripStyle != null)
                      Padding(padding: const EdgeInsets.only(top: 16), child: Card(child: Padding(
                        padding: const EdgeInsets.all(16), child: Text(
                          '${preference!.tripStyle} suggestion: about ${preference.suggestedStops} stops, ${preference.suggestedMinutes} minutes per visit. Change pace or duration in the planner. Saved plans keep their settings.')))),
                    const SizedBox(height: 20),
                    if (day.hotel.isNotEmpty)
                      Card(
                          child: ListTile(
                              leading: const Icon(Icons.bed_outlined),
                              title: Text(day.hotel),
                              subtitle: const Text('Selected stay'),
                              trailing: IconButton(
                                  tooltip: 'Remove selected stay',
                                  icon: const Icon(Icons.close),
                                  onPressed: () async => _notice(
                                      await widget.controller.removeFromMyDay(
                                          widget.destination.id, day.hotel,
                                          kind: 'hotel'))))),
                    if (day.restaurant.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Card(
                              child: ListTile(
                                  leading: const Icon(Icons.restaurant),
                                  title: Text(day.restaurant),
                                  subtitle: const Text('Selected meal stop'),
                                  trailing: IconButton(
                                      tooltip: 'Remove selected meal',
                                      icon: const Icon(Icons.close),
                                      onPressed: () async => _notice(
                                          await widget.controller
                                              .removeFromMyDay(
                                                  widget.destination.id,
                                                  day.restaurant,
                                                  kind: 'restaurant')))))),
                    const SizedBox(height: 20),
                    Text('Outings (${day.stops.length}/5)',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    if (day.stops.isEmpty)
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                  'Add a sight, mall, park or event venue from a city guide, or enter a place below. Add at least one outing to open the planner.'))),
                    for (var index = 0; index < day.stops.length; index++)
                      Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                              child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${index + 1}. ${day.stops[index]}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 8),
                                        Text(
                                            day.placeIds.containsKey(
                                                    day.stops[index])
                                                ? 'City guide or directory pick'
                                                : 'Custom stop · location not verified',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        const SizedBox(height: 8),
                                        TravelLinkButton(
                                            label: 'Open in Maps',
                                            icon: Icons.map_outlined,
                                            url: mapSearch(
                                                '${day.stops[index]}, ${widget.destination.name}, ${widget.destination.country}')),
                                        if (index > 0)
                                          TravelLinkButton(
                                              label:
                                                  'Check route from previous stop',
                                              icon: Icons.directions_outlined,
                                              url: directions(
                                                  origin:
                                                      '${day.stops[index - 1]}, ${widget.destination.name}, ${widget.destination.country}',
                                                  destination:
                                                      '${day.stops[index]}, ${widget.destination.name}, ${widget.destination.country}',
                                                  mode: 'driving')),
                                        Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              TextButton.icon(
                                                  onPressed: index == 0
                                                      ? null
                                                      : () async => _notice(
                                                          await widget
                                                              .controller
                                                              .moveDayStop(
                                                                  widget
                                                                      .destination
                                                                      .id,
                                                                  index,
                                                                  -1)),
                                                  icon: const Icon(
                                                      Icons.arrow_upward,
                                                      size: 18),
                                                  label: const Text('Earlier')),
                                              TextButton.icon(
                                                  onPressed: index ==
                                                          day.stops.length - 1
                                                      ? null
                                                      : () async => _notice(
                                                          await widget
                                                              .controller
                                                              .moveDayStop(
                                                                  widget
                                                                      .destination
                                                                      .id,
                                                                  index,
                                                                  1)),
                                                  icon: const Icon(
                                                      Icons.arrow_downward,
                                                      size: 18),
                                                  label: const Text('Later')),
                                              TextButton.icon(
                                                  onPressed: () async =>
                                                      _notice(await widget
                                                          .controller
                                                          .removeFromMyDay(
                                                              widget.destination
                                                                  .id,
                                                              day.stops[
                                                                  index])),
                                                  icon: const Icon(Icons.close,
                                                      size: 18),
                                                  label: const Text('Remove')),
                                            ]),
                                      ])))),
                    const SizedBox(height: 12),
                    if (day.stops.length >= 5)
                      const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                              'Limit reached. Remove a stop to add another.')),
                    OutlinedButton.icon(
                        onPressed: day.stops.length >= 5
                            ? null
                            : () async {
                                final picked = await pickCityVenue(
                                    context, widget.destination);
                                if (picked == null || !mounted) return;
                                _notice(await widget.controller.addToMyDay(
                                    widget.destination.id, picked.name,
                                    placeId: picked.id));
                              },
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Add to my day')),
                    TextButton(
                        onPressed:
                            day.stops.length >= 5 ? null : _addCustomStop,
                        child: const Text("Can't find it? Add a custom stop")),
                    const SizedBox(height: 20),
                    if (widget.controller.storageMessage != null)
                      Text(widget.controller.storageMessage!),
                  ]))),
        );
      });
}
