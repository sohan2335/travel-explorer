import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/local_store.dart';

const interestIds = [
  'restaurant',
  'movie',
  'event',
  'mall',
  'adventure',
  'play',
  'salon',
  'hotel',
  'waterpark',
];
const tripStyles = ['Relaxed', 'Balanced', 'Packed'];
const travelGroups = ['Solo', 'Friends', 'Family', 'Couple'];

/// Separate keys protect the app's existing cities, drafts and day picks.
class ExperienceController extends ChangeNotifier {
  ExperienceController(this.store);
  final LocalStore store;
  static const lastUserKey = 'travel_explorer.launch_user.v1';
  String? userId;
  bool sessionKnown = false, introDone = false, preferencesDone = false;
  Set<String> interests = {};
  String? tripStyle, company, message;
  int _revision = 0;
  bool _disposed = false;
  Future<void> _writes = Future.value();
  Future<void> identityReady = Future.value();

  String get key => keyFor(userId);
  static String keyFor(String? id) =>
      'travel_explorer.experience.v1.${Uri.encodeComponent(id ?? 'device')}';
  int get suggestedStops => switch (tripStyle) {
    'Relaxed' => 3,
    'Packed' => 5,
    _ => 4,
  };
  int get suggestedMinutes => switch (tripStyle) {
    'Relaxed' => 120,
    'Packed' => 60,
    _ => 90,
  };

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> restoreHint() async {
    final revision = _revision;
    try {
      final id = await store
          .read(lastUserKey)
          .timeout(const Duration(seconds: 2));
      if (revision == _revision) {
        await activate(id == null || id.isEmpty ? null : id, remember: false);
      }
    } catch (_) {
      message =
          'Preferences are available for this session. Device storage could not be read.';
      _notify();
    }
  }

  /// Only a non-secret ID is cached. This is an offline UI hint, never authentication.
  Future<void> activate(
    String? id, {
    bool remember = true,
    bool verified = false,
  }) => identityReady = _activate(id, remember: remember, verified: verified);

  Future<void> _activate(
    String? id, {
    required bool remember,
    required bool verified,
  }) async {
    final revision = ++_revision;
    userId = id;
    if (verified) sessionKnown = true;
    introDone = false;
    preferencesDone = false;
    interests = {};
    tripStyle = null;
    company = null;
    _notify();
    try {
      final raw = await store
          .read(keyFor(id))
          .timeout(const Duration(seconds: 2));
      if (revision != _revision || _disposed) return;
      if (raw != null) {
        final row = jsonDecode(raw) as Map<String, dynamic>;
        introDone = row['introDone'] == true;
        preferencesDone = row['preferencesDone'] == true;
        interests = (row['interests'] as List? ?? [])
            .whereType<String>()
            .where(interestIds.contains)
            .toSet();
        tripStyle = tripStyles.contains(row['tripStyle'])
            ? row['tripStyle'] as String
            : null;
        company = travelGroups.contains(row['company'])
            ? row['company'] as String
            : null;
      }
      if (remember) await _write(lastUserKey, id ?? '');
    } catch (_) {
      if (revision == _revision) {
        message =
            'Preferences could not be restored. You can continue without them.';
      }
    }
    _notify();
  }

  Future<bool> _write(String key, String value) async {
    final task = _writes.then(
      (_) => store.write(key, value).timeout(const Duration(seconds: 2)),
    );
    _writes = task.catchError((Object _) {});
    try {
      await task;
      return true;
    } catch (_) {
      message =
          'Could not save preferences on this device. Your choices still work for this session.';
      _notify();
      return false;
    }
  }

  Future<bool> _save() => _write(
    key,
    jsonEncode({
      'introDone': introDone,
      'preferencesDone': preferencesDone,
      'interests': interests.toList(),
      'tripStyle': tripStyle,
      'company': company,
    }),
  );
  Future<bool> completeIntro() async {
    introDone = true;
    _notify();
    return _save();
  }

  Future<bool> savePreferences(
    Set<String> values,
    String? style,
    String? group,
  ) async {
    interests = values.where(interestIds.contains).toSet();
    tripStyle = tripStyles.contains(style) ? style : null;
    company = travelGroups.contains(group) ? group : null;
    preferencesDone = true;
    _notify();
    return _save();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class ExperienceScope extends InheritedNotifier<ExperienceController> {
  const ExperienceScope({
    super.key,
    required ExperienceController controller,
    required this.homeBuilder,
    required super.child,
  }) : super(notifier: controller);
  final Widget Function() homeBuilder;
  ExperienceController get controller => notifier!;
  static ExperienceScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExperienceScope>();
  static ExperienceScope of(BuildContext context) => maybeOf(context)!;
}
