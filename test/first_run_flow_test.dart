import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/experience/experience_controller.dart';
import 'package:travel_explorer/experience/onboarding_screen.dart';
import 'package:travel_explorer/experience/preferences_screen.dart';
import 'package:travel_explorer/screens/profile_screen.dart';
import 'package:travel_explorer/services/local_store.dart';

void main() {
  testWidgets(
    'email login reuses existing requests then intro and preferences reach Home',
    (tester) async {
      final experience = ExperienceController(MemoryStore());
      addTearDown(experience.dispose);
      var signedIn = false;
      final paths = <String>[];
      Future<Map<String, dynamic>?> request(
        String path, [
        Map<String, dynamic>? data,
      ]) async {
        paths.add(path);
        if (path == 'sign-in/email') signedIn = true;
        return {
          'user': signedIn ? {'id': 'alice', 'name': 'Alice'} : null,
        };
      }

      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ExperienceScope(
          controller: experience,
          homeBuilder: () => const Scaffold(body: Text('Test Home')),
          child: MaterialApp(
            home: ProfileScreen(launchMode: true, request: request),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'test-pass-123',
      );
      await tester.scrollUntilVisible(
        find.text('Sign in'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(paths, ['get-session', 'sign-in/email', 'get-session']);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.byType(PreferencesScreen), findsOneWidget);
      await tester.tap(find.text('Skip for now'));
      await tester.pumpAndSettle();
      expect(find.text('Test Home'), findsOneWidget);
      expect(experience.introDone && experience.preferencesDone, isTrue);
      expect(experience.userId, 'alice');
      expect(tester.takeException(), isNull);
    },
  );
}
