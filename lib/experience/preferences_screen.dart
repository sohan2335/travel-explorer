import 'package:flutter/material.dart';
import '../widgets/discovery_shortcuts.dart';
import 'experience_controller.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({
    super.key,
    required this.onDone,
    this.editing = false,
  });
  final Future<void> Function() onDone;
  final bool editing;
  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  Set<String> _interests = {};
  String? _style, _company;
  bool _loaded = false, _busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final saved = ExperienceScope.of(context).controller;
      _interests = {...saved.interests};
      _style = saved.tripStyle;
      _company = saved.company;
    }
  }

  Future<void> _save({bool skip = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final saved = ExperienceScope.of(context).controller;
    final ok = await saved.savePreferences(
      skip ? saved.interests : _interests,
      skip ? saved.tripStyle : _style,
      skip ? saved.company : _company,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (skip
                    ? 'You can set preferences later in your profile.'
                    : 'Preferences saved.')
              : saved.message!,
        ),
      ),
      snackBarAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
    );
    await widget.onDone();
  }

  Widget _group(
    BuildContext context,
    String title,
    Widget child, {
    String? hint,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (hint != null) ...[const SizedBox(height: 8), Text(hint)],
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.editing ? 'Edit preferences' : 'Tell us what you like',
      ),
      automaticallyImplyLeading: widget.editing,
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: _busy ? null : () => _save(),
              child: const Text('Save preferences'),
            ),
            TextButton(
              onPressed: _busy ? null : () => _save(skip: true),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'All optional. Change your choices anytime in your profile.',
            ),
            const SizedBox(height: 24),
            _group(
              context,
              'What do you enjoy?',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final kind in interestIds)
                    FilterChip(
                      label: Text(discoveryLabels[kind]!),
                      avatar: Icon(
                        discoveryIcons[kind],
                        size: 20,
                        color: discoveryColors[kind],
                      ),
                      selected: _interests.contains(kind),
                      selectedColor: discoveryColors[kind]!.withValues(
                        alpha: .2,
                      ),
                      backgroundColor: const Color(0xFF222226),
                      onSelected: _busy
                          ? null
                          : (selected) => setState(() {
                              selected
                                  ? _interests.add(kind)
                                  : _interests.remove(kind);
                            }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _group(
              context,
              'Trip style',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final style in tripStyles)
                    ChoiceChip(
                      label: Text(style),
                      selected: _style == style,
                      selectedColor: const Color(0x33C3AEFF),
                      onSelected: _busy
                          ? null
                          : (selected) => setState(
                              () => _style = selected ? style : null,
                            ),
                    ),
                ],
              ),
              hint:
                  'Suggests a pace for new plans. Your saved plans stay as they are.',
            ),
            const SizedBox(height: 16),
            _group(
              context,
              'Who are you usually with?',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in travelGroups)
                    ChoiceChip(
                      label: Text(group),
                      selected: _company == group,
                      selectedColor: const Color(0x33C3AEFF),
                      onSelected: _busy
                          ? null
                          : (selected) => setState(
                              () => _company = selected ? group : null,
                            ),
                    ),
                ],
              ),
              hint:
                  'Saved as planning context; it does not filter venue suitability.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}
