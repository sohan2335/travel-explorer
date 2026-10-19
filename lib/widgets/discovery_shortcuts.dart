import 'package:flutter/material.dart';
import 'dart:math' as math;

const discoveryLabels = {
  'restaurant': 'Dining',
  'movie': 'Movies',
  'event': 'Events',
  'mall': 'Shopping',
  'adventure': 'Activities',
  'play': 'Play',
  'salon': 'Salons',
  'hotel': 'Stays',
  'waterpark': 'Water parks'
};

const discoveryIcons = <String, IconData>{
  'hotel': Icons.bed_outlined,
  'restaurant': Icons.restaurant,
  'adventure': Icons.hiking,
  'waterpark': Icons.waves,
  'mall': Icons.shopping_bag_rounded,
  'movie': Icons.movie_rounded,
  'play': Icons.sports_esports_rounded,
  'salon': Icons.content_cut,
  'event': Icons.celebration_rounded,
  'plan': Icons.route
};
const discoveryColors = <String, Color>{
  'hotel': Color(0xFFC3AEFF),
  'restaurant': Color(0xFFFFBC84),
  'adventure': Color(0xFF8FE1BF),
  'waterpark': Color(0xFF8BD4FF),
  'mall': Color(0xFFF5A2DB),
  'movie': Color(0xFFA998FF),
  'play': Color(0xFF81E5BE),
  'salon': Color(0xFFDBB0F4),
  'event': Color(0xFFB5C5FF),
  'plan': Color(0xFFF3DF91)
};

class DiscoveryShortcuts extends StatelessWidget {
  const DiscoveryShortcuts(
      {super.key,
      required this.onSelected,
      this.selected,
      this.includePlan = true});
  final ValueChanged<String> onSelected;
  final String? selected;
  final bool includePlan;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final width = compact ? (constraints.maxWidth - 20) / 3 : 128.0;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final kind in [...discoveryLabels.keys, if (includePlan) 'plan'])
            SizedBox(
                width: width,
                height: 94 + MediaQuery.textScalerOf(context).scale(40),
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
                        TweenAnimationBuilder<double>(
                          key: ValueKey('$kind-${selected == kind}'),
                          tween: Tween(begin: 0, end: 1),
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 550),
                          builder: (context, progress, child) {
                            final bounce = math.sin(progress * math.pi);
                            return Transform.translate(
                                offset: Offset(0, -5 * bounce),
                                child: Transform.rotate(
                                    angle:
                                        .13 * math.sin(progress * math.pi * 2),
                                    child: Transform.scale(
                                        scale: 1 + .12 * bounce,
                                        child: child)));
                          },
                          child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        discoveryColors[kind]!
                                            .withValues(alpha: .28),
                                        discoveryColors[kind]!
                                            .withValues(alpha: .04)
                                      ]),
                                  boxShadow: [
                                    BoxShadow(
                                        color: discoveryColors[kind]!
                                            .withValues(
                                                alpha: selected == kind
                                                    ? .16
                                                    : .04),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4))
                                  ]),
                              child: Icon(discoveryIcons[kind],
                                  size: 44, color: discoveryColors[kind])),
                        ),
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
