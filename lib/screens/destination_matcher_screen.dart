import 'package:flutter/material.dart';

import '../data/destination_match_profiles.dart';
import '../data/destinations.dart';
import '../models/destination_match.dart';
import '../state/travel_controller.dart';
import '../widgets/destination_image.dart';
import 'city_discover_screen.dart';

class DestinationMatcherScreen extends StatefulWidget {
  const DestinationMatcherScreen({
    super.key,
    required this.controller,
    this.initialTravelType,
  });

  final TravelController controller;
  final String? initialTravelType;

  @override
  State<DestinationMatcherScreen> createState() =>
      _DestinationMatcherScreenState();
}

class _DestinationMatcherScreenState extends State<DestinationMatcherScreen> {
  String? _travelType;
  TripBudget? _budget;
  int? _days;
  List<DestinationMatch>? _matches;

  @override
  void initState() {
    super.initState();
    _travelType = widget.initialTravelType;
  }

  MatchPreferences get _preferences =>
      MatchPreferences(travelType: _travelType, budget: _budget, days: _days);

  // A changed choice clears old results so the reasons always match the inputs.
  void _change(VoidCallback update) => setState(() {
    update();
    _matches = null;
  });

  @override
  Widget build(BuildContext context) {
    final exact = _matches?.where((match) => match.isExact).toList() ?? [];
    final suggestions = (exact.isNotEmpty ? exact : _matches ?? []).take(3);
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Destination Matcher')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'A city that fits your trip',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore all cities with fresh trip preferences. Each match tells you why it fits.',
                ),
                const SizedBox(height: 20),
                Text(
                  'Travel type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: const Text('Any type'),
                      selected: _travelType == null,
                      onSelected: (_) => _change(() => _travelType = null),
                    ),
                    for (final type in widget.controller.categories)
                      ChoiceChip(
                        key: ValueKey('matcher-type-$type'),
                        label: Text(type),
                        selected: _travelType == type,
                        onSelected: (selected) =>
                            _change(() => _travelType = selected ? type : null),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Budget style',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ChoiceChip(
                      label: const Text('Any budget'),
                      selected: _budget == null,
                      onSelected: (_) => _change(() => _budget = null),
                    ),
                    for (final budget in TripBudget.values)
                      ChoiceChip(
                        key: ValueKey('matcher-budget-${budget.name}'),
                        label: Text(budget.label),
                        selected: _budget == budget,
                        onSelected: (selected) =>
                            _change(() => _budget = selected ? budget : null),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  key: ValueKey('matcher-days-${_days ?? 0}'),
                  isExpanded: true,
                  initialValue: _days ?? 0,
                  decoration: const InputDecoration(
                    labelText: 'Trip duration',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 0,
                      child: Text('Any duration'),
                    ),
                    for (var day = 1; day <= 7; day++)
                      DropdownMenuItem(
                        value: day,
                        child: Text('$day ${day == 1 ? 'day' : 'days'}'),
                      ),
                  ],
                  onChanged: (value) =>
                      _change(() => _days = value == 0 ? null : value),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Uses hand-written sample budget styles and visit lengths. '
                  'These are planning examples, not live prices or availability. '
                  'Travel to the city is not included.',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _preferences.count == 0
                      ? null
                      : () => setState(
                          () => _matches = matchDestinations(
                            destinations,
                            destinationMatchProfiles,
                            _preferences,
                          ),
                        ),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Find my matches'),
                ),
                TextButton(
                  onPressed: () => _change(() {
                    _travelType = null;
                    _budget = null;
                    _days = null;
                  }),
                  child: const Text('Reset preferences'),
                ),
                if (_matches == null)
                  Text(
                    _preferences.count == 0
                        ? 'Choose at least one preference to start.'
                        : 'Your results will appear here.',
                  ),
                if (_matches != null) ...[
                  const Divider(height: 32),
                  Text(
                    exact.isNotEmpty ? 'Your matches' : 'Closest options',
                    key: const ValueKey('match-results'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exact.isNotEmpty
                        ? 'Up to three cities matching every selected preference.'
                        : 'No city matches every choice. Compare the differences or change your preferences.',
                  ),
                  const SizedBox(height: 16),
                  for (final match in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _MatchCard(
                        match: match,
                        controller: widget.controller,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.controller});

  final DestinationMatch match;
  final TravelController controller;

  @override
  Widget build(BuildContext context) {
    final city = match.destination;
    final profile = match.profile;
    return Card(
      key: ValueKey('match-result-${city.id}'),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: DestinationImage(url: city.imageUrl, label: city.name),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        city.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ListenableBuilder(
                      listenable: controller,
                      builder: (context, _) => IconButton(
                        key: ValueKey('matcher-save-${city.id}'),
                        tooltip:
                            '${controller.isSaved(city.id) ? 'Remove' : 'Save'} ${city.name}',
                        isSelected: controller.isSaved(city.id),
                        icon: const Icon(Icons.favorite_border),
                        selectedIcon: const Icon(Icons.favorite),
                        onPressed: () => controller.toggleWishlist(city.id),
                      ),
                    ),
                  ],
                ),
                Text('${city.location} · ${city.category}'),
                const SizedBox(height: 12),
                Text(
                  '${match.score}/${match.preferenceCount} preferences matched',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                for (final reason in match.reasons)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('✓ $reason'),
                  ),
                if (match.differences.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'What differs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (final difference in match.differences)
                    Text('• $difference'),
                ],
                if (profile != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Sample guide: ${profile.durationLabel} · '
                    '${profile.budgets.map((b) => b.label).join(' / ')}',
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  key: ValueKey('matcher-explore-${city.id}'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CityDiscoverScreen(
                        destination: city,
                        controller: controller,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_outward),
                  label: Text('Explore ${city.name}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
