# Understanding search, filters, and saved places

`TravelController` is the app's small shared notebook. It remembers the search
text, the selected category, and the IDs of saved destinations. The screens read
this notebook instead of each maintaining separate copies of the same information.

The constructor receives the destination list. It keeps a read-only copy so another
part of the app cannot accidentally add or remove destinations from its source.

`visibleDestinations` calculates what to display. It removes spaces around the
search text, converts the text and destination name to lowercase, then checks
whether the name contains the search. A destination must also belong to the
selected category. A `null` category means all categories. Category matching is
exact, so the UI should use the category labels provided by the data.

`toggleWishlist(id)` saves an unsaved place or removes a saved one. A set of IDs
prevents duplicate saves. Unknown IDs are ignored. The wishlist is independent
of the current search and category, so filtering never deletes a saved place.
It displays places in their original data order.

`ChangeNotifier` lets a screen listen for changes. Each setter calls
`notifyListeners()` after changing the notebook; the listening UI then rebuilds.
Setting the same value again does not trigger an unnecessary update.

Wishlist IDs and trip inputs are encoded as JSON and written through LocalStore. Startup waits for restore before showing Explore. Web uses localStorage; Android uses SharedPreferences through a small platform channel. Writes are queued so rapid taps cannot overwrite newer choices. Unknown IDs are ignored and malformed drafts are skipped. Storage failures show a message; session changes may not survive restart. MemoryStore makes controller tests independent of real device storage.

Run `flutter test test/travel_controller_test.dart` from the project folder to
check search, combined filters, save/remove behavior, and change notifications.

## Directory content is separate from personal state

The cloud directory belongs to `PlaceCatalog`, not to the wishlist controller. It loads public place rows and caches the result for the session; Refresh directory requests a new copy. `TravelController` still saves personal wishlist and draft inputs locally. Draft main outings may now be source-linked directory entries as well as bundled attractions. The validator requires a known city and bounded non-empty outing text. Restaurant and optional visit-minute fields are backward-compatible with older saved drafts.
