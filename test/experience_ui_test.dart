import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/experience/onboarding_screen.dart';
import 'package:travel_explorer/experience/preferences_screen.dart';
import 'package:travel_explorer/experience/experience_controller.dart';
import 'package:travel_explorer/services/local_store.dart';

void main() {
  testWidgets('preferences accept zero selections', (tester) async {
    final experience = ExperienceController(MemoryStore());
    addTearDown(experience.dispose);
    var finished = false;
    await tester.pumpWidget(
      ExperienceScope(
        controller: experience,
        homeBuilder: () => const SizedBox(),
        child: MaterialApp(
          home: PreferencesScreen(
            onDone: () async {
              finished = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Save preferences'));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
    expect(experience.preferencesDone, isTrue);
    expect(experience.interests, isEmpty);
    expect(experience.tripStyle, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'skip preferences keeps saved choices and allows small portrait',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final experience = ExperienceController(MemoryStore());
      addTearDown(experience.dispose);
      await experience.savePreferences({'movie'}, 'Relaxed', 'Friends');
      await tester.pumpWidget(
        ExperienceScope(
          controller: experience,
          homeBuilder: () => const SizedBox(),
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: PreferencesScreen(onDone: () async {}),
          ),
        ),
      );
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
      expect(experience.interests, {'movie'});
      expect(experience.tripStyle, 'Relaxed');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('intro has three pages and completes once', (tester) async {
    var finished = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onDone: () async {
            finished++;
          },
        ),
      ),
    );
    expect(find.text('Your city, your way'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Pick your places'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Plan it simply'), findsOneWidget);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(finished, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'intro skips directly and supports small landscape with large text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 320));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var skipped = false;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: OnboardingScreen(
            onDone: () async {
              skipped = true;
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(skipped, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
