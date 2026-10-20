import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_explorer/experience/experience_controller.dart';
import 'package:travel_explorer/services/local_store.dart';

class BrokenStore implements LocalStore {
  @override
  Future<String?> read(String key) async => throw StateError('Unavailable');
  @override
  Future<void> write(String key, String value) async =>
      throw StateError('Unavailable');
}

void main() {
  test('intro/preferences are isolated by user and guest device', () async {
    final store = MemoryStore();
    store.values['travel_explorer.drafts.v1'] = 'existing drafts';
    final c = ExperienceController(store);
    addTearDown(c.dispose);
    await c.activate('alice');
    await c.completeIntro();
    await c.savePreferences({'movie', 'unknown'}, 'Relaxed', 'Friends');
    await c.activate(null); // Sign out, then another user signs in.
    expect(c.introDone, isFalse);
    expect(c.interests, isEmpty);
    await c.activate('bob');
    expect(c.introDone, isFalse);
    expect(c.preferencesDone, isFalse);
    await c.completeIntro();
    await c.savePreferences({}, null, null);
    await c.activate('alice');
    expect(c.introDone, isTrue);
    expect(c.interests, {'movie'});
    expect(c.tripStyle, 'Relaxed');
    expect(c.suggestedStops, 3);
    expect(c.suggestedMinutes, 120);
    expect(store.values['travel_explorer.drafts.v1'], 'existing drafts');
    expect(
      jsonDecode(
        store.values[ExperienceController.keyFor('bob')]!,
      )['interests'],
      isEmpty,
    );
  });
  test(
    'returning flags and optional preferences restore after reopening',
    () async {
      final store = MemoryStore();
      final c = ExperienceController(store);
      await c.activate('alice');
      await c.completeIntro();
      await c.savePreferences({'restaurant'}, 'Packed', 'Solo');
      c.dispose();
      final reopened = ExperienceController(store);
      addTearDown(reopened.dispose);
      await reopened.restoreHint();
      expect(reopened.userId, 'alice');
      expect(reopened.introDone && reopened.preferencesDone, isTrue);
      expect(reopened.suggestedStops, 5);
      expect(reopened.suggestedMinutes, 60);
    },
  );
  test('corrupt or unavailable storage does not prevent session use', () async {
    final store = MemoryStore();
    store.values[ExperienceController.keyFor('alice')] = 'bad json';
    final c = ExperienceController(store);
    addTearDown(c.dispose);
    await c.activate('alice');
    expect(c.introDone, isFalse);
    expect(c.message, isNotNull);
    final broken = ExperienceController(BrokenStore());
    addTearDown(broken.dispose);
    await broken.restoreHint();
    expect(await broken.savePreferences({'hotel'}, 'Balanced', null), isFalse);
    expect(broken.preferencesDone, isTrue);
    expect(broken.interests, {'hotel'});
  });
  test('onboarding images are compressed below 300 KB', () {
    for (final name in ['coast', 'city', 'hills']) {
      expect(
        File('assets/onboarding/$name.jpg').lengthSync(),
        lessThan(300000),
      );
    }
  });
}
