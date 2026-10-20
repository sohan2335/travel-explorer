import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/experience/experience_controller.dart';
import 'package:travel_explorer/experience/splash_screen.dart';
import 'package:travel_explorer/screens/profile_screen.dart';
import 'package:travel_explorer/services/local_store.dart';

Future<void> launch(
  WidgetTester tester,
  ExperienceController experience, {
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    ExperienceScope(
      controller: experience,
      homeBuilder: () => const Scaffold(body: Text('Test Home')),
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: child!,
        ),
        home: SplashScreen(
          ready: Future.value(),
          readSession: () => Completer<Map<String, dynamic>?>().future,
        ),
      ),
    ),
  );
  await tester.pump();
  if (!reduced) {
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'offline network never holds splash; logged out sees existing login',
    (tester) async {
      final experience = ExperienceController(MemoryStore());
      addTearDown(experience.dispose);
      await launch(tester, experience);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.widget<ProfileScreen>(find.byType(ProfileScreen)).launchMode, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('reduced motion skips splash delays and transitions', (
    tester,
  ) async {
    final experience = ExperienceController(MemoryStore());
    addTearDown(experience.dispose);
    await launch(tester, experience, reduced: true);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('returning cached user can reach Home while offline', (
    tester,
  ) async {
    final store = MemoryStore();
    store.values[ExperienceController.lastUserKey] = 'alice';
    store.values[ExperienceController.keyFor('alice')] =
        '{"introDone":true,"preferencesDone":true}';
    final experience = ExperienceController(store);
    addTearDown(experience.dispose);
    await launch(tester, experience);
    expect(find.text('Test Home'), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
  });
}
