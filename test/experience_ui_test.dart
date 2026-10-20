import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/experience/onboarding_screen.dart';

void main() {
  testWidgets('intro has three pages and completes once', (tester) async {
    var finished = 0;
    await tester.pumpWidget(MaterialApp(home: OnboardingScreen(onDone: () async { finished++; })));
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
  testWidgets('intro skips directly and supports small landscape with large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(640, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var skipped = false;
    await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3), disableAnimations: true), child: child!),
      home: OnboardingScreen(onDone: () async { skipped = true; })));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(skipped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
