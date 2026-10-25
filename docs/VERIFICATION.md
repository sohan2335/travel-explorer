# Verification record

## Final submission audit — 25 October 2026

The current result is [FINAL_SUBMISSION_CHECK.md](FINAL_SUBMISSION_CHECK.md).
All four core stages are implemented. Fixed the keyboard/large-text venue-picker
overflow and inaccessible list, resolved all 36 analysis findings, applied standard
formatting and supplied the missing icon font. Standard analysis now reports no
issues; 77 tests with coverage, the navigation dry-run, core checks, three importer
tests and the release web build pass. Eighteen local documentation targets are
valid, and the 170-second MP4 decodes successfully. The public directory returned
24 entries across ten cities. Public repository access,
narrated public Drive video and physical-device testing are
explicitly listed as outstanding in the final report. Earlier dated records below
describe previous revisions, not the current result.

The project owner confirmed the extended deadline as **25 October 2026,
11:59 PM IST**. The original PDF's 22 October deadline no longer applies.

Formatting, analysis, all 77 tests, navigation, core checks, the three importer
tests, the web release build and service/documentation checks passed again before
the final release push to `main` and `onboarding`.

## Assignment demo preparation — 22 October 2026

- Re-read all four pages of the original assignment. The demo covers discovery, details, combined search/category filtering, and wishlist add/remove, followed by the matcher and day/whole-trip planning.
- Captured 636 frames from actual Flutter UI navigation in a separate 390 × 844 demo session; the complete capture passed its assertions. The demo uses bundled venue data and an isolated local-store implementation, with no personal browser account or drafts.
- Added destination category labels to city cards and symbol/emoji fallback families for readable capture and display.
- Re-ran the full regression suite: **75 tests passed**. Web build passed; analysis has zero errors/warnings and the existing 36 informational lints.
- Prepared a Full HD MP4 and a separate 332-word timed voice-over text in `outputs/demo/` in the workspace. The text includes screen cues, implementation notes and the assignment's final upload requirements. The movie has no spoken narration so the candidate can record their own voice.
- Final MP4 validation: **170 seconds, 5100 video frames, 30 fps, 1920 × 1080, H.264/yuv420p**. Full-video decoding passed without errors, and the final implementation scene was verified at 164 seconds. The finished MP4 is about 7.2 MiB.

## Search and destination matcher — 22 October 2026

- Full `flutter test` suite: **75 tests passed**, including 17 new search/matcher checks.
- `flutter analyze --no-fatal-infos`: zero errors and warnings; the existing 36 informational lints remain. No new-feature diagnostics were reported.
- `flutter build web --no-pub`: passed. The previously observed Cupertino font notice remains; no new dependencies were added.
- Standalone Dart core checks and `git diff --check`: passed.
- Search tests cover case/whitespace, all four actual destination categories, simultaneous name/category/country conditions, no results, clear/reset, tab changes and preservation of saved cities.
- Matcher tests cover independent and combined preferences, inclusive day boundaries, stable ties, no choices, unavailable sample profiles, invalid days and clearly labelled partial matches.
- Widget tests exercised save/explore actions, clearing stale recommendations, and a 320 × 568 phone layout at 1.3 text scale. An overflowing duration dropdown was found and fixed before the final test run.
- The local preview returned the same SHA-256 for `main.dart.js` as the new build, and includes the matcher. Refresh `http://127.0.0.1:8766/` to load it.
- This revision was verified with automated widget tests and HTTP build checks. A new browser walkthrough and physical-phone check were not performed. Sample budget styles and visit lengths are explicitly labelled examples, not live price or availability data.

## Simple travel extensions - 18 October 2026

- Final web build succeeded with Flutter 3.47.7. No new package downloads were needed.
- Standalone Dart core checks passed: contiguous plan arithmetic, room-access waiting, midnight/input guards, URL encoding, hotel queries, unique destination IDs, and three-country catalog integrity.
- Three Python importer checks passed using test fixtures: required columns, duplicate/sight filtering, and blank-name handling. This does not imply a real Kaggle file was downloaded.
- Browser checks at desktop and 390 x 844 verified ten destinations, country filtering (France shows Paris), remote Paris photo loading, clickable attraction sheets, and nearby hotel/transport controls.
- Confirmed external Google Maps tabs for a correctly encoded route and hotels near Palolem Beach, Goa, India.
- Verified bus, cab (Uber button) and bicycle (rental button) choices. No booking/payment was made.
- Verified missing-input messages, generated day plan, old-plan clearing on an edit, and the room-access waiting slot. Default UI inputs with a 09:00 arrival and 14:00 room access end at 20:00. A 30-minute rest reduction shifts later stops by 30 minutes.
- Verified save-from-details and remove-from-wishlist behavior after the additions. Screenshots were refreshed.
- Flutter test cases were added for the new behavior, but the full Flutter suite remains unrun for this revision because this session blocks its loopback sockets. Analysis has the previously documented telemetry-cache permission issue. Run both locally in VS Code.
- Android HTTPS-opening bridge is present but unbuilt/untested because Android SDK is absent. Browser popup failure offers a copyable URL. iOS/desktop targets use the fallback and have not been tested.
- Kaggle remains pending an actual downloaded CSV/license review; the importer only prepares a review preview. This earlier revision was session-only; local persistence is implemented in the update below.


## Travel journal UI update - 18 October 2026

The redesigned cream/forest-green UI compiles successfully with `flutter build web --no-pub`. Browser checks at 390 x 844 verified combined filters, destination navigation, saving to Wishlist, removing saved items, and the empty Wishlist state. Screenshots were refreshed.

The automated suite could not rerun in this session: the sandbox blocks the loopback connection needed by the Flutter test runner. Analysis also encountered a tool telemetry-cache permission error. Earlier passing results below describe the previous UI revision. Rerun `flutter analyze` and `flutter test` in VS Code before submission.

## Previous UI revision

Verified on 18 October 2026 with Flutter 3.47.7 / Dart 3.13.5 on Windows.

- `flutter analyze`: no issues found.
- `flutter test --no-pub`: all 8 tests passed (5 controller tests, 3 widget tests).
- `flutter build web`: succeeded.
- Browser walkthrough at 390 x 844: bundled images display; Goa search combined with Mountains gives zero results; All restores Goa; details opens; save updates Wishlist; removal produces the empty state.
- Four real browser screenshots saved in docs/screenshots/ and embedded in README.
- Android source generated, but Android SDK is absent: no APK build or physical Android device test has been performed.
- Repository publishing and demo recording remain to be completed.

Before submission verify on an actual browser/device:

- Home shows images, names, locations, and at least three categories.
- Every destination opens details with description, season, and 2-3 attractions.
- Search for GOA, then choose Mountains: no match. Choose Beaches: Goa appears.
- Add Goa from details; go back and open Wishlist; Goa is saved.
- Remove Goa in Wishlist; return to Explore; its heart is unselected.
- Open a destination from Wishlist and remove it there; back shows an empty list.
- Test narrow screen, increased text size, scrolling, and unavailable images.
- Earlier version used session-only wishlist state. Current version restores saved places and trip drafts from device storage; see the persistence checks below.
- Check public repository and demo permissions while signed out.




## Persistence, pace and Hyderabad update — 18 October 2026

- Final web build passed after adding storage, pace, the curated demo and clearer save notifications.
- Standalone Dart core checks passed, including draft JSON round trips, malformed/version/mode rejection, all three pace durations, Friday closure and contiguous Hyderabad route steps.
- Actual browser reload restored Goa in Wishlist and a generated Hyderabad draft with its arrival point, hotel, Relaxed pace, rest and timetable. Changing to Packed updated rest to 30 minutes and the visit to 60; saving, deleting, Undo and another reload restored the Packed timetable.
- The curated screen's date picker was exercised with Friday 23 October 2026: it showed the closure message and hid the palace itinerary.
- Four additional Flutter persistence test cases cover restoration/removal, rapid writes, malformed records and unavailable storage. They are written but not run: the known loopback restriction still prevents Flutter's test runner here. Run `flutter test` and `flutter analyze` in a normal VS Code terminal before submission.
- Android storage bridge is implemented but unbuilt and untested; no Android SDK is available here. Browser localStorage is verified. Other native platforms report unavailable storage and continue for the session.
- Storage is local to device/browser profile AND origin. Clearing data removes saves; port 8766 and port 8767 have different stores. The run script uses a stable 8767 for web development; use web-server with a normal browser for repeated sessions.
- Screenshot: `docs/screenshots/saved-trips.jpg` captures the restored collection. Sample data used for checks was removed afterwards.

## City discovery and Neon connection — 19 October 2026

- Final Flutter web build passed. The existing font tree-shaking warning remains; no extra packages were required.
- Standalone Dart checks passed for 24 listing records, unique IDs, known city/category/source fields, a stay and dining example in each of ten cities, draft compatibility, restaurant persistence, custom visit duration, explicit meal transfers, correct return origin, contiguous schedules, previous midnight guards and URL encoding.
- Created separate free Neon project `travel-explorer` in Singapore. SQL confirmed 24 rows and 10 city IDs. Anonymous SELECT is allowed; anonymous INSERT/UPDATE/DELETE are false; row-level security is enabled.
- Actual browser showed “Cloud directory · Neon” and source-linked Hyderabad hotel, restaurant and water-park entries. Munnar's newly added dining row also loaded from the cloud.
- Phone layout at 390 × 844 showed all six category shortcuts in a three-column grid, wrapped place actions and readable forms. Choosing a restaurant prefilled the meal field. The generated itinerary included a separate transfer to that meal stop and a return from the meal location.
- The complete Flutter test command was attempted for this revision. The runner could not load the suites because the sandbox blocked its connection to 127.0.0.1 (SocketException 10057). This is not a passing test run. Run `flutter test` and `flutter analyze` in VS Code before submission. The prepared Pages workflow runs tests before deployment.
- Android Internet permission is present for the new HTTP reads. Android build/device behavior remains unverified here because the SDK is absent.
- Public web deployment was prepared, not performed. GitHub Pages still needs a real repository, trusted Neon production origin, and a successful workflow run. The database is connected and live independently of web hosting.

- A new Munnar draft with a prefilled restaurant and 240-minute visit was generated, saved, restored after a full browser reload, and reopened from Wishlist. The meal transfer and timetable were rebuilt correctly. Only that temporary test draft was removed; the pre-existing Hyderabad draft was preserved.
- Screenshots of the final phone UI are `discovery-home.jpg`, `city-discovery.jpg` and `city-plan.jpg` under `docs/screenshots/`.


## Latest regression check — 19 October 2026
- All 19 Flutter tests passed after allowing the runner normal loopback access.
- Core Dart checks include multi-outing timing, route origins, old draft compatibility and invalid schedules.
- Browser: fresh Google callback completed and displayed the account; verifier removed from the URL.
- Browser: selected two extra Goa outings and generated all three visits with travel legs. Sample route was not saved.
- Home activity tiles and floating Home / Hotlists / Search navigation implemented. Profile remains in the top-right icon.

Code analysis completed with no errors or warnings; it reported 52 informational style suggestions (mostly adding braces around short if statements and console output in the standalone checker). These are not a clean analyzer pass and remain to be tidied. Release web build and all 19 Flutter tests passed.

Search-only-tab and animated icon update: all 20 Flutter tests passed, including the new check that city search appears only in Search and does not filter Home. Phone layout at enlarged text passed.

City-guide polish: all 20 tests pass after the redesigned guide, persistent planning and place-information controls, and shared contrast/button sizing changes. Phone tests include enlarged text. Remaining product proposals are documented separately from implemented features in CITY_FIRST_AND_LOGIN.md.

## My day — 20 October 2026
The previous version was committed and pushed first as 79b3180. My day was then implemented locally. All 25 Flutter tests pass, and the release web build succeeds. Browser checks confirmed adding two guide sights, synchronized pick counts, reordering, planner handoff, reload persistence and reopening through Hotlists. Only the two newly created verification picks were removed afterwards; existing trip drafts were retained.


## City-first and venue picker refinements — 20 October 2026
All 28 Flutter tests pass. New checks cover disabled activities before city choice, city-scoped picker filtering using bundled data, stable pick ID storage/attachment/removal, and the five-stop limit message. Existing phone-large-text, login-adapter compilation, planner, draft compatibility and persistence checks remain applicable. External road times and missing coordinates are not fabricated. No Android device fresh-install test was performed.

Browser check confirmed Home initially has no activity selection and disables activity controls, then choosing Goa enables them and displays Explore Goa. The final preview navigation stalled, so the rest of the updated picker validation relies on automated widget tests. The new city-first Home screenshot has been saved. Android fresh-install testing remains unperformed.
