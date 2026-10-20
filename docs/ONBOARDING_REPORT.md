# Onboarding & preferences — implementation and checks

Completed on 20 October 2026 on local branch `onboarding`. No push or deployment was made.

## What changed

- Part 1 (`6adea78`): dark Android/web native loader and animated compass splash; bounded local restoration; existing login entry; background session check.
- Part 2 (`bdeec1c`): three full-screen bundled photo pages, indicators, Continue/Get started/Skip and reduced-motion transitions.
- Part 3 (`cba5fc6`): optional interests, trip style and travel-company setup with Save/Skip and per-user local keys.
- Part 4 (`8012963`): selected Home interests first, conditional directory matches, new-plan pace suggestions and Profile edit/replay controls.
- Part 5: this report's commit contains startup/account-switch regression fixes, expanded tests and documentation.

The original dark palette, per-category accents, Lato and Poppins are preserved. The logo uses the app's existing Material compass glyph. Photos are compressed copies of existing attributed travel assets, not reference-app images. JPEG sizes: coast 99,263 bytes, city 282,937 bytes, hills 137,797 bytes.

## Beginner code map / files changed

- `lib/main.dart`: owns the new experience controller beside the existing travel controller and starts the splash immediately while local restoration runs.
- `lib/experience/experience_controller.dart`: separate intro/preferences flags and validated optional values; user-specific keys, device fallback, storage errors and a non-secret last-user hint.
- `lib/experience/experience_controller.dart` also defines `ExperienceScope`: lets screens read the same preference state without passing it through every constructor.
- `lib/experience/splash_screen.dart`: 600 ms fade/scale entrance, 600 ms hold, 400 ms exit; reduced motion; deadline and route selection. Long network requests are never awaited.
- `lib/experience/flow_navigation.dart`: shared fade plus small upward slide and the login → intro → preferences → Home decisions.
- `lib/experience/onboarding_screen.dart`: PageView photos, text transitions, indicators and finish/skip handling.
- `lib/experience/preferences_screen.dart`: optional chips, local Save/Skip and success/error snackbars.
- `lib/experience/interest_venues.dart`: show up to three real matching directory records only when at least two match the current city. No empty heading and no AI claim.
- `lib/screens/profile_screen.dart`: retain existing auth requests; observe their returned user ID for local setup routing; add Edit preferences/Replay intro and an injectable request function for tests. A navigation guard prevents a late session response from overriding an explicit guest choice.
- `lib/screens/explorer_screen.dart`: pass chosen interests to the activity tiles and conditionally display matching venues/storage messages; let the startup gate own callback routing so guest navigation cannot reopen a stale callback tab.
- `lib/widgets/discovery_shortcuts.dart`: stable interest-first ordering; all other categories remain available.
- `lib/screens/day_planner_screen.dart`: preference defaults apply only if there is no saved draft; existing pace/duration controls still work.
- `lib/screens/my_day_screen.dart`: clearly labelled stop-count and duration suggestions, without adding stops or restricting the five-stop limit.
- `flutter_native_splash.yaml`, `android/app/src/main/res/`, `web/index.html`, `web/splash/`: generated startup resources, plus explicit dark Android normal-window backgrounds.
- `assets/branding/compass.png`, `assets/onboarding/`: logo and three compressed photos.
- `pubspec.yaml`, `pubspec.lock`: font/image packages retained; only flutter_native_splash added as a dev dependency; new asset folders declared.
- `test/app_test.dart`: existing UI tests explicitly bypass startup so they continue to test their original screens.
- `test/launch_test.dart`, `test/experience_ui_test.dart`, `test/experience_controller_test.dart`, `test/first_run_flow_test.dart`, `test/preferences_usage_test.dart`: startup, layout, flags, login routing, preference and draft regressions.
- `README.md`, this report and `docs/screenshots/onboarding-mobile.jpg` / `preferences-mobile.jpg`: user instructions and verification evidence.

## Storage and authentication decisions

All 28 existing protected files — data/models, Neon and auth services, local-store implementations, travel controller, backend and venue JSON — match their pre-change SHA-256 hashes. Existing saved cities, My day picks and drafts are not migrated, renamed or cleared.

New flags/preferences are stored only through the existing LocalStore interface under `travel_explorer.experience.v1.<encoded user ID>`. With no ID, they use a per-device `device` key. The last user ID is stored separately under `travel_explorer.launch_user.v1`; no email, password or token is saved by the new code.

Session checks run in parallel, without delaying startup for the network. When offline, a previous non-secret ID can restore local setup continuity. That hint is not proof of login and does not authorize any backend access. If there is no usable identity, the existing login screen appears and guest exploration remains available. A Google verifier callback is left to the existing login code, avoiding a duplicate verifier exchange. The profile's normal sign-in/sign-out requests and credential handling are unchanged.

Skipping intro marks it complete; skipping preferences marks them acknowledged and preserves any existing saved choices. If storage fails, the current session still works and explains that choices may not survive reopening. New account IDs start with their own flags; the guest profile does not inherit a signed-in user's preferences. Existing travel lists remain device-local as before.

## Checks performed

- `flutter analyze --no-pub --no-fatal-infos` after every part: zero errors and zero warnings in the final source. The same 36 pre-existing informational notices remain in protected models/services/controller and the core-check tool.
- Final full suite: **50 tests passed**. The previous 31 travel-app tests still pass.
- Tests cover splash with a never-completing session request, reduced motion, slow local storage, first signed-in launch, returning offline identity, different account ID, intro Continue/Skip, empty preferences, Skip for now, corrupted/unavailable storage, user isolation, a simulated email sign-in sequence, conditional real venue matching, interest ordering, changeable pace, preserved saved drafts and compressed photo sizes.
- New layout tests cover 320×568 portrait, 640×320 landscape and 1.3× text. Existing app tests retain 390×844 with 1.5× text scaling.
- Web release build passes. Core checks pass for day-plan arithmetic/validation, URL encoding and destination integrity.
- Live browser at 390×844: restored existing signed-in session, advanced all three intro pages, opened optional preferences and skipped without choosing values; reloaded into Home without repeating setup; verified Profile replay returns to the intro. Screenshots are saved with this report.

## Issues found and fixed

- Late session completion could race with choosing guest mode; Profile now guards a completed navigation.
- An already introduced user with unfinished preferences now resumes preference setup after login.
- Startup waits for any pending local identity read within its existing deadline, without waiting for network completion.
- The splash content can scroll on short landscape viewports rather than overflowing with large text.
- Completion controls ignore repeated taps while leaving a screen.
- Account-switch tests confirm that one user's completed intro/preferences cannot skip another user's setup.

## Skipped / remaining limitations

- Budget and dietary questions: omitted because LocalPlace has no usable fields for them. Travel company is optional planning context, not a venue-suitability filter.
- shared_preferences package: unnecessary; the existing Android storage channel already uses SharedPreferences and the web implementation uses localStorage.
- iOS native generation: disabled because the repository has no iOS project.
- Android installation/native splash on hardware: not run because this laptop has no Android SDK. Native sign-in remains web-only, as before.
- Fresh real Google/email provider login and logout/account switching were not performed against a live provider. Automated request-injection tests check the flow; the live browser confirmed the existing real signed-in session. No real accounts or credentials were created for testing.
- The web compiler still emits the previously documented Cupertino font-family diagnostic while successfully building. Actual app icons use the Material font.
- The local offline identity hint is intentionally not an authentication guarantee; online protected access still uses Neon. A storage timeout may require repeating setup on a later launch if completion was not saved.
- Movies/Events/Play/Salons can be interests even where the current curated directory has no corresponding records; the matching section is hidden rather than filled with invented venues.
- Intro/preferences are local to this device/browser, not synchronized across devices. Clearing browser data resets these flags.

## Run and demo

Open the project in VS Code and run `flutter pub get` then `flutter run -d chrome` (or `./run-app.ps1` on this laptop). Refresh the compiled local preview at http://127.0.0.1:8766/. Native resources can be regenerated using `dart run flutter_native_splash:create`; retain the explicit dark NormalTheme backgrounds in the Android styles afterward. See [flutter_native_splash documentation](https://pub.dev/packages/flutter_native_splash) for the generator.

For the interview: “The splash runs independently of the network. A small experience controller stores setup flags and optional choices under separate user keys. The existing travel controller and backend are unchanged. Home sorts categories using the selected IDs, and only shows directory matches when there are enough real records. Pace is a default for a new plan, so saved drafts and user edits always win.”

Demo: replay intro from Profile; show Skip and Get started; leave choices empty or save interests; choose a city; compare activity order and matching entries; open My day and edit pace in the planner; revisit a saved draft; reload and show the intro does not repeat. Test a fresh real provider sign-in on the final hosting origin before submission.
