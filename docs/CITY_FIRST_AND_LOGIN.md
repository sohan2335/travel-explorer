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
