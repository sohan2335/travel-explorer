# Understanding the sample data

`lib/models/destination.dart` describes the shape of the information. Think of a class as a form: every destination needs an ID, name, location, category, photo asset path, description, suggested visiting season, and a list of attractions. Each attraction has a name and photo asset path.

`final` means a field cannot be assigned a different value after the object is created. `const` lets Dart create fixed values ahead of time. The bundled list and its nested attraction lists are constant, so this sample data cannot be changed by the screens.

`lib/data/destinations.dart` fills those forms with six Indian destinations and includes four more from more_destinations.dart. The app reads this local list directly; it needs no database, API key, or server. Stable IDs such as `goa` let the wishlist remember a destination even if its display name changes.

To add a destination, copy a `Destination(...)` entry, choose a unique ID, fill every field, and include two or three attractions. Match category spelling exactly: `Beaches`, `Mountains`, `Heritage`, or `Adventure`, so the filter can find it.

The original six destinations have photos bundled in `assets/images/`. The four added cities use remote Commons photos, so those images require internet. Text, search, wishlist and planner logic remain local. The `imageUrl` field keeps its original name and contains either a local asset path or a remote URL. Source pages identify the named attractions; destination heroes reuse a representative attraction. See `docs/IMAGE_CREDITS.md` for each creator, source, and license. The interface displays a fallback if an asset cannot be loaded. Descriptions and suggested visiting seasons are demonstration content, not booking or live weather information.

Each destination also has a country and source label. Country filtering uses the same list. See DATA_SOURCES.md for the exact fields checked against Hugging Face and the pending Kaggle import.

