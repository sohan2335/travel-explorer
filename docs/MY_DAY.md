# My day: collect, arrange and plan

## Try it
1. Open a city and browse its sights or venues.
2. Tap **Add to My day** on an outing. Hotel and restaurant cards have **Choose stay for My day** and **Choose meal for My day**.
3. Open **My day (count)** in the city screen or guide, or open the city's My day entry from Saved.
4. Move outings Earlier/Later, remove a pick, or enter an additional venue name. Each city has its own list.
5. Tap **Plan my day**. The selected route, stay and meal prefill the form. Check arrival, duration and transfer buffers, generate the timetable, then explicitly save a trip draft.

## Understand the code
- `lib/models/my_day.dart`: immutable picks, one selected stay, one selected meal and up to five ordered outings. It validates data restored from storage.
- `lib/state/travel_controller.dart`: all screens share the same picks through a ChangeNotifier. Adding a place updates the count, notifies listening widgets and saves the picks under a separate local-storage key. Writes are serialised so rapid changes do not save in the wrong order.
- `lib/widgets/my_day_actions.dart`: reusable Add / selected / review controls.
- `lib/screens/my_day_screen.dart`: list editing and planner handoff.
- `lib/screens/day_planner_screen.dart`: accepts an ordered route, uses its first item as the main outing and the rest as additional stops. Old arrival and pace settings can still restore from an existing draft. Opening My day in the planner does not write over that draft.

Picks are device-local, independent of Google login and separate from generated trip drafts. Duplicates are ignored, and a sixth outing is rejected. Selecting another stay or meal replaces that role, not your outings. The selected meal is scheduled after the outings. Planning buffers are chosen by you, not calculated from live routes or opening hours. Movies, events, salons and play currently open external city searches; to include a venue found there, enter its name in My day.

## Validation
25 Flutter tests pass, including city separation, duplicate/limit rules, stay/meal replacement, reordering, storage restoration, corrupt-entry isolation and planner handoff without draft overwriting. Existing large-text phone and browsing checks also pass.

The previous version was committed and pushed to the private repository first as `79b3180`, before My day development began.


## Updated picker and route checks
Use **Add to My day** to search the current city's bundled sights and directory venues. The saved pick includes its source ID; coordinates are not present in this catalog. Use the explicit custom-stop fallback only if needed. Each outing offers Open in Maps, and each later outing offers Check route from previous stop. These links include both the city and country and use Maps to resolve the place names. The list explains the five-outing limit, and the info icon contains the storage and planning limitations.
