import 'package:flutter/material.dart';

import 'data/destinations.dart';
import 'screens/explorer_screen.dart';
import 'state/travel_controller.dart';
import 'services/local_store.dart';

void main() => runApp(const TravelExplorerApp());

class TravelExplorerApp extends StatefulWidget {
  const TravelExplorerApp({super.key, this.controller, this.store});

  final TravelController? controller;
  final LocalStore? store;

  @override
  State<TravelExplorerApp> createState() => _TravelExplorerAppState();
}

class _TravelExplorerAppState extends State<TravelExplorerApp> {
  late TravelController _controller;
  late Future<void> _ready;

  void _prepareController() {
    _controller = widget.controller ??
        TravelController(destinations, store: widget.store ?? DeviceStore());
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
      _prepareController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFAD85FF),
            brightness: Brightness.dark,
            primary: const Color(0xFFC3AEFF),
            secondary: const Color(0xFFFFC78D),
            surface: const Color(0xFF19191C),
            onSurfaceVariant: const Color(0xFFCECED5),
            surfaceContainerHighest: const Color(0xFF303034),
            onSurface: const Color(0xFFF7F7F8)),
        scaffoldBackgroundColor: const Color(0xFF0E0E10),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0E0E10), scrolledUnderElevation: 0),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12))),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12))),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
        cardTheme: CardThemeData(
            color: const Color(0xFF1C1C20),
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFF333338)))),
        navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Color(0xFF18181B),
            indicatorColor: Color(0xFF554478)),
        inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Color(0xFF222226),
            contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                borderSide: BorderSide(color: Color(0xFF414147)))),
      ),
      home: FutureBuilder<void>(
          future: _ready,
          builder: (context, snapshot) =>
              snapshot.connectionState == ConnectionState.done
                  ? ExplorerScreen(controller: _controller)
                  : const Scaffold(
                      body: Center(child: CircularProgressIndicator()))),
    );
  }
}
