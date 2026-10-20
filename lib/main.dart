import 'package:flutter/material.dart';

import 'data/destinations.dart';
import 'theme/app_theme.dart';
import 'experience/experience_controller.dart';
import 'experience/splash_screen.dart';
import 'screens/explorer_screen.dart';
import 'state/travel_controller.dart';
import 'services/local_store.dart';

void main() => runApp(const TravelExplorerApp());

class TravelExplorerApp extends StatefulWidget {
  const TravelExplorerApp({
    super.key,
    this.controller,
    this.store,
    this.showLaunchFlow = true,
    this.readSession,
  });

  final TravelController? controller;
  final LocalStore? store;
  final bool showLaunchFlow;
  final SessionReader? readSession;

  @override
  State<TravelExplorerApp> createState() => _TravelExplorerAppState();
}

class _TravelExplorerAppState extends State<TravelExplorerApp> {
  late TravelController _controller;
  late Future<void> _ready;
  late ExperienceController _experience;

  void _prepareController() {
    final store = widget.store ?? DeviceStore();
    _experience = ExperienceController(store);
    _controller =
        widget.controller ?? TravelController(destinations, store: store);
    _ready = widget.controller == null ? _controller.restore() : Future.value();
  }

  @override
  void initState() {
    super.initState();
    _prepareController();
  }

  @override
  void didUpdateWidget(TravelExplorerApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.store != widget.store) {
      if (oldWidget.controller == null) _controller.dispose();
      _experience.dispose();
      _prepareController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _experience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExperienceScope(
      controller: _experience,
      homeBuilder: () => ExplorerScreen(controller: _controller),
      child: MaterialApp(
        title: 'Travel Explorer',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark(),
        home: widget.showLaunchFlow
            ? SplashScreen(ready: _ready, readSession: widget.readSession)
            : FutureBuilder<void>(
                future: _ready,
                builder: (context, snapshot) =>
                    snapshot.connectionState == ConnectionState.done
                    ? ExplorerScreen(controller: _controller)
                    : const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      ),
              ),
      ),
    );
  }
}
