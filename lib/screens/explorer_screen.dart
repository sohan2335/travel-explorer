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
import '../widgets/my_day_actions.dart';
import 'my_day_screen.dart';
import '../widgets/discovery_shortcuts.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key, required this.controller});

  final TravelController controller;

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  int _tab = 0;
  String? _activity;
  Destination? _chosenCity;
  final _cityScroll = ScrollController();
  final _searchFocus = FocusNode();
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    if (Uri.base.queryParameters.containsKey('neon_auth_session_verifier')) {
      _tab = 4;
    }
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
    _cityScroll.dispose();
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
        final items = saved
            ? controller.wishlist
            : _tab == 0
                ? destinations
                : controller.visibleDestinations;
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
              Flexible(
                  child: Text('Travel Explorer',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600))),
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
                                              ? 'Saved'
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
                                        for (final cityId
                                            in controller.pickedCities)
                                          ListTile(
                                              leading: const Icon(
                                                  Icons.playlist_add_check),
                                              title: Text(
                                                  'My day in ${destinations.firstWhere((d) => d.id == cityId).name}'),
                                              subtitle: Text(
                                                  '${controller.myDayFor(cityId).count} picks'),
                                              trailing: const Icon(
                                                  Icons.arrow_forward),
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => MyDayScreen(
                                                          destination: destinations
                                                              .firstWhere((d) =>
                                                                  d.id ==
                                                                  cityId),
                                                          controller:
                                                              controller)))),
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
                                        if (_tab == 1) ...[
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
                                        ],
                                        if (_tab == 0) ...[
                                          Text('Choose a city',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          Row(children: [
                                            const Expanded(
                                                child: Text(
                                                    'Swipe through cities or use the arrows.')),
                                            IconButton(
                                                tooltip: 'Previous cities',
                                                onPressed: () =>
                                                    _cityScroll.animateTo(
                                                        (_cityScroll
                                                                    .offset -
                                                                300)
                                                            .clamp(
                                                                0.0,
                                                                _cityScroll
                                                                    .position
                                                                    .maxScrollExtent),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    250),
                                                        curve: Curves.easeOut),
                                                icon: const Icon(
                                                    Icons.chevron_left)),
                                            IconButton(
                                                tooltip: 'More cities',
                                                onPressed: () =>
                                                    _cityScroll.animateTo(
                                                        (_cityScroll
                                                                    .offset +
                                                                300)
                                                            .clamp(
                                                                0.0,
                                                                _cityScroll
                                                                    .position
                                                                    .maxScrollExtent),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    250),
                                                        curve: Curves.easeOut),
                                                icon: const Icon(
                                                    Icons.chevron_right))
                                          ]),
                                          SizedBox(
                                              height: 150 +
                                                  MediaQuery.textScalerOf(
                                                          context)
                                                      .scale(12),
                                              child: ListView.separated(
                                                  controller: _cityScroll,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      destinations.length,
                                                  separatorBuilder: (_, __) =>
                                                      const SizedBox(width: 12),
                                                  itemBuilder:
                                                      (context, index) {
                                                    final city =
                                                        destinations[index];
                                                    return SizedBox(
                                                        width: 160,
                                                        child: Semantics(
                                                            onTap: () =>
                                                                setState(() {
                                                                  _chosenCity =
                                                                      city;
                                                                  _activity =
                                                                      null;
                                                                }),
                                                            button: true,
                                                            selected: _chosenCity?.id ==
                                                                city.id,
                                                            label:
                                                                'Choose ${city.name}',
                                                            child: Card(
                                                                clipBehavior: Clip
                                                                    .antiAlias,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                    side: BorderSide(
                                                                        color: _chosenCity?.id == city.id
                                                                            ? Theme.of(context)
                                                                                .colorScheme
                                                                                .primary
                                                                            : const Color(
                                                                                0xFF333338),
                                                                        width:
                                                                            2)),
                                                                child: InkWell(
                                                                    onTap: () =>
                                                                        setState(
                                                                            () {
                                                                          _chosenCity =
                                                                              city;
                                                                          _activity =
                                                                              null;
                                                                        }),
                                                                    child: Stack(
                                                                        fit: StackFit
                                                                            .expand,
                                                                        children: [
                                                                          DestinationImage(
                                                                              url: city.imageUrl,
                                                                              label: city.name),
                                                                          const DecoratedBox(
                                                                              decoration: BoxDecoration(
                                                                                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                                                                            Colors.transparent,
                                                                            Color(0xF008090B)
                                                                          ]))),
                                                                          Positioned(
                                                                              left: 12,
                                                                              right: 12,
                                                                              bottom: 12,
                                                                              child: Text(city.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))
                                                                        ])))));
                                                  })),
                                          const SizedBox(height: 16),
                                          if (_chosenCity != null)
                                            OutlinedButton.icon(
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            CityDiscoverScreen(
                                                                destination:
                                                                    _chosenCity!,
                                                                controller:
                                                                    controller))),
                                                icon: const Icon(
                                                    Icons.explore_outlined),
                                                label: Text(
                                                    'Explore ${_chosenCity!.name}')),
                                          const SizedBox(height: 16),
                                          Text(
                                              _chosenCity == null
                                                  ? 'Choose a city to unlock activities'
                                                  : 'What would you like to do in ${_chosenCity!.name}?',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium),
                                          const SizedBox(height: 10),
                                          DiscoveryShortcuts(
                                              selected: _activity,
                                              includePlan: false,
                                              enabled: _chosenCity != null,
                                              onSelected: (kind) {
                                                setState(
                                                    () => _activity = kind);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            CityDiscoverScreen(
                                                                destination:
                                                                    _chosenCity!,
                                                                controller:
                                                                    controller,
                                                                initialKind:
                                                                    kind)));
                                              }),
                                        ],
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
                                                ? 'No saved cities yet'
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
                                const SliverToBoxAdapter(
                                    child: SizedBox(height: 24))
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
                                                  child: row * columns +
                                                              column <
                                                          items.length
                                                      ? _DestinationCard(
                                                          initialKind:
                                                              _activity ??
                                                                  'restaurant',
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
          bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(42),
                              child: NavigationBar(
                                height: 76,
                                backgroundColor: const Color(0xFF242426),
                                indicatorColor: const Color(0xFF414144),
                                selectedIndex: _tab == 1
                                    ? 2
                                    : _tab == 3 || _tab == 2
                                        ? 1
                                        : 0,
                                onDestinationSelected: (index) {
                                  setState(() => _tab = [0, 3, 1][index]);
                                  if (index == 2) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted) _searchFocus.requestFocus();
                                    });
                                  } else {
                                    _searchFocus.unfocus();
                                  }
                                },
                                destinations: const [
                                  NavigationDestination(
                                      icon: Icon(Icons.home_outlined),
                                      selectedIcon: Icon(Icons.home),
                                      label: 'Home'),
                                  NavigationDestination(
                                      icon: Icon(Icons.bookmark_outline),
                                      selectedIcon: Icon(Icons.bookmark),
                                      label: 'Saved'),
                                  NavigationDestination(
                                      icon: Icon(Icons.search), label: 'Search')
                                ],
                              )))))),
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
  void _plan(BuildContext context, {String? attraction}) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => DayPlannerScreen(
              destination: destination,
              controller: controller,
              initialAttraction: attraction)));
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
        listenable: controller,
        builder: (context, _) => Scaffold(
              appBar: AppBar(
                  title: Text('${destination.name} city guide',
                      overflow: TextOverflow.ellipsis),
                  actions: [
                    _SaveButton(
                        destination: destination, controller: controller)
                  ]),
              bottomNavigationBar: SafeArea(
                  top: false,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Center(
                          heightFactor: 1,
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 960),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                      onPressed: () => _plan(context),
                                      icon: const Icon(Icons.route),
                                      label:
                                          const Text('Plan one day here'))))))),
              body: SingleChildScrollView(
                  child: Center(
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 96),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: SizedBox(
                                            height: 240,
                                            child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  DestinationImage(
                                                      url: destination.imageUrl,
                                                      label: destination.name),
                                                  const DecoratedBox(
                                                      decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                        Colors.transparent,
                                                        Color(0xEE08090B)
                                                      ]))),
                                                  Positioned(
                                                      left: 20,
                                                      right: 20,
                                                      bottom: 20,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                destination
                                                                    .name,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        32,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .white)),
                                                            Text(
                                                                destination
                                                                    .location,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white))
                                                          ])),
                                                ]))),
                                    const SizedBox(height: 20),
                                    Text('Get to know ${destination.name}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    const SizedBox(height: 8),
                                    Text(destination.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(height: 1.6)),
                                    const SizedBox(height: 16),
                                    Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          OutlinedButton.icon(
                                              onPressed: () =>
                                                  showPlaceInformation(
                                                      context, destination,
                                                      controller: controller),
                                              icon: const Icon(
                                                  Icons.info_outline),
                                              label: const Text(
                                                  'About this city')),
                                          OutlinedButton.icon(
                                              onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          CityDiscoverScreen(
                                                              destination:
                                                                  destination,
                                                              controller:
                                                                  controller))),
                                              icon: const Icon(
                                                  Icons.explore_outlined),
                                              label: const Text(
                                                  'Browse city venues')),
                                        ]),
                                    const SizedBox(height: 20),
                                    Card(
                                        child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(Icons.wb_sunny_outlined,
                                                      color: colors.secondary,
                                                      size: 30),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                        Text(
                                                            'Best time to visit',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleMedium
                                                                ?.copyWith(
                                                                    color: colors
                                                                        .onSurface)),
                                                        const SizedBox(
                                                            height: 6),
                                                        Text(
                                                            destination
                                                                .bestTimeToVisit,
                                                            style: TextStyle(
                                                                color: colors
                                                                    .onSurface,
                                                                fontSize: 16))
                                                      ]))
                                                ]))),
                                    const SizedBox(height: 24),
                                    MyDayActions(
                                        destination: destination,
                                        controller: controller),
                                    const SizedBox(height: 20),
                                    Text('Top attractions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    const SizedBox(height: 6),
                                    const Text(
                                        'Open a place guide or use a sight as the first stop in your day.'),
                                    const SizedBox(height: 16),
                                    LayoutBuilder(
                                        builder: (context, constraints) {
                                      final width = constraints.maxWidth >= 700
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
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                                onTap: () => showPlaceInformation(
                                                                    context,
                                                                    destination,
                                                                    attraction:
                                                                        attraction,
                                                                    controller:
                                                                        controller),
                                                                child: SizedBox(
                                                                    height: 180,
                                                                    child: DestinationImage(
                                                                        url: attraction
                                                                            .imageUrl,
                                                                        label: attraction
                                                                            .name))),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16),
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          attraction
                                                                              .name,
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .titleMedium
                                                                              ?.copyWith(fontWeight: FontWeight.bold)),
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      Wrap(
                                                                          spacing:
                                                                              8,
                                                                          runSpacing:
                                                                              8,
                                                                          children: [
                                                                            OutlinedButton.icon(
                                                                                onPressed: () => showPlaceInformation(context, destination, attraction: attraction, controller: controller),
                                                                                icon: const Icon(Icons.menu_book_outlined, size: 18),
                                                                                label: const Text('View guide')),
                                                                            FilledButton.tonalIcon(
                                                                                onPressed: () => _plan(context, attraction: attraction.name),
                                                                                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                                                                                label: const Text('Plan a visit')),
                                                                            MyDayActions(
                                                                                destination: destination,
                                                                                controller: controller,
                                                                                name: attraction.name,
                                                                                placeId: '${destination.id}:sight:${attraction.name}',
                                                                                showReview: false),
                                                                          ]),
                                                                    ])),
                                                          ])))
                                          ]);
                                    }),
                                    const SizedBox(height: 28),
                                    const Divider(),
                                    const SizedBox(height: 20),
                                    TravelTools(destination: destination),
                                  ]))))),
            ));
  }
}
