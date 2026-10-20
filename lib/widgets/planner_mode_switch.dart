import 'package:flutter/material.dart';

class PlannerModeSwitch extends StatelessWidget {
  const PlannerModeSwitch({
    super.key,
    this.wholeTrip = false,
    required this.onDay,
    required this.onTrip,
  });
  final bool wholeTrip;
  final VoidCallback onDay, onTrip;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final item in [
          (false, Icons.today_outlined, 'Plan a day', 'One day out', onDay),
          (true, Icons.luggage_outlined, 'Plan whole trip', '2–7 days', onTrip),
        ])
          SizedBox(
            width: (constraints.maxWidth - 16) / 2,
            child: Semantics(
              selected: wholeTrip == item.$1,
              button: true,
              excludeSemantics: true,
              label: '${item.$3}, ${item.$4}',
              onTap: wholeTrip == item.$1 ? () {} : item.$5,
              child: Card(
                color: wholeTrip == item.$1
                    ? const Color(0xFF303034)
                    : const Color(0xFF1C1C20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: wholeTrip == item.$1
                        ? const Color(0xFFC3AEFF)
                        : const Color(0xFF333338),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: wholeTrip == item.$1 ? () {} : item.$5,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 136),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item.$2, color: const Color(0xFFC3AEFF)),
                          const SizedBox(height: 8),
                          Text(
                            item.$3,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(item.$4, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
