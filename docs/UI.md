# Understanding the interface

Start at `lib/main.dart`: `main()` launches `TravelExplorerApp`. The app creates
one `TravelController`, shares it with its screens, and disposes it when done.
Tests can provide their own controller. A supplied controller belongs to its caller.

`ExplorerScreen` keeps only the selected bottom navigation tab in local state.
Search text, category selection, and saved destinations belong to the controller.
`ListenableBuilder` rebuilds the interface whenever the controller notifies it.
Search and category filtering work together. Wishlist shows all saved places.

Tapping a destination opens `DestinationDetails` with Flutter's `Navigator`.
Both screens use the same controller, so saving on the details screen also changes
the home screen and wishlist. Heart buttons have destination-specific tooltips.

`DestinationImage` handles successful, loading, and failed network photos.
An unavailable photo never hides the destination's text. Photos require internet;
the included destination information remains usable without it.

Details attractions wrap into columns on wide screens and stack on narrow screens.
Main content is centered with a maximum width for comfortable desktop reading.
The destination list scrolls and text wraps instead of using a fixed card height.

Wishlist IDs and saved trip drafts restore on startup from device storage. Open Wishlist to resume a draft.

## Travel journal styling

The theme in `lib/main.dart` defines warm cream surfaces, forest-green actions, terracotta accents, rounded cards, category chips, and the navigation bar. Theme changes are inherited by widgets throughout the app.

`lib/screens/explorer_screen.dart` defines the journal introduction, larger photo cards, category labels and circular save buttons over photos, and the visiting-season panel in details. `Stack` places the labels and save button over a photo; `Positioned` anchors them to its corners. The existing controller still owns search and wishlist behavior.


## New feature screens

The country selector reads countries from the same destination list. `place_information.dart` shows a bottom sheet when a place name is tapped. `travel_tools.dart` builds hotel and transport search buttons from the selected attraction. `day_planner_screen.dart` collects the traveller inputs and displays the stops returned by the plain function in `day_plan.dart`. Changing an input clears the displayed timetable; the saved draft changes only when Save trip draft is pressed. `travel_links.dart` only constructs URLs; it makes no web requests.


## Current video-inspired discovery UI

The latest theme is dark plum with lavender, peach, mint, blue and pink category accents. `DiscoveryShortcuts` adapts to a three-column phone grid. `CityDiscoverScreen` has the city selector, photo hero, nearby-search anchor, source-linked directory cards and planner entry points. The former cream/green descriptions above describe the earlier revision.
