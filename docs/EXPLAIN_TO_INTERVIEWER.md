# Learn the app in five small steps

## 1. A model is a form

Open lib/models/destination.dart. A Destination holds a name, country, category, description, image, and attraction list. An Attraction holds a name, photo, and optional description. `final` fields cannot be reassigned after an object is made. `const` data is fixed sample content.

Try changing one description in lib/data/more_destinations.dart. Refresh the app and find that city. Explain which object changed and which widget displays it.

## 2. Filters are three yes/no checks

Open lib/state/travel_controller.dart. Each destination is checked for a name match, a category match, and a country match. The result is shown only when all three are true. A null category/country means "all." The wishlist stores IDs, so changing filters does not remove saved places. `notifyListeners()` tells listening screens to rebuild.

Try searching Goa, then choosing France. Explain why the result is empty.

## 3. Buttons can open existing services

Open lib/services/travel_links.dart. `Uri.https` builds an encoded link from a place name and city. Google Maps handles hotel searches and route information. The app does not secretly calculate live prices or book a ride. `TravelLinkButton` connects that URL to a button.

External-link platform helpers are isolated boilerplate: the web helper calls the browser's open function; Android's small MainActivity bridge asks Android to open an HTTPS URL. You do not need to invent a server to do this. Other unsupported platforms show a copyable link. Android needs a real-device test before claiming it works there.

## 4. The planner adds minutes

Open lib/models/day_plan.dart. A stop records its start minute and duration. The next stop begins at the previous start plus duration. At 09:00, the value is 9 times 60 = 540. The function adds arrival time, a transfer, hotel arrangements, rest, another transfer, one attraction, a meal, and a return transfer.

When room access is already available, a 09:00 plan with 60 minutes rest and 60 minutes per transfer ends at 16:30. The UI also asks for the confirmed room-access time (initially 14:00). If the traveller arrives at the hotel earlier, one simple `if` adds waiting time before check-in and rest; with those UI defaults the day ends at 20:00. If it would pass midnight, the function asks for different inputs instead of pretending it still fits in one day. These durations are editable planning buffers, not measured routes. Hotel check-in and attraction availability are not known to the algorithm.

Try changing rest from 60 to 30 minutes. Explain why the plan ends 30 minutes earlier. The UI clears an old plan when inputs change, so the user cannot confuse it with the new inputs.

## 5. Tell the truth about the data and checks

Open docs/DATA_SOURCES.md and docs/VERIFICATION.md. Some fields are checked against a Hugging Face dataset. Other content is curated. Kaggle is pending an actual file/license review. The planner is a rule-based timetable, not AI. Wishlist IDs and saved trip inputs survive restarts on the same device/browser origin. The app rebuilds the timetable from the saved inputs. Live routes, hotel availability and fares belong to the external provider.

## A short explanation to practise

"I built the interface with Flutter widgets and stored a small destination list locally. One ChangeNotifier controller handles search, category/country filters, and wishlist IDs. Place names open an information sheet. I build Google Maps links for nearby hotels and transport, so I don't need a booking backend. My one-day planner is a function that adds minutes to make a draft itinerary and rejects plans that go past midnight. I used AI assistance, reviewed the code, and can explain and change these features myself."

## Check your understanding

1. What changes if you add a new country to the destination list?
2. Why does the wishlist use IDs instead of names?
3. Which line combines the three filter conditions?
4. Why do URLs need encoding when a place name contains spaces or `&`?
5. How does the planner avoid overlapping time slots?
6. What does this version still need from a live provider?


## Three small additions to practise

1. **Saving:** read `lib/models/trip_draft.dart`, then `lib/state/travel_controller.dart` and `lib/services/local_store.dart`. A draft stores inputs as JSON, not a screenshot. On startup `restore()` reads them; the planner adds the minutes again. One draft per destination keeps the design small. The web/native adapter files handle platform details; no server is involved.
2. **Pace:** `visitMinutesByPace` gives Relaxed/Balanced/Packed visits 120/90/60 minutes. The screen sets the corresponding rest default to 90/60/30 minutes, which the user can override. Packed still visits one main attraction; it does not automatically add more stops.
3. **Local knowledge:** `lib/data/hyderabad_demo.dart` holds a curated route. `palaceOpenOn()` checks `DateTime.friday`. The screen hides that palace route on Fridays. This is a small researched example; the generic planner does not know every attraction's opening hours.

Try this yourself: save a Relaxed trip, reload, open Wishlist, resume it, then change to Packed. Explain why the visit gets shorter, why rest changes, and why the old timetable disappears until you generate it again.

## Current city discovery version

The latest UI follows the video reference: dark plum, colourful shortcut tiles and a shared city screen. Start with `docs/DISCOVERY.md` for these additions. The fixed Hyderabad example described above is retained as earlier reference code, but the home screen now offers a planner for every destination.

The public directory has a real backend now: Neon stores curated place rows, and Flutter reads them through its Data API with a short-lived guest token. No database password is in the app. `PlaceCatalog` falls back to bundled JSON if the cloud request fails. `LocalPlace` is just another form-like model, with city, kind, name and source fields. The cloud directory does not know live booking availability. Wishlist and personal trip drafts are still local.

A good interview explanation: “I separated public place content from personal trip state. I filter the directory by city and category, use Maps for nearby searches, and prefill the same planner from a chosen stay, meal or outing. I kept the algorithm as minute arithmetic and made the visit duration editable for longer park trips.”
