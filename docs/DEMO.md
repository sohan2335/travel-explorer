# Travel Explorer demo: 2–3 minutes

Before recording, run the app on the device you plan to show. Check the current
assignment PDF against the finished app before claiming every requirement is met.
The assignment PDF has been read; all four core stages are implemented. See VERIFICATION.md for actual check results.

## Recording checklist

- **0:00–0:20 — Introduce the project.** Say your name, GDGC VNRVJIET recruitment,
  and the app's purpose: discover destinations and save places to visit.
- **0:20–0:45 — Explore.** Show destination names, categories, locations, and
  photographs. Scroll the list. Explain that sample information is bundled with
  the app; an account and backend are not required.
- **0:45–1:15 — Search and filter.** Search for Goa. Select Mountains to show the
  empty state, then All to restore Goa. Explain that both filters must match.
- **1:15–1:45 — Open details.** Open Goa and show its description, best visiting
  season, and attractions. Tap the heart to save it.
- **1:45–2:10 — Show wishlist.** Go back and open Wishlist. Show Goa, remove it,
  and show the empty wishlist message. Reload and show that saved places return in the same browser profile.
- **2:10–2:40 — Explain your code.** Briefly show the destination model, controller,
  and one test. Describe what you learned and one change you made yourself.
- **2:40–3:00 — Finish.** Show the public repository and README setup instructions.
  Mention any remaining limitations honestly.

## Final submission checks

- Compare every PDF requirement with the working app and record any gaps.
- Run `flutter analyze` and `flutter test`; fix failures and record actual results.
- Test on a real phone or emulator, including a narrow screen and keyboard input.
- Try without internet: bundled photos, search, and wishlist should continue
  to work. Check the image fallback separately if an asset is missing.
- Check that the repository is public and can be cloned by someone else.
- Include screenshots, setup instructions, and the demo link in the README.
- Check the recording link opens without requesting access.
- Submit by **22 October 2026**, using the exact time and submission method from
  the assignment: **11:59 PM IST**.

## Questions to practice answering

1. What does a `Destination` object hold? Explain one field in your own words.
2. Why do two screens share one `TravelController`?
3. How does typing in a `TextField` change the destinations shown?
4. Why use destination IDs for the wishlist instead of destination names?
5. What does `notifyListeners()` do after saving a place?
6. How do wishlist IDs and saved trip inputs survive a restart?
7. What happens if a photograph fails to load?
8. Which checks have you actually run, and which behavior did you test manually?

## Brief extension walkthrough

Keep the complete recording within 2-3 minutes by shortening the introductions above. Show the France country filter, open Paris, and tap an attraction name to show the background/surroundings links. Show the nearby hotel search and transport selector without pretending to book anything. Open the day planner, enter an arrival point and chosen hotel, confirm the room-access time, and generate the timetable. Explain that adding minute durations makes the schedule, and early arrivals wait for room access. Mention the actual dataset sources and pending Kaggle import honestly. Practise with EXPLAIN_TO_INTERVIEWER.md before recording.

See `VERIFICATION.md` for actual verification results. Tests cover controller
behavior, navigation, wishlist changes, combined filters, and a phone-sized
layout with larger text. Record test results after running the current version.


## Standout feature demonstration

1. Save Goa, reload and show it still in Wishlist.
2. Open a destination planner; enter a station and a sample hotel. Choose Relaxed. Point out 120 minutes sightseeing and 90 minutes rest.
3. Generate and Save trip draft. Reload; open Wishlist and Resume the trip. Show the restored inputs and timetable.
4. Change to Packed: 60 minutes sightseeing and 30 minutes rest. Explain that rest is still editable. Generate again and save to replace the draft.
5. Delete saved draft and use Undo. Explain the one-draft-per-city design.
6. Open the student Hyderabad day. Select a Friday to show the closure message; choose Thursday for the timeline. Open the official visitor source.
7. Explain limitations: local saving, no account sync, example buffers, generic planner does not validate all opening times.

## Latest discovery demo (replace the fixed Hyderabad demo segment)

Choose Hyderabad on Explore and show the six shortcuts. Open Water parks, show Wonderla and the “Cloud directory · Neon” status, then choose a tourist spot and open nearby Maps results. Explain that the cards are citywide and do not claim live availability. Switch to Food and show the official source. Use a stay, restaurant or outing in the planner, enter the remaining inputs, generate and save. Reload and resume from Wishlist. Switch to another city to show that the same screens and planner work everywhere; an empty curated category still offers map search. State which tests ran and that GitHub Pages deployment is prepared rather than already published.
