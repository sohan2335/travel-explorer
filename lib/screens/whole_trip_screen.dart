import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/destinations.dart';
import '../experience/experience_controller.dart';
import '../models/day_plan.dart';
import '../models/destination.dart';
import '../models/trip_draft.dart';
import '../models/whole_trip.dart';
import '../services/local_store.dart';
import '../services/whole_trip_store.dart';
import '../state/travel_controller.dart';
import '../widgets/destination_image.dart';
import '../widgets/planner_mode_switch.dart';
import 'day_planner_screen.dart';

class WholeTripScreen extends StatefulWidget {
  const WholeTripScreen({
    super.key,
    required this.destination,
    required this.controller,
    this.store,
    this.fromDayPlanner = false,
  });
  final Destination destination;
  final TravelController controller;
  final LocalStore? store;
  final bool fromDayPlanner;
  @override
  State<WholeTripScreen> createState() => _WholeTripScreenState();
}

class _WholeTripScreenState extends State<WholeTripScreen> {
  late WholeTripStore _store;
  late WholeTrip _trip;
  bool _loading = true, _saving = false;
  String? _message;
  @override
  void initState() {
    super.initState();
    _store = WholeTripStore(
      widget.store ??
          context
              .getInheritedWidgetOfExactType<ExperienceScope>()
              ?.controller
              .store ??
          DeviceStore(),
    );
    final now = DateTime.now();
    _trip = WholeTrip(
      cityId: widget.destination.id,
      startDate: DateTime(now.year, now.month, now.day),
      days: [_newDay(0), _newDay(1)],
    );
    _restore();
  }

  TripDraft _newDay(int index) {
    final style =
        context
            .getInheritedWidgetOfExactType<ExperienceScope>()
            ?.controller
            .tripStyle ??
        'Balanced';
    final base = '${widget.destination.name} city centre';
    return TripDraft(
      destinationId: widget.destination.id,
      origin: base,
      hotel: base,
      arrivalMinutes: 540,
      hotelReadyMinutes: 0,
      restMinutes: 0,
      travelMinutes: 60,
      mode: 'transit',
      attraction: widget
          .destination
          .attractions[index % widget.destination.attractions.length]
          .name,
      pace: style,
      hasPlan: false,
      visitMinutes: visitMinutesByPace[style]!,
    );
  }

  Future<void> _restore() async {
    try {
      final saved = await _store.load();
      if (mounted && saved[widget.destination.id] != null) {
        _trip = saved[widget.destination.id]!;
      }
    } catch (_) {
      _message =
          'Saved trips could not be read. You can still plan and copy this trip in this session.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _save({bool announce = true}) async {
    if (_saving) return false;
    setState(() => _saving = true);
    final ok = await _store.save(_trip);
    if (!mounted) return ok;
    setState(() {
      _saving = false;
      _message = ok
          ? null
          : 'Could not save this trip. Copy it to keep a text version.';
    });
    if (announce) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Whole trip saved on this device' : _message!),
        ),
      );
    }
    return ok;
  }

  Future<void> _setDays(int count) async {
    if (_saving || count == _trip.days.length) return;
    if (count < _trip.days.length &&
        _trip.days.skip(count).any((d) => d.hasPlan)) {
      final remove = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Shorten this trip?'),
          content: Text(
            'Days ${count + 1}–${_trip.days.length} will be removed when you save.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep days'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove extra days'),
            ),
          ],
        ),
      );
      if (remove != true || !mounted) return;
    }
    setState(
      () => _trip = _trip.copyWith(
        days: List.generate(
          count,
          (i) => i < _trip.days.length ? _trip.days[i] : _newDay(i),
        ),
      ),
    );
  }

  Future<void> _editDay(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayPlannerScreen(
          destination: widget.destination,
          controller: widget.controller,
          dayDraft: _trip.days[index],
          dayNumber: index + 1,
          onSaveDay: (draft) async {
            final days = List<TripDraft>.of(_trip.days);
            days[index] = draft;
            setState(() => _trip = _trip.copyWith(days: days));
            return _save(announce: false);
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _copy() async {
    try {
      final text = StringBuffer(
        '${_trip.days.length} days in ${widget.destination.name}\nPlanning buffers — check real routes and venue hours.\n',
      );
      for (var i = 0; i < _trip.days.length; i++) {
        text.writeln(
          '\nDay ${i + 1} · ${tripDate(_trip.startDate.add(Duration(days: i)))}',
        );
        if (!_trip.days[i].hasPlan) {
          text.writeln('Not planned yet.');
          continue;
        }
        for (final stop in wholeTripDayPlan(_trip.days[i])) {
          text.writeln('${stop.timeRange} ${stop.title}\n${stop.note}');
        }
      }
      await Clipboard.setData(ClipboardData(text: text.toString()));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Whole trip copied')));
      }
    } on ArgumentError catch (error) {
      if (mounted) {
        setState(
          () =>
              _message = '${error.message} Open each day to adjust its timing.',
        );
      }
    }
  }

  Widget _dayCard(int index) {
    final day = _trip.days[index];
    List<DayPlanStop> stops = [];
    if (day.hasPlan) {
      try {
        stops = wholeTripDayPlan(day);
      } on ArgumentError {
        /* Show edit action for an invalid timetable. */
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day ${index + 1} · ${tripDate(_trip.startDate.add(Duration(days: index)))}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(day.attraction),
              const SizedBox(height: 8),
              Text(
                stops.isEmpty
                    ? 'Choose your stops and create this day’s timetable.'
                    : '${1 + day.additionalPlaces.length} outings · ${day.pace} pace',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _saving ? null : () => _editDay(index),
                icon: const Icon(Icons.edit_outlined),
                label: Text('Edit day ${index + 1}'),
              ),
              if (stops.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('View timetable'),
                  children: [
                    for (final stop in stops)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(stop.title),
                        subtitle: Text(stop.timeRange),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Trip in ${widget.destination.name}')),
    bottomNavigationBar: _loading
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton.icon(
                onPressed: _saving ? null : () => _save(),
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving…' : 'Save whole trip'),
              ),
            ),
          ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  PlannerModeSwitch(
                    wholeTrip: true,
                    onTrip: () {},
                    onDay: () => widget.fromDayPlanner
                        ? Navigator.pop(context)
                        : Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DayPlannerScreen(
                                destination: widget.destination,
                                controller: widget.controller,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'A few days, your way.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan 2–7 days in ${widget.destination.name}. Edit and save each day; your one-day drafts stay separate.',
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(_message!),
                    ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _trip.startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (date != null && mounted) {
                              setState(
                                () => _trip = _trip.copyWith(startDate: date),
                              );
                            }
                          },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text('Starts ${tripDate(_trip.startDate)}'),
                  ),
                  const SizedBox(height: 16),
                  const Text('How many days?'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var n = 2; n <= 7; n++)
                        ChoiceChip(
                          label: Text('$n days'),
                          selected: _trip.days.length == n,
                          onSelected: _saving ? null : (_) => _setDays(n),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < _trip.days.length; i++) _dayCard(i),
                  OutlinedButton.icon(
                    onPressed: _copy,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy whole trip'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'One saved whole trip per city, on this device. Dates and day-count changes save with Save whole trip. Transfers between cities are not included.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
  );
}

class WholeTripsScreen extends StatefulWidget {
  const WholeTripsScreen({super.key, required this.controller, this.store});
  final TravelController controller;
  final LocalStore? store;
  @override
  State<WholeTripsScreen> createState() => _WholeTripsScreenState();
}

class _WholeTripsScreenState extends State<WholeTripsScreen> {
  late WholeTripStore _store;
  late Future<Map<String, WholeTrip>> _saved;
  @override
  void initState() {
    super.initState();
    _store = WholeTripStore(
      widget.store ??
          context
              .getInheritedWidgetOfExactType<ExperienceScope>()
              ?.controller
              .store ??
          DeviceStore(),
    );
    _saved = _store.load();
  }

  Future<void> _open(Destination city) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WholeTripScreen(
          destination: city,
          controller: widget.controller,
          store: _store.store,
        ),
      ),
    );
    if (mounted) setState(() => _saved = _store.load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Whole trips')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Choose a city for your trip',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, WholeTrip>>(
              future: _saved,
              builder: (context, snapshot) => Column(
                children: [
                  if (snapshot.hasError)
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Saved whole trips could not be read.'),
                    ),
                  for (final trip in snapshot.data?.values ?? <WholeTrip>[])
                    ListTile(
                      leading: const Icon(Icons.luggage_outlined),
                      title: Text(
                        'Resume ${destinations.firstWhere((d) => d.id == trip.cityId).name}',
                      ),
                      subtitle: Text(
                        '${trip.days.length} days · ${tripDate(trip.startDate)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(
                        destinations.firstWhere((d) => d.id == trip.cityId),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final city in destinations)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: DestinationImage(
                          url: city.imageUrl,
                          label: city.name,
                        ),
                      ),
                    ),
                    title: Text(city.name),
                    subtitle: Text(city.country),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _open(city),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
