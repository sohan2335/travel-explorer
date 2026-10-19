import 'package:flutter/material.dart';

import '../data/destinations.dart';
import '../models/destination.dart';
import '../state/travel_controller.dart';
import '../widgets/destination_image.dart';
import '../widgets/travel_tools.dart';
import 'place_information.dart';
import 'day_planner_screen.dart';
import 'city_discover_screen.dart';
import 'profile_screen.dart';
import '../widgets/discovery_shortcuts.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key, required this.controller});

  final TravelController controller;

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  int _tab = 0;
  String _activity = 'restaurant';
  final _searchFocus = FocusNode();
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.controller.query);
  }

  @override
  void didUpdateWidget(ExplorerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _search.text = widget.controller.query;
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final saved = _tab == 3;
        final items =
            saved ? controller.wishlist : controller.visibleDestinations;
        return Scaffold(
          appBar: AppBar(
            flexibleSpace: const DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF37235F), Color(0xFF0E0E10)]))),
            title: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.explore_outlined, size: 24),
              SizedBox(width: 10),
              Text('Travel Explorer',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
            actions: [
              IconButton(
                  tooltip: 'Profile and sign in',
                  icon: const Icon(Icons.account_circle_outlined),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen())))
            ],
          ),
          body: _tab == 4
              ? ProfileScreen(
                  embedded: true, onExplore: () => setState(() => _tab = 0))
              : _tab == 2
                  ? _trips(context)
                  : SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 20),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                          saved
                                              ? 'YOUR PERSONAL COLLECTION'
                                              : 'YOUR CITY, YOUR WAY',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 2.4,
                                          )),
                                      const SizedBox(height: 14),
                                      Text(
                                          saved
                                              ? 'Places worth keeping.'
                                              : _tab == 1
                                                  ? 'Find your next city.'
                                                  : 'Go somewhere.\nMake a day of it.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: -1.3,
                                                height: 1.12,
                                              )),
                                      const SizedBox(height: 8),
                                      Text(saved
                                          ? 'Your favourite corners of the world, ready for another day.'
                                          : 'Stays, good food and little adventures. All in one place.'),
                                      if (controller.storageMessage != null)
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                                controller.storageMessage!)),
                                      if (saved) ...[
                                        const SizedBox(height: 16),
                                        const Text('Saved trip drafts',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        if (controller.drafts.isEmpty)
                                          const Text(
                                              'Save a draft in the day planner to resume it here.'),
                                        for (final draft in controller.drafts)
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                                'Resume ${destinations.firstWhere((p) => p.id == draft.destinationId).name} trip'),
                                            subtitle: Text(
                                                '${draft.pace} pace • saved on this device'),
                                            trailing:
                                                const Icon(Icons.arrow_forward),
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => DayPlannerScreen(
                                                        destination: destinations
                                                            .firstWhere((p) =>
                                                                p.id ==
                                                                draft
                                                                    .destinationId),
                                                        controller:
                                                            controller))),
                                          ),
                                      ],
                                      if (!saved) ...[
                                        const SizedBox(height: 24),
                                        TextField(
                                          controller: _search,
                                          focusNode: _searchFocus,
                                          onChanged: controller.setQuery,
                                          decoration: const InputDecoration(
                                            labelText: 'Find your city',
                                            hintText: 'Try Goa or Jaipur',
                                            prefixIcon: Icon(Icons.search),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        DropdownButtonFormField<String>(
                                          initialValue:
                                              controller.selectedCountry ??
                                                  'All countries',
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                              labelText: 'Country'),
                                          items: [
                                            'All countries',
                                            ...controller.countries
                                          ]
                                              .map((country) =>
                                                  DropdownMenuItem(
                                                      value: country,
                                                      child: Text(country)))
                                              .toList(),
                                          onChanged: (value) =>
                                              controller.setCountry(
                                                  value == 'All countries'
                                                      ? null
                                                      : value),
                                        ),
                                        const SizedBox(height: 16),
                                        Text('What would you like to do?',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 10),
                                        Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              for (final entry in const {
                                                'restaurant': 'Dining',
                                                'mall': 'Shopping',
                                                'event': 'Events',
                                                'hotel': 'Stays',
                                                'adventure': 'Adventure parks',
                                                'waterpark': 'Water parks'
                                              }.entries)
                                                ChoiceChip(
                                                    avatar: Icon(
                                                        discoveryIcons[
                                                            entry.key],
                                                        size: 19,
                                                        color: discoveryColors[
                                                            entry.key]),
                                                    label: Text(entry.value),
                                                    selected:
                                                        _activity == entry.key,
                                                    onSelected: (_) => setState(
                                                        () => _activity =
                                                            entry.key)),
                                            ]),
                                        const SizedBox(height: 8),
                                        Text(
                                            'Now choose a city to explore ${discoveryLabels[_activity]!.toLowerCase()}.'),
                                      ],
                                      const SizedBox(height: 20),
                                      Text(
                                          '${items.length} ${saved ? 'saved places' : 'cities to explore'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                    ],
                                  ),
                                ),
                              ),
                              if (items.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            saved
                                                ? Icons.favorite_border
                                                : Icons.search_off,
                                            size: 56),
                                        const SizedBox(height: 16),
                                        Text(
                                            saved
                                                ? 'Your wishlist is waiting'
                                                : 'No destinations found',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                            textAlign: TextAlign.center),
                                        const SizedBox(height: 8),
                                        Text(
                                            saved
                                                ? 'Tap a heart on any destination to save it here.'
                                                : 'Try another city name or country.',
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                )
                              else if (_tab == 0)
                                SliverToBoxAdapter(
                                    child: _CityCarousel(
                                        initialKind: _activity,
                                        key: ValueKey(
                                            items.map((p) => p.id).join(',')),
                                        items: items,
                                        controller: controller))
                              else
                                SliverPadding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                  sliver: SliverLayoutBuilder(
                                      builder: (context, constraints) {
                                    final columns =
                                        constraints.crossAxisExtent >= 700
                                            ? 2
                                            : 1;
                                    return SliverList.builder(
                                      itemCount:
                                          (items.length / columns).ceil(),
                                      itemBuilder: (context, row) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (int column = 0;
                                                column < columns;
                                                column++) ...[
                                              if (column > 0)
                                                const SizedBox(width: 16),
                                              Expanded(
                                                  child: row *
                                                                  columns +
                                                              column <
                                                          items.length
                                                      ? _DestinationCard(
                                                          initialKind:
                                                              _activity,
                                                          destination: items[
                                                              row * columns +
                                                                  column],
                                                          controller:
                                                              controller)
                                                      : const SizedBox
                                                          .shrink()),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (index) {
              setState(() => _tab = index);
              if (index == 1)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _searchFocus.requestFocus();
                });
              else
                _searchFocus.unfocus();
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Explore'),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(
                  icon: Icon(Icons.route_outlined),
                  selectedIcon: Icon(Icons.route),
                  label: 'My trips'),
              NavigationDestination(
                  icon: Icon(Icons.favorite_border),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Wishlist'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile'),
            ],
          ),
        );
      },
    );
  }

  Widget _trips(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(24), children: [
        Text('Your days, planned.',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
            'Pick up a saved itinerary. Plans are stored on this device.'),
        const SizedBox(height: 24),
        if (widget.controller.drafts.isEmpty) ...[
          const Icon(Icons.route_outlined, size: 64),
          const SizedBox(height: 16),
          const Text('Your next adventure starts with a city.',
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: () => setState(() => _tab = 0),
              child: const Text('Choose a city to plan')),
        ],
        for (final draft in widget.controller.drafts)
          Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                  child: ListTile(
                leading: const Icon(Icons.route),
                title: Text(
                    '${destinations.firstWhere((d) => d.id == draft.destinationId).name} day plan'),
                subtitle: Text('${draft.pace} pace - ${draft.hotel}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DayPlannerScreen(
                            destination: destinations
                                .firstWhere((d) => d.id == draft.destinationId),
                            controller: widget.controller))),
              ))),
      ]);
}

class _DestinationCard extends StatelessWidget {
  const _DestinationCard(
      {required this.destination,
      required this.controller,
      this.initialKind = 'restaurant'});
  final String initialKind;
  final Destination destination;
  final TravelController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          constraints: const BoxConstraints(maxWidth: 1100),
          builder: (_) => FractionallySizedBox(
              heightFactor: .94,
              child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  child: CityDiscoverScreen(
                      initialKind: initialKind,
                      destination: destination,
                      controller: controller))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              SizedBox(
                  height: 230,
                  child: DestinationImage(
                      url: destination.imageUrl, label: destination.name)),
              Positioned(
                top: 8,
                right: 10,
                child: Material(
                  color: const Color(0xFF242428),
                  shape: const CircleBorder(),
                  child: _SaveButton(
                      destination: destination, controller: controller),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.6)),
                    const SizedBox(height: 4),
                    Text(destination.location),
                  ],
                )),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF303036),
                  foregroundColor: Color(0xFFC3AEFF),
                  child: Icon(Icons.arrow_outward, size: 19),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.destination, required this.controller});
  final Destination destination;
  final TravelController controller;

  @override
  Widget build(BuildContext context) {
    final saved = controller.isSaved(destination.id);
    return IconButton(
      tooltip: '${saved ? 'Remove' : 'Save'} ${destination.name}',
      isSelected: saved,
      onPressed: () => controller.toggleWishlist(destination.id),
      icon: const Icon(Icons.favorite_border),
      selectedIcon: const Icon(Icons.favorite),
      color: Theme.of(context).colorScheme.primary,
    );
  }
}

class DestinationDetails extends StatelessWidget {
  const DestinationDetails(
      {super.key, required this.destination, required this.controller});
  final Destination destination;
  final TravelController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: Text(destination.name), actions: [
          _SaveButton(destination: destination, controller: controller),
          const SizedBox(width: 8),
        ]),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: SizedBox(
                            height: 300,
                            child: DestinationImage(
                                url: destination.imageUrl,
                                label: destination.name)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(destination.category,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.centerLeft),
                              onPressed: () =>
                                  showPlaceInformation(context, destination),
                              child: Text('${destination.name}  ↗',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          decoration:
                                              TextDecoration.underline)),
                            ),
                            const SizedBox(height: 8),
                            Text(destination.location),
                            const SizedBox(height: 24),
                            Text(destination.description,
                                style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                                icon: const Icon(Icons.explore_outlined),
                                label: const Text(
                                    'Find stays, food & things to do'),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => CityDiscoverScreen(
                                            destination: destination,
                                            controller: controller)))),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: const Text('Plan one day here'),
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                      builder: (_) => DayPlannerScreen(
                                          controller: controller,
                                          destination: destination))),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7ECDD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.wb_sunny_outlined,
                                        color: Color(0xFFC3AEFF)),
                                    const SizedBox(width: 14),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Best time to visit',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                        const SizedBox(height: 6),
                                        Text(destination.bestTimeToVisit),
                                      ],
                                    )),
                                  ]),
                            ),
                            const SizedBox(height: 24),
                            Text('Top attractions',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            LayoutBuilder(builder: (context, constraints) {
                              final width = constraints.maxWidth >= 650
                                  ? (constraints.maxWidth - 32) / 3
                                  : constraints.maxWidth;
                              return Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    for (final attraction
                                        in destination.attractions)
                                      SizedBox(
                                          width: width,
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      height: 150,
                                                      child: DestinationImage(
                                                          url: attraction
                                                              .imageUrl,
                                                          label:
                                                              attraction.name)),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: TextButton(
                                                        style: TextButton.styleFrom(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            alignment: Alignment
                                                                .centerLeft),
                                                        onPressed: () =>
                                                            showPlaceInformation(
                                                                context,
                                                                destination,
                                                                attraction:
                                                                    attraction),
                                                        child: Text(
                                                            '${attraction.name}  ↗',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline)),
                                                      )),
                                                ]),
                                          )),
                                  ]);
                            }),
                            const SizedBox(height: 28),
                            const Divider(),
                            const SizedBox(height: 20),
                            TravelTools(destination: destination),
                          ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// PageView handles swipes; arrow buttons make the same action easy on desktop.
class _CityCarousel extends StatefulWidget {
  const _CityCarousel(
      {super.key,
      required this.items,
      required this.controller,
      required this.initialKind});
  final String initialKind;
  final List<Destination> items;
  final TravelController controller;
  @override
  State<_CityCarousel> createState() => _CityCarouselState();
}

class _CityCarouselState extends State<_CityCarousel> {
  final _pages = PageController(viewportFraction: .90);
  int _index = 0;
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _move(int page) => _pages.animateToPage(page,
      duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Pick your next city',
                style: Theme.of(context).textTheme.titleLarge)),
        const Padding(
            padding: EdgeInsets.fromLTRB(20, 6, 20, 16),
            child: Text(
                'Swipe to explore. Tap a photo for food, stays and things to do.')),
        SizedBox(
            height: 260 + MediaQuery.textScalerOf(context).scale(105),
            child: PageView.builder(
              controller: _pages,
              itemCount: widget.items.length,
              onPageChanged: (page) => setState(() => _index = page),
              itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: _DestinationCard(
                      destination: widget.items[index],
                      initialKind: widget.initialKind,
                      controller: widget.controller)),
            )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              tooltip: 'Previous city',
              onPressed: _index == 0 ? null : () => _move(_index - 1),
              icon: const Icon(Icons.arrow_back)),
          Text('${_index + 1} / ${widget.items.length}',
              semanticsLabel: 'City ${_index + 1} of ${widget.items.length}'),
          IconButton(
              tooltip: 'Next city',
              onPressed: _index == widget.items.length - 1
                  ? null
                  : () => _move(_index + 1),
              icon: const Icon(Icons.arrow_forward)),
        ]),
        const SizedBox(height: 20),
      ]);
}
