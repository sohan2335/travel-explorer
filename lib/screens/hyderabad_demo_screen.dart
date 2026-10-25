import 'package:flutter/material.dart';
import '../data/destinations.dart';
import '../data/hyderabad_demo.dart';
import '../services/travel_links.dart';
import '../state/travel_controller.dart';
import '../widgets/travel_link_button.dart';
import 'day_planner_screen.dart';

class HyderabadDemoScreen extends StatefulWidget {
  const HyderabadDemoScreen({super.key, required this.controller});
  final TravelController controller;
  @override
  State<HyderabadDemoScreen> createState() => _HyderabadDemoScreenState();
}

class _HyderabadDemoScreenState extends State<HyderabadDemoScreen> {
  DateTime _date = DateTime.now();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('A student day in Hyderabad')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'One neighbourhood. A day of discovery.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'A curated Old City example from MGBS, with a palace, Charminar and Laad Bazaar. Start after breakfast; choose your own meals and transport. This example does not include hotel check-in.',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  'Visit date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2026),
                    lastDate: DateTime(2030, 12, 31),
                  );
                  if (selected != null && mounted) {
                    setState(() => _date = selected);
                  }
                },
              ),
              const SizedBox(height: 12),
              if (!palaceOpenOn(_date))
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Friday closure: Chowmahalla Palace is closed. Choose another day for this route, or create your own plan around a different attraction.',
                    ),
                  ),
                )
              else ...[
                const Text(
                  'Palace hours: 10:00–17:00, Saturday–Thursday. Recheck before travelling.',
                ),
                const SizedBox(height: 12),
                for (final stop in hyderabadDemo)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.timeRange,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            stop.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(stop.note),
                          if (stop.origin != null)
                            TravelLinkButton(
                              label: 'Check directions',
                              url: directions(
                                origin: stop.origin!,
                                destination: stop.destination!,
                                mode: stop.title == 'Head to Charminar'
                                    ? 'walking'
                                    : 'transit',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Create my own Hyderabad plan'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DayPlannerScreen(
                      destination: destinations.firstWhere(
                        (place) => place.id == 'hyderabad',
                      ),
                      controller: widget.controller,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sources checked 18 October 2026. Times between stops are example buffers, not live timetables or fare quotes. A nearby metro station still requires onward travel to the palace.',
              ),
              TravelLinkButton(
                label: 'Palace visitor information',
                url: Uri.parse('https://www.chowmahalla.in/visit/'),
              ),
              TravelLinkButton(
                label: 'Hyderabad tourism information',
                url: Uri.parse('https://hyderabad.telangana.gov.in/tourism/'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
