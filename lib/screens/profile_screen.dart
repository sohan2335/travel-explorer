import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../experience/experience_controller.dart';
import '../experience/flow_navigation.dart';
import '../experience/preferences_screen.dart';
import '../experience/onboarding_screen.dart';

typedef ProfileRequest =
    Future<Map<String, dynamic>?> Function(
      String path, [
      Map<String, dynamic>? data,
    ]);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.embedded = false,
    this.onExplore,
    this.launchMode = false,
    this.request = authRequest,
  });
  final ProfileRequest request;
  final bool embedded;
  final bool launchMode;
  final VoidCallback? onExplore;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _name = TextEditingController();
  bool _busy = true, _signup = false, _hide = true, _leaving = false;
  String? _message;
  Map<String, dynamic>? _user;
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final result = await widget.request('get-session');
      if (mounted && !_leaving) {
        setState(() => _user = result?['user'] as Map<String, dynamic>?);
        await _observeSession();
        if (mounted && widget.launchMode && _user != null && !_leaving) {
          _leaving = true;
          continueExperience(context);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _message =
              'Your sign-in session could not be completed. Please try Continue with Google again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _observeSession() async {
    final experience = ExperienceScope.maybeOf(context)?.controller;
    if (experience != null) {
      await experience.activate(_user?['id'] as String?, verified: true);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) {
        setState(() => _message = e.toString().replaceFirst('Bad state: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _emailLogin() async {
    if (!_form.currentState!.validate()) return;
    await _run(() async {
      await widget.request(_signup ? 'sign-up/email' : 'sign-in/email', {
        'email': _email.text.trim(),
        'password': _password.text,
        if (_signup) 'name': _name.text.trim(),
      });
      _password.clear();
      final result = await widget.request('get-session');
      if (mounted) {
        setState(() {
          _user = result?['user'] as Map<String, dynamic>?;
          if (_user == null) {
            _message =
                'Check your email for verification, then sign in. If already verified, allow session cookies and retry.';
          }
        });
        await _observeSession();
        if (mounted &&
            _user != null &&
            (widget.launchMode ||
                !(ExperienceScope.maybeOf(context)?.controller.introDone ??
                    true) ||
                !(ExperienceScope.maybeOf(
                      context,
                    )?.controller.preferencesDone ??
                    true))) {
          _leaving = true;
          continueExperience(context);
        }
      }
    });
  }

  Widget _preferenceLinks(BuildContext context) {
    if (widget.launchMode || ExperienceScope.maybeOf(context) == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Edit preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              experienceRoute(
                context,
                Builder(
                  builder: (pageContext) => PreferencesScreen(
                    editing: true,
                    onDone: () async => Navigator.pop(pageContext),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.replay),
            title: const Text('Replay intro'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              experienceRoute(
                context,
                Builder(
                  builder: (pageContext) => OnboardingScreen(
                    onDone: () async => Navigator.pop(pageContext),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: widget.embedded || widget.launchMode
        ? null
        : AppBar(title: const Text('Your profile')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 38,
              child: Icon(Icons.person_outline, size: 42),
            ),
            const SizedBox(height: 20),
            Text(
              _user == null
                  ? 'Your next day out starts here.'
                  : 'Hello, ${_user!['name'] ?? 'traveller'}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore freely as a guest. Your saved cities and trip drafts stay on this device; signing in does not sync them.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _preferenceLinks(context),
            const SizedBox(height: 16),
            if (_busy) const LinearProgressIndicator(),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(_message!, semanticsLabel: _message),
              ),
            if (_user != null) ...[
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text('${_user!['email'] ?? ''}'),
              ),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        await widget.request('sign-out', {});
                        if (mounted) {
                          setState(() => _user = null);
                          await _observeSession();
                        }
                      }),
                child: const Text('Sign out'),
              ),
            ] else ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
                onPressed: _busy
                    ? null
                    : () => _run(() async {
                        final result = await widget.request('sign-in/social', {
                          'provider': 'google',
                          'callbackURL': Uri.base
                              .replace(
                                fragment: '',
                                queryParameters: Map<String, String>.from(
                                  Uri.base.queryParameters,
                                )..remove('neon_auth_session_verifier'),
                              )
                              .toString(),
                          'disableRedirect': true,
                        });
                        final url = result?['url'];
                        if (url is! String) {
                          throw StateError('Google sign-in is unavailable.');
                        }
                        navigateToAuth(url);
                      }),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('or use your email', textAlign: TextAlign.center),
              ),
              Form(
                key: _form,
                child: Column(
                  children: [
                    if (_signup)
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Your name',
                        ),
                        validator: (s) => s == null || s.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (s) =>
                          s == null ||
                              !RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(s.trim())
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          tooltip: 'Show or hide password',
                          icon: Icon(
                            _hide ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator: (s) => s == null || s.length < 8
                          ? 'Use at least 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _emailLogin,
                      child: Text(_signup ? 'Create account' : 'Sign in'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _signup = !_signup;
                              _message = null;
                            }),
                      child: Text(
                        _signup
                            ? 'Already registered? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            TextButton(
              onPressed: widget.launchMode
                  ? () async {
                      if (_leaving) return;
                      _leaving = true;
                      await ExperienceScope.of(
                        context,
                      ).controller.activate(null);
                      if (context.mounted) continueExperience(context);
                    }
                  : widget.onExplore ?? () => Navigator.pop(context),
              child: Text(
                widget.launchMode ? 'Explore as guest' : 'Back to exploring',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
