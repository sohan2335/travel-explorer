import 'package:flutter/material.dart';

import '../state/travel_controller.dart';

/// The Search tab owns discovery filters. Home and Saved keep their full lists.
class DestinationSearchControls extends StatelessWidget {
  const DestinationSearchControls({
    super.key,
    required this.controller,
    required this.search,
    required this.focusNode,
    required this.onMatch,
  });

  final TravelController controller;
  final TextEditingController search;
  final FocusNode focusNode;
  final VoidCallback onMatch;

  void _reset() {
    search.clear();
    controller.clearFilters();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: search,
        focusNode: focusNode,
        onChanged: controller.setQuery,
        decoration: InputDecoration(
          labelText: 'Find your city',
          hintText: 'Try Goa or Jaipur',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear city search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    search.clear();
                    controller.setQuery('');
                  },
                ),
        ),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        key: ValueKey(controller.selectedCountry),
        initialValue: controller.selectedCountry ?? 'All countries',
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Country'),
        items: ['All countries', ...controller.countries]
            .map(
              (country) =>
                  DropdownMenuItem(value: country, child: Text(country)),
            )
            .toList(),
        onChanged: (value) =>
            controller.setCountry(value == 'All countries' ? null : value),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Text(
              'Destination type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          TextButton(
            onPressed: controller.hasFilters ? _reset : null,
            child: const Text('Reset filters'),
          ),
        ],
      ),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: controller.selectedCategory == null,
            onSelected: (_) => controller.setCategory(null),
          ),
          for (final category in controller.categories)
            ChoiceChip(
              label: Text(category),
              selected: controller.selectedCategory == category,
              onSelected: (selected) =>
                  controller.setCategory(selected ? category : null),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Icon(
            Icons.auto_awesome_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Match my trip'),
          subtitle: const Text('Find a city for your style, budget and time'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onMatch,
        ),
      ),
    ],
  );
}
