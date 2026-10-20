import 'package:flutter/material.dart';

const introPages = [
  (
    'coast',
    'Your city, your way',
    'Stays, food and little adventures in one place.',
  ),
  ('city', 'Pick your places', 'Save spots as you browse and build your day.'),
  (
    'hills',
    'Plan it simply',
    'Order your stops, check timing, share the plan.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});
  final Future<void> Function() onDone;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _index = 0;
  bool _busy = false;
  Future<void> _finish() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onDone();
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _next() {
    if (_index == 2) {
      _finish();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(_index + 1);
    } else {
      _pages.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final page = introPages[_index];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView(
            controller: _pages,
            onPageChanged: (index) => setState(() => _index = index),
            children: [
              for (final item in introPages)
                Image.asset(
                  'assets/onboarding/${item.$1}.jpg',
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Color(0xFF19191C)),
                ),
            ],
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, .35, .65, 1],
                  colors: [
                    Color(0x880E0E10),
                    Color(0x220E0E10),
                    Color(0xDE0E0E10),
                    Color(0xFF0E0E10),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'Introduction page ${_index + 1} of 3',
                          child: Row(
                            children: [
                              for (var i = 0; i < 3; i++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: AnimatedContainer(
                                      duration: reduced
                                          ? Duration.zero
                                          : const Duration(milliseconds: 200),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        color: i == _index
                                            ? const Color(0xFFC3AEFF)
                                            : const Color(0xFF414147),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _finish,
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: reduced
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, .08),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Column(
                            key: ValueKey(_index),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TRAVEL EXPLORER',
                                style: TextStyle(
                                  color: Color(0xFFFFC78D),
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page.$2,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      height: 1.15,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                page.$3,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _next,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _index == 2 ? 'Get started' : 'Continue',
                            ),
                          ),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
