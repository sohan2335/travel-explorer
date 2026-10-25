// Run manually: flutter test tool/record_demo_test.dart --reporter expanded
// Captures the real Flutter UI in an isolated demo session, never browser data.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_explorer/data/destinations.dart';
import 'package:travel_explorer/main.dart';
import 'package:travel_explorer/services/local_store.dart';
import 'package:travel_explorer/services/place_catalog.dart';

void main() {
  testWidgets('record feature walkthrough', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final rootKey = GlobalKey();
    final store = MemoryStore();
    final frames = <Map<String, dynamic>>[];
    final directory = Directory('../../work/demo-frames');
    const dryRun = bool.fromEnvironment('DEMO_DRY_RUN');
    await tester.runAsync(() => directory.create(recursive: true));
    var phase = 'intro';
    var frameIndex = 0;

    Future<void> capture(double duration, {Offset? tap}) async {
      if (dryRun) return;
      final fileName = 'frame_${(frameIndex++).toString().padLeft(5, '0')}.png';
      await tester.runAsync(() async {
        final boundary =
            rootKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '${directory.path}/$fileName',
        ).writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
      frames.add({
        'file': fileName,
        'phase': phase,
        'duration': duration,
        if (tap != null) 'tap': [tap.dx, tap.dy],
      });
      if (frameIndex % 50 == 0) {
        debugPrint('Captured $frameIndex frames ($phase)');
      }
    }

    Future<void> settle(double duration) async {
      await tester.pumpAndSettle();
      await capture(duration);
    }

    Future<void> swipe(Offset delta) async {
      final start = Offset(delta.dx == 0 ? 195 : 240, 490);
      final gesture = await tester.startGesture(start);
      for (var i = 0; i < 8; i++) {
        await gesture.moveBy(delta / 8);
        await tester.pump(const Duration(milliseconds: 55));
        await capture(.055);
      }
      await tester.pump(const Duration(milliseconds: 160));
      await gesture.up();
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 90));
        await capture(.09);
      }
      await tester.pumpAndSettle();
    }

    Future<void> reveal(Finder target) async {
      for (var i = 0; i < 16; i++) {
        if (target.evaluate().isNotEmpty) {
          final animation = Scrollable.ensureVisible(
            target.evaluate().first,
            duration: const Duration(milliseconds: 480),
            alignment: .35,
          );
          for (var step = 0; step < 8; step++) {
            await tester.pump(const Duration(milliseconds: 80));
            await capture(.08);
          }
          await animation;
          await tester.pumpAndSettle();
          return;
        } else {
          await swipe(const Offset(0, -340));
        }
      }
      throw StateError('Demo control did not become visible: $target');
    }

    Future<void> tap(
      Finder target, {
      double hold = 1.4,
      bool scroll = true,
    }) async {
      if (scroll) await reveal(target);
      final point = tester.getCenter(target.first);
      await capture(.18, tap: point);
      await tester.tap(target.first);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 80));
        await capture(.08);
      }
      await settle(hold);
    }

    Future<void> back({double hold = .8}) async {
      await tester.pageBack();
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 80));
        await capture(.08);
      }
      await settle(hold);
    }

    Future<void> showApp() async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: rootKey,
          child: TravelExplorerApp(store: store, showLaunchFlow: false),
        ),
      );
      await tester.pumpAndSettle();
    }

    await tester.runAsync(() => PlaceCatalog.load(offline: true));
    await showApp();
    await tester.runAsync(() async {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      // The headless renderer has no system fallback fonts by default.
      for (final font in [
        ('Segoe UI Symbol', 'seguisym.ttf'),
        ('Segoe UI Emoji', 'seguiemj.ttf'),
      ]) {
        final symbols = FontLoader(font.$1);
        final bytes = await File('C:/Windows/Fonts/${font.$2}').readAsBytes();
        symbols.addFont(Future.value(ByteData.sublistView(bytes)));
        await symbols.load();
      }
      await GoogleFonts.pendingFonts();
      final photos = destinations
          .take(6)
          .expand(
            (city) => [
              city.imageUrl,
              ...city.attractions.map((a) => a.imageUrl),
            ],
          )
          .toSet();
      for (final photo in photos) {
        await precacheImage(AssetImage(photo), rootKey.currentContext!);
      }
    });
    await settle(6);

    phase = 'discovery';
    await capture(2.5);
    for (var i = 0; i < 5; i++) {
      await swipe(const Offset(-296, 0));
      await settle(i == 1 || i == 3 || i == 4 ? 2.4 : .6);
    }
    await swipe(const Offset(1480, 0));
    await settle(.8);

    phase = 'search';
    await tap(find.text('Search'), scroll: false, hold: 1.1);
    final search = find.widgetWithText(TextField, 'Find your city');
    for (final text in ['G', 'GO', 'GOA']) {
      await tester.enterText(search, text);
      await tester.pumpAndSettle();
      await capture(.55);
    }
    await tap(find.widgetWithText(ChoiceChip, 'Beaches'), hold: 1.5);
    await reveal(find.text('1 cities to explore'));
    await settle(1.5);
    await tap(find.widgetWithText(ChoiceChip, 'Mountains'), hold: 1.3);
    await reveal(find.text('No destinations found'));
    await settle(2.6);
    await tap(find.widgetWithText(ChoiceChip, 'Beaches'), hold: .7);
    await reveal(find.text('1 cities to explore'));
    await settle(1.6);

    phase = 'details';
    await tap(find.text('Home'), scroll: false, hold: .6);
    await tap(find.byTooltip('Open Goa city guide'), hold: 2);
    await reveal(find.text('Best time to visit'));
    await settle(3.2);
    await reveal(find.text('Top attractions'));
    await settle(1.1);
    for (final name in ['Palolem Beach', 'Fort Aguada', 'Fontainhas']) {
      await reveal(find.text(name).last);
      await settle(2.6);
    }
    await tap(find.text('View guide').last, hold: 1);
    await settle(1.4);
    await tap(
      find.byTooltip('Close place information'),
      scroll: false,
      hold: .4,
    );

    phase = 'saved';
    await tap(find.byTooltip('Save Goa'), scroll: false, hold: 1.4);
    await back(hold: .4);
    await tap(find.text('Saved'), scroll: false, hold: 2.2);
    expect(find.text('1 saved places'), findsOneWidget);
    await tap(find.byTooltip('Remove Goa'), hold: 2);
    expect(find.text('No saved cities yet'), findsOneWidget);
    await tap(find.text('Home'), scroll: false, hold: .3);
    await tap(find.byTooltip('Save Goa'), scroll: false, hold: .3);
    // Recreate app state from the same isolated JSON store to demonstrate restore.
    await tester.pumpWidget(const SizedBox());
    await showApp();
    await tap(find.text('Saved'), scroll: false, hold: 2.4);
    expect(find.text('1 saved places'), findsOneWidget);

    phase = 'matcher';
    await tap(find.text('Search'), scroll: false, hold: .7);
    await tap(find.text('Match my trip'), hold: 1.3);
    await tap(find.byKey(const ValueKey('matcher-type-Mountains')), hold: 1);
    await tap(find.byKey(const ValueKey('matcher-budget-budget')), hold: 1);
    await tap(find.byType(DropdownButtonFormField<int>), hold: .6);
    await tap(find.text('4 days').last, scroll: false, hold: 1);
    await tap(find.text('Find my matches'), hold: 1);
    await reveal(find.text('3/3 preferences matched'));
    await settle(4);
    await reveal(find.byKey(const ValueKey('matcher-explore-manali')));
    await settle(2.2);
    await back(hold: .6);

    phase = 'day';
    await tap(find.text('Home'), scroll: false, hold: .4);
    await tap(find.text('Goa').first, hold: 1.2);
    await tap(find.text('Explore Goa'), hold: 1.2);
    await reveal(find.text('Sights & city guide'));
    await settle(1);
    await tap(find.widgetWithText(OutlinedButton, 'Dining'), hold: 1.2);
    await reveal(find.text('The Fisherman’s Wharf, Panjim'));
    await settle(2.4);
    await tap(find.text('Sights & city guide'), hold: .5);
    await tap(find.text('Plan your visit'), scroll: false, hold: 1.8);
    await tap(find.text('Create my day plan'), hold: .9);
    await reveal(find.text('Your day, at a glance'));
    await settle(2.5);
    await swipe(const Offset(0, -360));
    await settle(1.5);
    await tap(find.text('Save trip draft'), hold: 1.5);

    phase = 'trip';
    await tap(find.text('Plan whole trip'), hold: 2);
    await tap(find.text('3 days'), hold: 1.2);
    await reveal(find.text('Edit day 2'));
    await settle(2.5);
    await tap(find.text('Save whole trip'), scroll: false, hold: 2.4);

    phase = 'approach';
    await back(hold: .4);
    await back(hold: .4);
    await back(hold: .4);
    await tap(find.byTooltip('Close city'), scroll: false, hold: .4);
    await tap(find.text('Home'), scroll: false, hold: 8);

    if (!dryRun) {
      await tester.runAsync(
        () => File(
          '../../work/demo-frames/frames.json',
        ).writeAsString(jsonEncode(frames)),
      );
    }
    expect(tester.takeException(), isNull);
    debugPrint('DEMO CAPTURE COMPLETE: ${frames.length} frames');
  }, timeout: const Timeout(Duration(minutes: 15)));
}
