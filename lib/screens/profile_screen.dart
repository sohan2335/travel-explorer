import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embedded = false, this.onExplore});
  final bool embedded;
  final VoidCallback? onExplore;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _name = TextEditingController();
  bool _busy = true, _signup = false, _hide = true;
  String? _message;
  Map<String, dynamic>? _user;
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final result = await authRequest('get-session');
      if (mounted) {
        setState(() => _user = result?['user'] as Map<String, dynamic>?);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message =
            'Your sign-in session could not be completed. Please try Continue with Google again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
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
      await authRequest(_signup ? 'sign-up/email' : 'sign-in/email', {
        'email': _email.text.trim(),
        'password': _password.text,
        if (_signup) 'name': _name.text.trim()
      });
      _password.clear();
      final result = await authRequest('get-session');
      if (mounted) {
        setState(() {
          _user = result?['user'] as Map<String, dynamic>?;
          if (_user == null) {
            _message =
                'Check your email for verification, then sign in. If already verified, allow session cookies and retry.';
          }
        });
      }
    });
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
        appBar:
            widget.embedded ? null : AppBar(title: const Text('Your profile')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  const CircleAvatar(
                      radius: 38, child: Icon(Icons.person_outline, size: 42)),
                  const SizedBox(height: 20),
                  Text(
                      _user == null
                          ? 'Your next day out starts here.'
                          : 'Hello, ${_user!['name'] ?? 'traveller'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  const Text(
                      'Explore freely as a guest. Your saved cities and trip drafts stay on this device; signing in does not sync them.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (_busy) const LinearProgressIndicator(),
                  if (_message != null)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(_message!, semanticsLabel: _message)),
                  if (_user != null) ...[
                    ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: Text('${_user!['email'] ?? ''}')),
                    FilledButton(
                        onPressed: _busy
                            ? null
                            : () => _run(() async {
                                  await authRequest('sign-out', {});
                                  if (mounted) setState(() => _user = null);
                                }),
                        child: const Text('Sign out')),
                  ] else ...[
                    OutlinedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text('Continue with Google'),
                        onPressed: _busy
                            ? null
                            : () => _run(() async {
                                  final result =
                                      await authRequest('sign-in/social', {
                                    'provider': 'google',
                                    'callbackURL': Uri.base
                                        .replace(
                                            fragment: '',
                                            queryParameters: Map<String,
                                                    String>.from(
                                                Uri.base.queryParameters)
                                              ..remove(
                                                  'neon_auth_session_verifier'))
                                        .toString(),
                                    'disableRedirect': true
                                  });
                                  final url = result?['url'];
                                  if (url is! String) {
                                    throw StateError(
                                        'Google sign-in is unavailable.');
                                  }
                                  navigateToAuth(url);
                                })),
                    const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('or use your email',
                            textAlign: TextAlign.center)),
                    Form(
                        key: _form,
                        child: Column(children: [
                          if (_signup)
                            TextFormField(
                                controller: _name,
                                decoration: const InputDecoration(
                                    labelText: 'Your name'),
                                validator: (s) => s == null || s.trim().isEmpty
                                    ? 'Enter your name'
                                    : null),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              validator: (s) => s == null ||
                                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                          .hasMatch(s.trim())
                                  ? 'Enter a valid email'
                                  : null),
                          const SizedBox(height: 12),
                          TextFormField(
                              controller: _password,
                              obscureText: _hide,
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                      tooltip: 'Show or hide password',
                                      icon: Icon(_hide
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () =>
                                          setState(() => _hide = !_hide))),
                              validator: (s) => s == null || s.length < 8
                                  ? 'Use at least 8 characters'
                                  : null),
                          const SizedBox(height: 20),
                          FilledButton(
                              onPressed: _busy ? null : _emailLogin,
                              child:
                                  Text(_signup ? 'Create account' : 'Sign in')),
                          TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => setState(() {
                                        _signup = !_signup;
                                        _message = null;
                                      }),
                              child: Text(_signup
                                  ? 'Already registered? Sign in'
                                  : 'New here? Create an account')),
                        ])),
                  ],
                  TextButton(
                      onPressed:
                          widget.onExplore ?? () => Navigator.pop(context),
                      child: const Text('Back to exploring')),
                ]))),
      );
}
