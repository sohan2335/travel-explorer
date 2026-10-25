# Learn the app in six small steps

## 1. A model is a form

`Destination` holds a city's name, location, category, description, photo, visiting
season and attractions. `Attraction` holds a name, photo and optional description.
The lists in `lib/data/` contain sample objects. `final` means a field cannot be
reassigned; `const` describes fixed sample data.

## 2. Search asks three yes/no questions

`TravelController.visibleDestinations` checks name, category and country.
It trims the query and compares lowercase names using `contains`. A city appears
only when all three conditions match. A null category or country means All.
Goa plus Mountains gives no results; Goa plus Beaches finds Goa.

## 3. Shared state keeps hearts in sync

The wishlist is called Saved in the UI. It stores destination IDs in a set.
Toggling a heart changes that set and calls `notifyListeners()`. Listening widgets
rebuild, so Home, details and Saved agree. Filtering does not delete saved IDs.
The local store serialises IDs and draft inputs as JSON. Web uses localStorage;
Android uses the existing SharedPreferences platform bridge. Sign-in is not cloud sync.

## 4. The matcher counts reasons

The matcher awards one point for each selected preference that matches a city's
sample profile: travel type, budget style and visit length. It sorts by points,
then alphabetically. Mountains + Budget + 4 days gives Manali 3/3. When no city
matches everything, the screen labels the alternatives and explains differences.
It is a rule-based function, not an AI service or a live price feed.

## 5. The planner adds minutes

09:00 is 9 × 60 = 540 minutes. Each stop begins when the previous stop ends.
For example, 60 minutes travel + a 90-minute visit + a 60-minute meal + 60 minutes
return takes a zero-break 09:00 plan to 13:30. A chosen restaurant may add a transfer.
Extra outings add their own travel and visit durations. Plans beyond midnight are rejected.

The screen starts from an optional home/hotel/city location. It does not require
an airport, station, hotel check-in or room-access time. Some internal field names
remain from older saved drafts for compatibility; the UI calls `buildDayPlan` with
`includeArrival: false`. Inputs can be saved and the timetable rebuilt later.
Whole trips reuse the same day model, saving 2–7 independently editable days under
a separate storage key. They plan one city, not transport between cities.

## 6. Public content and personal data have different jobs

Neon supplies a public read-only place directory using a short-lived guest token.
If it cannot be reached, bundled JSON is used. That service does not store personal
wishlist IDs or trip drafts. Google Maps links use `Uri.https` for safe URL encoding.
The external provider supplies current route information; this app does not book trips.

## A short explanation to practise

I used Flutter widgets, simple Dart models and a shared ChangeNotifier controller.
The core destination list is local. Search combines three conditions, and Saved
stores IDs. The matcher counts matching preferences. My planner adds minute durations
and checks midnight. I used AI assistance and verified the behaviour with tests.

Before the interview, change one city description, follow a heart toggle through
the controller, and explain one search test and one matcher test in your own words.
See FINAL_SUBMISSION_CHECK.md for actual checks and outstanding submission steps.
