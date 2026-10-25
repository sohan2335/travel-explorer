# Search and Smart Destination Matcher

Open **Search** in the bottom bar. This screen has destination-name search,
country selection and the assignment categories: **Beaches, Mountains,
Heritage and Adventure**. Home still starts with city photographs.

## Explain search to an interviewer

`TravelController.visibleDestinations` removes surrounding spaces and compares
lowercase destination names with the lowercase query using `contains`.
It then checks the selected category and country. All three conditions must
be true. Empty search and an All selection allow every value for that field.

For example, `  GOA  ` plus Beaches and India shows Goa. Changing the category
to Mountains gives no result; the app does not silently ignore the category.
Clear city search removes only the text. Reset filters clears all three inputs
in one controller update. Neither action deletes saved places or trip drafts.

`lib/widgets/destination_search_controls.dart` displays the inputs. Categories
come from the destination data, so the controls use exactly the labels that the
filter compares. The country control also resets visibly when filters are reset.

## Explain the matcher

Open **Search → Match my trip**. The selected Search category is preselected as
the travel type; the matcher otherwise explores all ten destinations using its
own temporary preferences. Returning leaves Search filters intact.

Choose one or more of:

- Travel type: Beaches, Mountains, Heritage or Adventure.
- Budget style: Budget, Mid-range or Premium.
- Trip duration: 1–7 days spent in the destination.

The matcher uses `lib/models/destination_match.dart`. Each destination receives
one point for each selected preference it matches. A duration matches when it is
between the city's minimum and maximum sample visit lengths, inclusive. Unselected
preferences do not add points or penalties. Ties are alphabetical, then by ID.

The screen shows up to three cities matching every choice. When none match all
choices, it shows the three highest scores as **Closest options**, including both
the matching reasons and what differs. A score of 2/3 means two of three selected
preferences matched; it is not a probability or a claim of AI confidence.
Changing a choice clears old results so the reasons cannot describe stale inputs.

The small profile map is in `lib/data/destination_match_profiles.dart`.
Budget styles and visit lengths are explicitly hand-written demonstration tags.
They are not researched prices, quotes, mandatory stay lengths or availability.
Transport to the city, visas and airfare are not included. Missing profiles never
claim a budget or duration match. Everything works offline with no AI service,
extra account, new package or database migration.

**Example:** Mountains + Budget + 4 days ranks Manali first with 3/3. Munnar
matches the travel type and visit length, but its sample budget styles differ.
Beaches + 7 days has no exact match, so the UI labels the alternatives honestly.

Tap a result's heart to use the existing Saved collection, or Explore to open
its city categories. Matcher choices are session-only; they do not overwrite
onboarding preferences, saved days or whole-trip plans.

## Demo and checks

1. In Search, enter `  gOA  ` and select Beaches. Goa should be the only result.
2. Select Mountains while keeping that name. Confirm the no-result message.
3. Clear the name. Manali and Munnar should appear. Choose France: no results.
4. Reset filters. Confirm the empty name, All countries, All categories and ten cities.
5. Select Mountains and open Match my trip. Mountains should be preselected.
6. Select Budget and 4 days. Find matches, read Manali's 3/3 reasons, save it,
   and open its city. Verify the saved heart agrees in Saved.
7. Try Beaches and 7 days. Confirm Closest options and visible differences.
8. Change or reset preferences. Old recommendations must disappear.
9. Check a narrow phone, increased text size and switching between Home,
   Search and Saved. Search filters must not hide Home's city choices or saved IDs.

Run `flutter test test/destination_match_test.dart test/destination_search_test.dart`
for the matching rules and UI checks; run `flutter test` for the regression suite.

For interview preparation, read the data map first, the scoring function next,
then the screen. The key idea is a few predictable comparisons followed by a sort.
