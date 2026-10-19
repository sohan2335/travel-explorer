# Working with agents in this Codex chat

You can ask the coordinator in plain language. It assigns subagents and integrates their results in this shared project. You do not need four separate chats. Assign each task specific files so agents do not overwrite one another.

## Task 1: UI

"Update only lib/main.dart, lib/screens/, and lib/widgets/. Build Explore, Details, and Wishlist with responsive Material UI. Use the existing Destination and TravelController interfaces. Include loading, image failure, no-match, and empty-wishlist states. Explain changed widgets. Do not edit models, state, or package versions."

## Task 2: Data models

"Update only lib/models/ and lib/data/. Keep the Destination and Attraction constructors compatible. Supply at least three Indian destinations in three categories, with all required details and 2-3 named attractions. Record image sources and distinguish illustrative images from verified location photos. Do not edit UI or state."

## Task 3: Search, filter, wishlist

"Update only lib/state/travel_controller.dart and its unit tests. Make case-insensitive trimmed name search AND category filtering work together. Toggle saved IDs, ignore unknown IDs, and notify listeners on changes. Keep the agreed public methods. Explain the data flow; do not introduce a backend."

## Task 4: Tests and documentation

"Inspect existing interfaces, then update tests and docs only. Cover combined filtering, save/remove synchronization, navigation, and empty states. Run analysis/tests if Flutter is available. Report exact checks and failures honestly. Prepare README setup, real screenshot checklist, and a 2-3 minute demo script."

## Coordinator responsibilities

Agree interfaces before parallel edits. Review all changes, resolve conflicts, format the project, run analysis/tests/build, and perform a device walkthrough. Keep changes understandable. Request a fresh validation after changing behavior.

## Beginner follow-up prompts

- "Explain the heart button from tap to UI refresh using the actual code. Ask me three questions to check my understanding."
- "Add one destination only. Walk me through every field and how it appears in the app."
- "Review the current app against the four assignment stages. Fix one failing requirement and show how you verified it."
- "Help me record the demo. Ask me to explain search and wishlist without reading a script."

## Deadline plan (IST)

18 October: setup and a working core. 19 October: verify all four stages and replace sample imagery. 20 October: test on the intended device, fix usability issues, and learn the code. 21 October: capture screenshots, publish the repository, and record the demo. 22 October: verify links in a signed-out browser and submit before 11:59 PM; leave a buffer for uploads.
