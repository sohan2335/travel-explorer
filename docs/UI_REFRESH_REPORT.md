# UI refresh and bug report — 20 October 2026

Work is on local branch `ui-refresh`. The original work was saved in `6ee6c33` before changes. Phase 1 is `c46f699`; Phase 2 is `5951048`; Phase 3 is the commit containing this report. Nothing from this refresh has been pushed.

## Result

- Home starts with a friendly greeting and large horizontal city photo cards. Tap the photo to choose a city, its heart to save, or its arrow to open the guide. Activities stay disabled until a city is chosen.
- Dark colours and category accents are unchanged. Poppins headings and Lato body fonts are bundled with their licences; runtime font downloads are disabled.
- Guides have a large hero photo, rounded dark content sheet, persistent overlaid back/save controls, readable season information and attraction actions.
- Home / Saved / Search / My day are directly accessible in the floating navigation bar. The My day tab opens existing city picks and saved drafts through the original controller.
- Adding consistently says “Add to my day”. The five-outing limit, compact introduction, info sheet, venue picker, custom fallback and Maps route checks remain available.

## Bugs found and fixed

1. The venue sheet could overflow when the mobile keyboard appeared. Its height now uses the available space after the keyboard inset. A keyboard regression test passes.
2. Moving guide controls onto the hero initially made Back scroll out of reach. Back and Save now stay overlaid while scrolling; the existing large-text navigation test catches this regression.
3. The latest google_fonts major version used a different Material TextTheme type, causing compile errors. Version 8.0.2 matches this app's existing Flutter imports. cached_network_image is fixed at 3.4.1 for the same compatibility reason.
4. A new transitive Apple implementation triggered a Windows native-assets compiler failure with the SDK's space-containing path. The committed lockfile selects path_provider_foundation 2.3.2. This adds no extra direct dependency; preserve the lockfile and avoid upgrading dependencies before submission.

## Verification

- Phase 1: Flutter analyzer run, 28 tests passed, web release build passed; browser Home loaded with disabled city-dependent activities.
- Phase 2: Flutter analyzer run, 29 tests passed (including keyboard resizing), web release build passed.
- Phase 3: Flutter analyzer run, 31 tests passed, web release build passed; core day-plan arithmetic/validation, URL encoding and destination-integrity checks passed.
- Phone-sized widget checks use 390×844 and 1.5× text scaling. They cover guide navigation, planner creation, saving/removing cities, Search isolation, the picker source ID and the five-stop limit. Added checks cover direct My day access and named missing-photo placeholders.
- Live browser: checked desktop and 390×844 phone layouts, card arrow → guide, persistent guide controls after scrolling, My day navigation, existing persisted picks, a live Goa venue search for Fort Aguada, and the existing signed-in profile after reload. Screenshots are in `docs/screenshots/ui-refresh-*`.
- SHA-256 comparisons against the saved baseline confirmed that all tracked data, models, auth, storage, networking, controller, backend and venue-data files are unchanged.
- Solid text contrast on the lightest specified dark surface (#303034): body #F7F7F8 = 12.27:1; secondary body #CECED5 = 8.39:1; purple #C3AEFF = 6.77:1. This is a solid-colour check, not a pixel-by-pixel certification of photos. Photo captions use a dark bottom gradient.
- Buttons use a minimum 48×48 target. Disabled activity tiles are visibly dimmer and reduced-motion settings are respected by the existing icon animation.

## Remaining limits / skipped work

- **Coordinates:** the existing venue and sight models supply no verified coordinates. The picker preserves source IDs and names, but cannot attach coordinates without changing protected data/models. Maps uses names plus city context. No distance or road-time claim was added.
- **Analyzer:** there are 36 existing informational lint notices, with zero errors and zero warnings. They are in protected models/services/controller or the existing core-check tool. UI brace notices were fixed; protected code was left intact. `flutter analyze --no-fatal-infos` succeeds; plain `flutter analyze` reports the info notices.
- **Web compiler:** it emits a CupertinoIcons font-family diagnostic while successfully building. This app uses Material icons; screenshots show those icons correctly. No extra icon package was added.
- **Platforms/auth:** Android build and fresh install were not tested because no Android SDK is available. A fresh Google/email sign-in was not performed during this presentation-only refresh; existing auth code is byte-for-byte unchanged. Repeat real sign-in before submission.
- **Caching:** cached_network_image has limited web caching support; do not claim persistent offline remote photos. Bundled photos and named placeholders remain available.
- Booking, prices, messaging and ratings were omitted as requested. No new city/venue records or backend features were added.

## Files changed

- `lib/main.dart`: use the shared theme and force dark mode.
- `lib/theme/app_theme.dart`: existing colour values, typography, shared component spacing and minimum controls.
- `lib/screens/explorer_screen.dart`: Home carousel, greeting, direct My day tab, floating navigation and rounded guide layout.
- `lib/widgets/destination_image.dart`: allowed image package, dark gradient placeholder with destination name.
- `lib/widgets/discovery_shortcuts.dart`: aligned spacing and clearer disabled state; same category colours and animation.
- `lib/widgets/city_venue_picker.dart`: keyboard-safe sheet layout; existing source and current-city filtering retained.
- `lib/widgets/my_day_actions.dart`: consistent add labels.
- `lib/screens/city_discover_screen.dart`, `lib/screens/place_information.dart`: scroll clearance and labels.
- `lib/screens/day_planner_screen.dart`, `lib/screens/hyderabad_demo_screen.dart`, `lib/screens/my_day_screen.dart`, `lib/screens/profile_screen.dart`: presentation label cleanup and/or braces only.
- `test/app_test.dart`: label updates and meaningful navigation/keyboard/placeholder regression checks.
- `pubspec.yaml`, `pubspec.lock`: only google_fonts and cached_network_image as new direct packages, font assets and Dart 3.9 minimum.
- `assets/fonts/`: five Lato normal weights, four Poppins normal weights and their two OFL licences.
- `README.md`, this report, and UI-refresh screenshots: run guidance, UI decisions and verification.

## Run in VS Code

Open this `travel_explorer` folder, then use its terminal:

```sh
flutter pub get
flutter run -d chrome
```

Flutter 3.35+ / Dart 3.9+ is required. On this laptop, `./run-app.ps1` also uses the workspace Flutter SDK. The already-running local compiled preview is at http://127.0.0.1:8766/; refresh that page to see the build. The old public harris-ltd-mechanism-tires tunnel has expired.

To check changes:

```sh
flutter analyze --no-fatal-infos
flutter test
flutter build web --no-wasm-dry-run
dart tool/check_core.dart
```

## Explain it in an interview

“I changed the presentation without changing the backend. The controller still owns saved cities, picked venues and drafts. Widgets read that state and call the existing actions. A city is selected before activities so results stay relevant. The photo arrow opens a guide, while the heart changes the saved list. My day reuses the same stored picks. I kept coordinates and travel-time claims honest because the data does not provide them. I tested navigation, large text, mobile keyboard space and the five-stop limit.”

## Demo checklist

1. Start Home with no city; show dimmed activity tiles.
2. Tap Goa's photo; show enabled categories. Open the guide using its arrow.
3. Scroll the guide; show accessible Back/Save, season and attraction actions.
4. Save a city and find it in Saved. Search for Paris in Search; return to Home and show that Home is unchanged.
5. Open My day; search current-city venues, add one and check its ID-backed source label. Add a custom stop only to demonstrate its unverified label.
6. Reorder outings, check a route in Maps, reach five stops and show the limit message.
7. Generate a timetable; edit duration/buffers, copy the plan and save a draft. Reload and reopen the draft.
8. Before submission, manually test Google/email login and logout on the final hosting origin, update screenshots, and test Android if the SDK becomes available.
