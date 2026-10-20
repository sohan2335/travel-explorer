import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import 'experience_controller.dart';
import 'flow_navigation.dart';

typedef SessionReader = Future<Map<String, dynamic>?> Function();

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.ready, this.readSession});
  final Future<void> ready;
  final SessionReader? readSession;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    reverseDuration: const Duration(milliseconds: 400),
  );
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _launch();
    }
  }

  Future<void> _launch() async {
    final elapsed = Stopwatch()..start();
    final scope = ExperienceScope.of(context);
    final experience = scope.controller;
    final localReady = Future.wait([
      widget.ready.catchError((Object _) {}),
      experience.restoreHint(),
    ]).timeout(const Duration(milliseconds: 2600), onTimeout: () => []);
    // Authentication runs in the background. An offline request never holds the splash.
    final authCallback = Uri.base.queryParameters.containsKey(
      'neon_auth_session_verifier',
    );
    if (!authCallback) {
      unawaited(() async {
        try {
          final result =
              await (widget.readSession?.call() ?? authRequest('get-session'));
          if (!mounted) return;
          final user = result?['user'];
          await experience.activate(
            user is Map ? user['id'] as String? : null,
            verified: true,
          );
        } catch (_) {
          /* Offline: use only the local launch hint, not an auth claim. */
        }
      }());
    }
    try {
      if (!MediaQuery.disableAnimationsOf(context)) {
        await _animation.forward().orCancel;
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        await localReady;
        final remaining = 2600 - elapsed.elapsedMilliseconds;
        if (remaining > 0) {
          await experience.identityReady.timeout(
            Duration(milliseconds: remaining),
            onTimeout: () {},
          );
        }
        await _animation.reverse().orCancel;
      } else {
        await localReady;
      }
      if (!mounted) return;
      if (experience.userId != null && !authCallback) {
        continueExperience(context);
      } else {
        replaceExperience(context, const ProfileScreen(launchMode: true));
      }
    } on TickerCanceled {
      /* Screen was disposed. */
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _animation,
            child: ScaleTransition(
              scale: Tween(begin: .85, end: 1.0).animate(
                CurvedAnimation(parent: _animation, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/branding/compass.png',
                      width: 144,
                      height: 144,
                      excludeFromSemantics: true,
                    ),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animation,
                        curve: const Interval(.25, 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Travel Explorer',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text('Your city, your way'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
