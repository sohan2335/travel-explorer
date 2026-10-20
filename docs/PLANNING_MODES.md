# Day and whole-trip planning — 20 October 2026

The prior onboarding version (`cbeef25`) was pushed first to `origin/onboarding` as requested. This planner update is saved and pushed on that same branch after validation.

## Behaviour

The city guide now says “Plan your visit”. Its planner starts with two dark cards: Plan a day and Plan whole trip. Both use the existing colours and fonts. Switching from a day to a whole trip keeps the original day form underneath, so using Plan a day or Back returns to its current inputs.

A day plan no longer asks for an airport/station, arrival formalities or hotel room-access time. Its optional starting/return location can be home, a hotel or any city place. Blank uses the city centre, explicitly labelled as a default. Start time, up to five outings, optional breaks/meal, pace, travel buffers, Maps, Copy and Save remain available. The timetable returns to the chosen starting point.

Whole trip means 2–7 consecutive days in the selected city. Choose a start date, edit each day's timetable, save it into the trip and copy the combined outline. Each day can have its own starting point, stops, pace and buffers. Suggested first sights come from existing city data; they are not marked planned until the user creates a timetable. Unplanned days are labelled clearly in the screen and copied text. Reducing a trip with planned extra days asks for confirmation in the app.

Use My day → Whole trip plans to resume. One saved whole trip is kept per city, separately from existing one-day drafts. Saving a day inside a whole trip updates that trip rather than the standalone city day draft.

## Source map

- `lib/widgets/planner_mode_switch.dart`: the two responsive mode cards.
- `lib/screens/day_planner_screen.dart`: airport-free inputs, start time, local-day calculation and optional save callback for a whole-trip day.
- `lib/screens/whole_trip_screen.dart`: dates, 2–7 day controls, daily editing/timetable preview, copy/save, plus the saved-trip/city chooser screen.
- `lib/models/whole_trip.dart`: dates and independent daily inputs, JSON validation and rebuilding a day's timetable.
- `lib/services/whole_trip_store.dart`: new `travel_explorer.whole_trips.v1` key. Serial saves preserve different city trips and unreadable storage is not silently overwritten.
- `lib/models/day_plan.dart`: `includeArrival` keeps the old helper default, while the UI sets false to remove arrival/check-in blocks. Timetable totals and the midnight validation account for this mode.
- `lib/screens/explorer_screen.dart`: Plan your visit wording and the Whole trip plans entry under My day.
- `test/app_test.dart`: updated airport-free day-flow assertions.
- `test/whole_trip_test.dart`: local timing, midnight, model/date validation, persistence, concurrent city saves and corrupt-storage behaviour.
- `test/planning_modes_test.dart`: phone mode switching, two independent edited/saved days, reopening a trip, standalone draft isolation, seven-day selection and small-screen/large-text layout.
- `README.md` and this file: current usage and interview notes.

## Compatibility and limits

Neon/API, login, preference/onboarding flags, existing local-store implementations and standalone draft schema are unchanged. The old draft field names `origin`, `hotel` and `arrivalMinutes` remain internally for compatibility; the day UI uses a generic starting point and start time. Old saved inputs load, with the timetable rebuilt without arrival/check-in stages. Existing independent day drafts are not deleted or overwritten by whole-trip saves.

Whole trips cover a single city each. There is no intercity routing, flight booking, live transport time, hotel availability or price claim. Timings are editable planning buffers and users should verify routes and hours. The app saves locally, not to a new cloud service.

A damaged whole-trip storage record produces an error message and cannot be overwritten through Save; users can still plan/copy in the current session. Native Android installation remains untested because the SDK is unavailable on this laptop.

## Verification

- 58 automated tests passed, including all existing onboarding/preferences/travel tests.
- Analyzer: zero errors/warnings; the same 36 existing informational lint notices remain.
- Core arithmetic/validation, URL-encoding and destination checks passed.
- Web release build passed.
- Live 390×844 browser check confirmed Plan your visit → both mode cards, the airport-free day form, and the dated whole-trip editor. Screenshots: `planning-modes-mobile.jpg` and `whole-trip-mobile.jpg` in `docs/screenshots/`.
- Layout tests include 390×844 and 320×568 with 1.3× text scaling; existing 1.5× layout checks still pass.
- Local-trip tests confirm that a day starts at the selected time, excludes arrival/check-in/waiting stages, returns to its base and rejects a schedule past midnight.
- Persistence checks confirm two distinct saved days survive reopening; concurrent city saves preserve both trips; standalone drafts remain untouched; corrupt storage is preserved rather than replaced.

## Explain it in the interview

“I reused the day form for both modes. A whole trip is just a start date and a list of daily inputs. The day editor receives a save callback, so the same form can save to a whole trip or the original standalone draft. A separate storage key keeps those drafts apart. Day schedules use the local-outing mode, which removes airport and hotel-arrival assumptions. I kept the calculations deterministic and tested persistence, timing and mobile layouts.”
