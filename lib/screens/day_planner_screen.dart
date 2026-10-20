import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination.dart';
import '../experience/experience_controller.dart';
import '../services/place_catalog.dart';
import '../models/day_plan.dart';
import '../models/trip_draft.dart';
import '../state/travel_controller.dart';
import '../services/travel_links.dart';
import '../widgets/travel_link_button.dart';

class DayPlannerScreen extends StatefulWidget {
  const DayPlannerScreen(
      {super.key,
      required this.destination,
      required this.controller,
      this.initialStops,
      this.initialHotel,
      this.initialAttraction,
      this.initialRestaurant,
      this.initialVisitMinutes});
  final List<String>? initialStops;
  final Destination destination;
  final String? initialHotel, initialAttraction, initialRestaurant;
  final TravelController controller;
  final int? initialVisitMinutes;

  @override
  State<DayPlannerScreen> createState() => _DayPlannerScreenState();
}

class _DayPlannerScreenState extends State<DayPlannerScreen> {
  final _form = GlobalKey<FormState>();
  final _origin = TextEditingController();
  final _hotel = TextEditingController();
  final _restaurant = TextEditingController();
  TimeOfDay _arrival = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _hotelReady = const TimeOfDay(hour: 14, minute: 0);
  int _rest = 60;
  int _travel = 60;
  String _mode = 'transit';
  String _pace = 'Balanced';
  int? _visit;
  late String _attraction;
  List<String> _additionalPlaces = [];
  List<DayPlanStop>? _plan;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _attraction = widget.destination.attractions.first.name;
    final draft = widget.controller.draftFor(widget.destination.id);
    final style = context.getInheritedWidgetOfExactType<ExperienceScope>()?.controller.tripStyle;
    if (draft == null && style != null) {
      _pace = style;
      _rest = restMinutesByPace[style]!;
      _visit = visitMinutesByPace[style];
    }
    if (draft != null) {
      _origin.text = draft.origin;
      _hotel.text = draft.hotel;
      _restaurant.text = draft.restaurant;
      _arrival = TimeOfDay(
          hour: draft.arrivalMinutes ~/ 60, minute: draft.arrivalMinutes % 60);
      _hotelReady = TimeOfDay(
          hour: draft.hotelReadyMinutes ~/ 60,
          minute: draft.hotelReadyMinutes % 60);
      _rest = draft.restMinutes;
      _visit = draft.visitMinutes == 0 ? null : draft.visitMinutes;
      _travel = draft.travelMinutes;
      _mode = draft.mode;
      _pace = draft.pace;
      _attraction = draft.attraction;
      _additionalPlaces = List.of(draft.additionalPlaces);
      if (draft.hasPlan) {
        try {
          _plan = _calculatePlan();
        } on ArgumentError catch (error) {
          _error = error.message.toString();
        }
      }
    }
    if (widget.initialStops != null && widget.initialStops!.isNotEmpty) {
      _attraction = widget.initialStops!.first;
      _additionalPlaces = widget.initialStops!.skip(1).toList();
      _clearPlan();
    }
    if (widget.initialVisitMinutes != null) {
      _visit = widget.initialVisitMinutes;
      _clearPlan();
    }
    if (widget.initialHotel != null) {
      _hotel.text = widget.initialHotel!;
      _clearPlan();
    }
    if (widget.initialAttraction != null) {
      _attraction = widget.initialAttraction!;
      _additionalPlaces
          .removeWhere((p) => p.toLowerCase() == _attraction.toLowerCase());
      _clearPlan();
    }
    if (widget.initialRestaurant != null) {
      _restaurant.text = widget.initialRestaurant!;
      _clearPlan();
    }
  }

  List<DayPlanStop> _calculatePlan() => buildDayPlan(
        arrivalMinutes: _arrival.hour * 60 + _arrival.minute,
        origin: _origin.text.trim(),
        hotel: _hotel.text.trim(),
        attraction: _attraction,
        restMinutes: _rest,
        travelMinutes: _travel,
        hotelReadyMinutes: _hotelReady.hour * 60 + _hotelReady.minute,
        pace: _pace,
        mealPlace: _restaurant.text.trim(),
        visitMinutesOverride: _visit,
        additionalPlaces: _additionalPlaces,
      );

  Future<void> _pickStops() async {
    final catalog = PlaceCatalog.load();
    final selected = List<String>.of(_additionalPlaces);
    final custom = TextEditingController();
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => StatefulBuilder(
            builder: (context, update) => Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
                  child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * .7,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Add stops in ${widget.destination.name}',
                                style: Theme.of(context).textTheme.titleLarge),
                            const Text(
                                'Select up to four extra places. Selected order becomes your route.'),
                            Expanded(
                                child: FutureBuilder<CatalogResult>(
                                    future: catalog,
                                    builder: (context, snapshot) {
                                      final names = <String>{
                                        ...widget.destination.attractions
                                            .map((a) => a.name),
                                        ...?snapshot.data?.places
                                            .where((p) =>
                                                p.cityId ==
                                                    widget.destination.id &&
                                                p.kind != 'hotel')
                                            .map((p) => p.name),
                                        ...selected
                                      }
                                          .where((p) =>
                                              p.toLowerCase() !=
                                              _attraction.toLowerCase())
                                          .toList();
                                      return ListView(children: [
                                        if (snapshot.connectionState !=
                                            ConnectionState.done)
                                          const LinearProgressIndicator(),
                                        for (final name in names)
                                          CheckboxListTile(
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(name),
                                              value: selected.contains(name),
                                              onChanged: selected.length >= 4 &&
                                                      !selected.contains(name)
                                                  ? null
                                                  : (checked) => update(() {
                                                        if (checked == true) {
                                                          selected.add(name);
                                                        } else {
                                                          selected.remove(name);
                                                        }
                                                      })),
                                      ]);
                                    })),
                            Row(children: [
                              Expanded(
                                  child: TextField(
                                      controller: custom,
                                      maxLength: 500,
                                      decoration: const InputDecoration(
                                          labelText:
                                              'Other venue or event location',
                                          counterText: ''))),
                              IconButton(
                                  tooltip: 'Add entered place',
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    final name = custom.text.trim();
                                    if (name.isNotEmpty &&
                                        name.toLowerCase() !=
                                            _attraction.toLowerCase() &&
                                        !selected.any((p) =>
                                            p.toLowerCase() ==
                                            name.toLowerCase()) &&
                                        selected.length < 4) {
                                      update(() {
                                        selected.add(name);
                                        custom.clear();
                                      });
                                    }
                                  })
                            ]),
                            const SizedBox(height: 12),
                            FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _additionalPlaces = selected;
                                    _clearPlan();
                                  });
                                  Navigator.pop(sheetContext);
                                },
                                child:
                                    Text('Use ${selected.length} extra stops')),
                          ])),
                )));
    // Let the sheet finish its closing animation before disposing its text field.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    custom.dispose();
  }

  Future<void> _saveDraft() async {
    setState(() => _saving = true);
    final success = await widget.controller.saveDraft(TripDraft(
      destinationId: widget.destination.id,
      origin: _origin.text.trim(),
      hotel: _hotel.text.trim(),
      restaurant: _restaurant.text.trim(),
      visitMinutes: _visit ?? 0,
      additionalPlaces: List.of(_additionalPlaces),
      arrivalMinutes: _arrival.hour * 60 + _arrival.minute,
      hotelReadyMinutes: _hotelReady.hour * 60 + _hotelReady.minute,
      restMinutes: _rest,
      travelMinutes: _travel,
      mode: _mode,
      attraction: _attraction,
      pace: _pace,
      hasPlan: _plan != null,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
          content: Text(success
              ? 'Trip draft saved on this device'
              : 'Could not save on this device. Copy the plan to keep it.')));
  }

  Future<void> _deleteDraft() async {
    final previous = widget.controller.draftFor(widget.destination.id);
    final success = await widget.controller.removeDraft(widget.destination.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(success
            ? 'Saved draft removed; current inputs are still here'
            : 'Saved draft could not be removed from device storage'),
        action: success && previous != null
            ? SnackBarAction(
                label: 'Undo',
                onPressed: () async {
                  final restored = await widget.controller.saveDraft(previous);
                  if (mounted) {
                    setState(() {});
                    if (!restored) {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(const SnackBar(
                            content: Text(
                                'Could not restore the saved draft on this device')));
                    }
                  }
                })
            : null,
      ));
  }

  @override
  void dispose() {
    _origin.dispose();
    _hotel.dispose();
    _restaurant.dispose();
    super.dispose();
  }

  void _clearPlan() {
    _plan = null;
    _error = null;
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Please enter a place name.'
      : null;

  void _generate() {
    if (!_form.currentState!.validate()) return;
    setState(() {
      try {
        _plan = _calculatePlan();
        _error = null;
      } on ArgumentError catch (error) {
        _plan = null;
        _error = error.message.toString();
      }
    });
    if (_plan != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
            content: Text(
                'Your day plan is ready below. Save the draft to keep it.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.destination;
    final city = '${place.name}, ${place.country}';
    return Scaffold(
      appBar: AppBar(title: Text('One day in ${place.name}')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Form(
                  key: _form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Make room for a little adventure.',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        const Text(
                            'Create an editable day plan with up to five outings. Times are your planning buffers, not live journey estimates. Save the draft to resume it on this device.'),
                        if (widget.controller.storageMessage != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(widget.controller.storageMessage!)),
                        const SizedBox(height: 24),
                        TextFormField(
                            controller: _origin,
                            maxLength: 500,
                            validator: _required,
                            onChanged: (_) => setState(_clearPlan),
                            decoration: const InputDecoration(
                                labelText: 'Arrival airport / station',
                                hintText:
                                    'Enter the specific airport or station')),
                        const SizedBox(height: 12),
                        TextFormField(
                            controller: _hotel,
                            maxLength: 500,
                            validator: _required,
                            onChanged: (_) => setState(_clearPlan),
                            decoration: const InputDecoration(
                                labelText: 'Hotel / luggage-drop location',
                                hintText:
                                    'Enter the hotel or a confirmed drop-off point')),
                        const SizedBox(height: 8),
                        TextFormField(
                            controller: _restaurant,
                            maxLength: 500,
                            onChanged: (_) => setState(_clearPlan),
                            decoration: const InputDecoration(
                                labelText: 'Restaurant / meal stop (optional)',
                                hintText:
                                    'Choose nearby food, or leave blank')),
                        const SizedBox(height: 8),
                        TravelLinkButton(
                            label: 'Find a hotel near the attraction',
                            icon: Icons.hotel_outlined,
                            url: hotelSearch(_attraction, city, 'Budget')),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            icon: const Icon(Icons.schedule),
                            label: Text(
                                'Arrival time: ${clockTime(_arrival.hour * 60 + _arrival.minute)}'),
                            onPressed: () async {
                              final time = await showTimePicker(
                                  context: context, initialTime: _arrival);
                              if (time != null && mounted) {
                                setState(() {
                                  _arrival = time;
                                  _clearPlan();
                                });
                              }
                            }),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.hotel_outlined),
                          label: Text(
                              'Room available from: ${clockTime(_hotelReady.hour * 60 + _hotelReady.minute)}'),
                          onPressed: () async {
                            final time = await showTimePicker(
                                context: context, initialTime: _hotelReady);
                            if (time != null && mounted) {
                              setState(() {
                                _hotelReady = time;
                                _clearPlan();
                              });
                            }
                          },
                        ),
                        const Text(
                            'Set the room-access time confirmed by your hotel. The plan waits until then before scheduling rest.'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                            initialValue: _attraction,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Your main attraction'),
                            items: {
                              ...place.attractions.map((a) => a.name),
                              _attraction
                            }
                                .toList()
                                .map((item) => DropdownMenuItem(
                                    value: item, child: Text(item)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _attraction = value;
                                  _additionalPlaces.removeWhere((p) =>
                                      p.toLowerCase() == value.toLowerCase());
                                  _clearPlan();
                                });
                              }
                            }),
                        const SizedBox(height: 16),
                        Text('More stops in your day',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Text(
                            'Add malls, sights, parks or an event venue. Each outing uses the visit duration below and gets a travel buffer. Check event times yourself.'),
                        for (var index = 0;
                            index < _additionalPlaces.length;
                            index++)
                          ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Text('${index + 2}'),
                              title: Text(_additionalPlaces[index]),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        tooltip: 'Move stop earlier',
                                        onPressed: index == 0
                                            ? null
                                            : () => setState(() {
                                                  final name = _additionalPlaces
                                                      .removeAt(index);
                                                  _additionalPlaces.insert(
                                                      index - 1, name);
                                                  _clearPlan();
                                                }),
                                        icon: const Icon(Icons.arrow_upward)),
                                    IconButton(
                                        tooltip: 'Remove stop',
                                        onPressed: () => setState(() {
                                              _additionalPlaces.removeAt(index);
                                              _clearPlan();
                                            }),
                                        icon: const Icon(Icons.close)),
                                  ])),
                        OutlinedButton.icon(
                            onPressed: _pickStops,
                            icon: const Icon(Icons.add_location_alt_outlined),
                            label: const Text('Choose more stops')),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                            initialValue: _mode,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Transport preference'),
                            items: transportModes.entries
                                .map((entry) => DropdownMenuItem(
                                    value: entry.key, child: Text(entry.value)))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _mode = value;
                                  _clearPlan();
                                });
                              }
                            }),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _pace,
                          decoration: const InputDecoration(
                              labelText: 'Sightseeing pace'),
                          items: visitMinutesByPace.keys
                              .map((pace) => DropdownMenuItem(
                                  value: pace, child: Text(pace)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _pace = value;
                                _visit = null;
                                _rest = restMinutesByPace[value]!;
                                _clearPlan();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                            '$_pace defaults to ${visitMinutesByPace[_pace]} minutes sightseeing. Adjust visit and rest below; parks often need several hours.'),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                            key: ValueKey(
                                'visit-${_visit ?? visitMinutesByPace[_pace]}'),
                            initialValue: _visit ?? visitMinutesByPace[_pace],
                            decoration: const InputDecoration(
                                labelText: 'Visit duration per outing'),
                            items: const [30, 60, 90, 120, 180, 240, 360, 480]
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text('$m minutes')))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _visit = value;
                                  _clearPlan();
                                });
                              }
                            }),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                            key: ValueKey('rest-$_rest'),
                            initialValue: _rest,
                            decoration:
                                const InputDecoration(labelText: 'Rest time'),
                            items: const [0, 30, 60, 90, 120, 180]
                                .map((minutes) => DropdownMenuItem(
                                    value: minutes,
                                    child: Text('$minutes minutes')))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _rest = value;
                                  _clearPlan();
                                });
                              }
                            }),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                            initialValue: _travel,
                            decoration: const InputDecoration(
                                labelText: 'Buffer for each transfer'),
                            items: const [15, 30, 60, 90, 120, 180]
                                .map((minutes) => DropdownMenuItem(
                                    value: minutes,
                                    child: Text('$minutes minutes')))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _travel = value;
                                  _clearPlan();
                                });
                              }
                            }),
                        const SizedBox(height: 12),
                        const Text(
                            'Public transport is the starting preference for a budget-minded plan. Compare actual fares and routes before choosing. Increase the transfer buffer for distant places.'),
                        const SizedBox(height: 20),
                        SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                                onPressed: _generate,
                                icon: const Icon(Icons.auto_stories_outlined),
                                label: const Text('Create my day plan'))),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: [
                          OutlinedButton.icon(
                              onPressed: _saving ? null : _saveDraft,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(
                                  _saving ? 'Saving...' : 'Save trip draft')),
                          if (widget.controller.draftFor(place.id) != null)
                            TextButton.icon(
                                onPressed: _saving ? null : _deleteDraft,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete saved draft')),
                        ]),
                        const Text(
                            'One draft per destination. Saving replaces that destination\'s previous draft. Device/browser data can be cleared in settings.'),
                        if (_error != null)
                          Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(_error!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error))),
                        if (_plan != null) ...[
                          const SizedBox(height: 28),
                          Text('Your day, at a glance',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          for (final stop in _plan!)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                  child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(stop.timeRange,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(stop.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      const SizedBox(height: 6),
                                      Text(stop.note),
                                      if (stop.destination != null)
                                        TravelLinkButton(
                                            label: 'Check this route',
                                            icon: Icons.directions_outlined,
                                            url: directions(
                                                origin: '${stop.origin}, $city',
                                                destination:
                                                    '${stop.destination}, $city',
                                                mode: _mode)),
                                      if (stop.title == 'Meal & a break')
                                        TravelLinkButton(
                                            label: 'Find nearby food',
                                            icon: Icons.restaurant_outlined,
                                            url: mapSearch(_restaurant.text
                                                    .trim()
                                                    .isEmpty
                                                ? 'restaurants near ${_additionalPlaces.isEmpty ? _attraction : _additionalPlaces.last}, $city'
                                                : '${_restaurant.text.trim()}, $city')),
                                    ]),
                              )),
                            ),
                          OutlinedButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy my day plan'),
                              onPressed: () async {
                                final text =
                                    'One day in ${place.name}\nPace: $_pace\nMeal: ${_restaurant.text.trim().isEmpty ? 'Choose nearby' : _restaurant.text.trim()}\nTransport: ${transportModes[_mode]}\nDraft timings - verify routes, opening hours and hotel access.\n\n${_plan!.map((stop) => '${stop.timeRange} ${stop.title}\n${stop.note}').join('\n\n')}';
                                await Clipboard.setData(
                                    ClipboardData(text: text));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(const SnackBar(
                                        content: Text('Day plan copied')));
                                }
                              }),
                          const SizedBox(height: 12),
                          const Text(
                              'Use Save trip draft to resume here later, or Copy my day plan to keep a text version. Unsaved edits are lost when you leave.'),
                        ],
                      ])),
            ),
          )),
    );
  }
}
