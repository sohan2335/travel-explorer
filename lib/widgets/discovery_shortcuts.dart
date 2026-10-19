import 'package:flutter/material.dart';
import '../models/local_place.dart';

const discoveryLabels = {...placeKinds, 'event': 'Events'};

const discoveryIcons = <String, IconData>{
  'hotel': Icons.bed_outlined,
  'restaurant': Icons.restaurant,
  'adventure': Icons.hiking,
  'waterpark': Icons.waves,
  'mall': Icons.shopping_bag_outlined,
  'event': Icons.celebration_outlined,
  'plan': Icons.route
};
const discoveryColors = <String, Color>{
  'hotel': Color(0xFFC3AEFF),
  'restaurant': Color(0xFFFFBC84),
  'adventure': Color(0xFF8FE1BF),
  'waterpark': Color(0xFF8BD4FF),
  'mall': Color(0xFFF5A2DB),
  'event': Color(0xFFB5C5FF),
  'plan': Color(0xFFF3DF91)
};

class DiscoveryShortcuts extends StatelessWidget {
  const DiscoveryShortcuts(
      {super.key, required this.onSelected, this.selected});
  final ValueChanged<String> onSelected;
  final String? selected;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final width = compact ? (constraints.maxWidth - 20) / 3 : 100.0;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final kind in [...discoveryLabels.keys, 'plan'])
            SizedBox(
                width: width,
                height: compact ? 96 : 105,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      backgroundColor: discoveryColors[kind]!
                          .withValues(alpha: selected == kind ? .2 : .07),
                      side: BorderSide(
                          color: discoveryColors[kind]!
                              .withValues(alpha: selected == kind ? 1 : .2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: () => onSelected(kind),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(discoveryIcons[kind],
                            size: 30, color: discoveryColors[kind]),
                        const SizedBox(height: 8),
                        Text(discoveryLabels[kind] ?? 'Day plan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: discoveryColors[kind], fontSize: 12)),
                      ]),
                )),
        ]);
      });
}
