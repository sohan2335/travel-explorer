# City-first browsing and profile

Updated 19 October 2026.

## What to demonstrate
1. Search for a city on the home screen and tap its photo.
2. A large dismissible bottom sheet opens. Choose Food, Shopping, Stays, Adventure, Water parks or Events.
3. Search venue names or neighbourhoods inside that city. Maps links search the whole selected city, without choosing a tourist spot first.
4. Use a restaurant or hotel in the existing day planner. Sights remain available under Sights & city guide.
5. Open the profile icon. Continue with Google, or use email sign-in / account creation. Guests can keep exploring.

## How the code works
- `explorer_screen.dart`: city cards call `showModalBottomSheet` with a CityDiscoverScreen.
- `city_discover_screen.dart`: stores the selected category and search text using setState; filters catalog entries by city, category and name/area.
- `discovery_shortcuts.dart`: category labels, icons and colours. Events is a discovery shortcut, not an invented database listing.
- `profile_screen.dart`: validates email/password, calls Neon Auth, displays the returned profile and signs out.
- `auth_web.dart`: sends HTTPS requests to the existing Neon Auth endpoint with browser credentials included. Neon manages the HTTP-only session cookie. The app does not save passwords or OAuth secrets.
- `main.dart`: near-black background, charcoal cards and purple accents, inspired by the new video.

## Honest limits
The directory still contains 24 curated examples across 10 destinations, not every venue in each city. Events opens a city-specific web search; no live events feed, dates or ticket availability are claimed. Venue Maps links can find additional listings.

Sign-in is implemented for Flutter web. Android/native sign-in requires additional platform integration and currently displays an explanatory message. Wishlist and trip drafts remain device-local, shared by users of that browser; account login does not sync them. Browser policies that block third-party session cookies can prevent session restoration. Production hosting requires adding its exact origin to Neon Auth trusted domains. Local preview origins 127.0.0.1:8766 and :8767 are configured.

Google's shared Neon provider is configured. The Google redirect reached the real Google sign-in page during verification; no personal credentials were entered. Completed login, account creation, session restoration and logout still need verification with the user's own account. Email signup may require email verification according to the Neon project's settings.

## Validation
- Release web compilation: passed.
- Pure Dart core checks: passed (planner, data, persistence parsing, links).
- Browser: city photo opens pop-up; Food category loads city-specific Neon results; Google redirect reaches Google sign-in.
- Full Flutter test runner remains blocked before suites load by local SocketException 10057. Updated widget tests reflect the extra city sheet and Sights & city guide step; run `flutter test` in your normal VS Code terminal.

Authentication reference: https://neon.com/docs/auth/authentication-flow

The bottom bar now contains Explore, Search, My trips, Wishlist and Profile. Search focuses city search; My trips opens saved drafts directly; Profile displays login/account controls in its own tab. All tabs have actions and use the existing simple state controller.

Phone browser checks also passed for the five-tab navigation, saved plan listings, city search autofocus and empty email/password validation. Login completion still requires a real user account. Full widget tests remain unexecuted due to the runner connection restriction described above.

## Activity categories
Home now offers Dining, Shopping, Events, Stays, Adventure parks and Water parks. These choose which city category opens; they do not filter out cities with no curated venues. Select an activity, then swipe or use arrows in the city carousel and tap a photo. Search and Wishlist retain a grid. The earlier Beaches/Mountains/Heritage filters and card badges were removed from the UI. Events remains an external discovery search rather than a live events feed.


## Latest update: multiple outings and completed login — 19 October 2026
The current bottom navigation is a floating rounded bar: Home, Hotlists and Search. Profile is accessed through the top-right account icon. Hotlists contains favourite cities and saved trip drafts. Activity choices now use large coloured icon tiles for Dining, Movies, Events, Shopping, Activities, Play, Salons, Stays and Water parks. Movies, Play and Salons use citywide external search; they have no curated database listings yet.

Open a city, choose Day plan, then Choose more stops. Pick up to four extra sights or directory venues, or enter a mall/event location yourself. The main outing plus extra stops makes at most five outings. Selected order becomes the route; move an extra stop earlier or remove it using its icons. Every outing uses the selected visit duration. Each extra outing adds a travel buffer. The timetable rejects routes going past midnight, and saved drafts retain the extra stops. Existing one-outing drafts still restore. This remains a planning template: it does not check event start times, opening hours or actual journey durations.

Login now completes Neon's callback step: get-session receives the returned session verifier, and the app removes that parameter after the server confirms a user. It also opens the profile automatically on callback. A fresh Google login completed in the browser and showed the signed-in account. The implementation follows the official Neon SDK getSession hook in https://github.com/neondatabase/neon-js/blob/main/packages/auth/src/core/better-auth-methods.ts . Session cookies remain managed by the browser; the app stores no password or Google token. Old/expired callbacks can require a fresh Google attempt.

Verification: all 19 Flutter tests passed using the normal runner with loopback access. Core Dart checks also passed for multi-stop ordering, transfer origins, contiguous times, duplicate rejection, midnight rejection and old/new saved draft compatibility. Browser verified selecting Fort Aguada and Fontainhas as extra Goa stops and generating a timetable containing all three outings. This test plan was not saved over any existing draft. Historical notes about a blocked runner and uncompleted Google login above have been superseded by these checks.


## Separate Search and animated activity icons
City-name search and country filtering are now shown only in the Search tab. Search filters that tab's results; Home always shows all city cards. Activity tiles use larger rounded icons on coloured gradient badges. A short bounce and tilt plays on entry and when the selection changes, using Flutter's TweenAnimationBuilder. There is no continuous animation or new icon package. Device reduced-motion preferences disable the motion. Tile height accommodates enlarged text.


## City guide readability update
The city guide now uses a photo header, a readable dark season card, explicit About this city / Browse city venues actions, full attraction cards with View guide and Plan a visit buttons, and a persistent planning button at the bottom. Plan a visit opens the planner with that attraction selected. Place-information sheets keep their close button in a fixed header. Shared buttons have a minimum 48px tap area and secondary text uses a stronger contrast colour. The enlarged-text phone test continues to check the guide and Hotlists flow.

Recommended next step: one shared My day list while browsing, so venue picks accumulate without replacing the main attraction. Then improve the small directory with more sourced venue details and add a map overview of the chosen stops. These are proposals, not implemented features; no live prices, event schedules or route optimisation are claimed.
