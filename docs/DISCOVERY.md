# City discovery: a beginner walkthrough

The supplied video inspired the dark plum background, colourful category tiles, large city imagery and cards. Its branding, ratings, prices and photos were not copied.

`DiscoveryShortcuts` is six buttons in a two-row phone grid or a desktop row. The selected city and category are ordinary strings. `CityDiscoverScreen` filters `LocalPlace` objects by `cityId` and `kind`. A FutureBuilder shows the asynchronous database result. Official links are stored with each directory entry; the checked date says when the source was reviewed, not that the place is open now.

“Find nearby” builds a Maps query around the chosen attraction. The in-app curated cards are citywide, not distance-ranked. Accurate nearest sorting would require coordinates for the starting point and each venue. Room/table availability and real-time prices need an inventory provider; Neon does not supply travel content automatically.

Choosing a stay, meal or main outing opens the same planner for any of the ten cities. It prefills that field without silently overwriting the saved draft. The user must save explicitly. A chosen restaurant adds a transfer from the attraction and becomes the return-route starting point. Restaurant and visit-duration inputs are stored with the draft; older drafts remain readable. Parks start with a four-hour editable visit buffer, not a claim about the time required. Check opening hours and the full route before using a plan.

Useful next improvements after this version is understood:
- Curate more budget stays and food options using official sources, with more options in each city.
- Add verified coordinates and sort by approximate straight-line distance from a chosen landmark. Keep road travel time with a route provider.
- Add a second day only after the one-day flow, saving and validation are reliable.

To add a listing, edit the offline JSON and add a matching row through the Neon SQL editor. Use one of hotel, restaurant, adventure, waterpark or mall, a known city ID, an official HTTPS source and a checked date. Never invent ratings, discounts or availability.
