# Final submission check — 25 October 2026

The checked project implements every core stage in the assignment.
Public repository access and the narrated video are still pending, so the
submission is not yet complete.

**Extended deadline: 25 October 2026, 11:59 PM IST.** The project owner confirmed
the extension on 25 October; it supersedes the original PDF's 22 October deadline.

## Required features

- **Stage 1 — discovery: passed.** Ten destinations across four categories.
  Every city has an image, name, location and category. Bundled assets exist.
- **Stage 2 — details/navigation: passed.** Home, city guides and Saved are connected.
  Every destination has a description, visiting season and two or three named,
  photographed attractions. Navigation is covered by widget tests and a full demo-flow check.
- **Stage 3 — search/filtering: passed.** Name search ignores case and surrounding
  spaces. Name, category and country conditions combine correctly. All four requested
  categories, no-result behaviour, reset and tab switching are tested.
- **Stage 4 — wishlist: passed.** Add/remove hearts update the shared controller
  and separate Saved screen. Local persistence and restoration have regression tests.

Optional matcher, Maps links and local storage are implemented. Live weather is
not implemented; it is optional in the PDF. Extra city discovery and day/whole-trip
planning are included, with sample data and route-buffer limitations stated in the UI.

## Problems found and resolved

1. **Venue picker with keyboard/larger text:** the fixed header/footer could leave
   a zero-height venue area or overflow on a 320 × 568 phone with 1.5 text scale.
   Replaced that structure with one scrollable list. A regression now searches
   for and selects Palolem Beach under those conditions without exceptions.
2. **Standard analysis failed:** fixed 29 missing-brace lint findings and updated
   the pure-Dart CLI check's imports/output. Standard analysis now has zero findings;
   no `--no-fatal-infos` bypass or blanket suppression is used.
3. **Missing icon font in release builds:** added the pinned `cupertino_icons`
   font package. The release now includes both icon fonts and no longer reports
   the missing-Cupertino-font message.
4. **Stale instructions:** updated the README and interview guide to describe the
   current Search/matcher and the planner without mandatory airports/check-in.
   Refreshed README screenshots and added checks to the deployment workflow.

Standard Dart formatting was applied across the existing source/tests/tool files.
Most changes in those files are formatting; the venue-picker fix is the behaviour change.

## Executed checks

These checks were rerun successfully before the final GitHub push on 25 October.

- `dart format --output=none --set-exit-if-changed lib test tool`: passed, zero changes.
- `flutter analyze`: passed, **no issues found**.
- `flutter test --coverage`: passed, **77 tests**; coverage output generated locally.
- Manual demo navigation in dry-run mode: passed; covers discovery, search, guides,
  Saved add/remove/restore, matcher, dining, generated day draft and whole-trip save.
- `dart tool/check_core.dart`: passed, including timetable boundaries and URL encoding.
- `python tool/check_import.py`: **3 tests passed**.
- `flutter build web --no-pub`: passed; WebAssembly dry-run compilation also passed.
- Local documentation/screenshot links: **18 targets checked**, no broken links.
  `git diff --check` passed. The demo was decoded again: **170 seconds / 5100 frames**;
  its audio is still silent, so the prepared copy still needs personal narration.
- Online public directory: **24 records / 10 cities**, fetched with a short-lived
  guest token. No private account cookies or credentials are exposed in the app.
- Auth session endpoint: reachable and accepts the localhost origin. A new real
  Google/email login was not performed during this audit.

See [submission regression tests](../test/submission_regression_test.dart),
[search tests](../test/destination_search_test.dart) and
[matcher tests](../test/destination_match_test.dart).

## Final release

This release includes the search/matcher, final bug fixes, regression tests,
README screenshots and interview documentation. The final push targets both
the default branch `main` and the development branch `onboarding`; Git history
identifies the release commit.

## What still needs attention before sending the submission

- **Repository visibility:** the existing repository is private, as previously
  requested. The PDF requires a public repository. It has not been made public.
- **Video:** a 2:50 demo and timed script are provided in workspace `outputs/demo/`.
  Add personal narration if using the prepared silent movie, upload the final copy
  to Google Drive, verify its public viewing access, and add the actual URL to README.
- **Native verification:** Android SDK is absent, so APK and physical Android
  tests could not run. Simulated phone layout tests and a web release build are
  passing; they do not constitute a physical-device test. Windows native builds
  also need the absent Visual Studio desktop toolchain.

The deadline extension is confirmed by the project owner. The read-only web tool
could not independently verify the form's current acceptance status.

No repository visibility change, public video upload or form submission was
performed by these checks. Those actions remain separate from the code push.

Source: `D:/Downloads/GDGC VNRVJIET - App Development Assignment.pdf`, all four pages.
