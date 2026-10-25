# Travel Explorer demo: 2 minutes 50 seconds

The prepared MP4 and separate timed voice-over text are supplied in the
workspace `outputs/demo/` folder as `Travel_Explorer_Demo.mp4` and
`Voice_Over_Script.txt`. Record your own narration before submission.

## Walkthrough order

- **00:00–00:10:** Home screen and city photographs.
- **00:10–00:25:** Swipe through the destination photographs and their category labels.
- **00:25–00:45:** Enter GOA, select Beaches, switch to Mountains, then restore Beaches.
- **00:45–01:12:** Open the Goa guide, show its best season, then Palolem Beach, Fort Aguada and Fontainhas.
- **01:12–01:30:** Save Goa, open Saved, remove it, save again and recreate app state to restore it.
- **01:30–01:58:** Open Match my trip, select Mountains, Budget and 4 days, then show Manali and its reasons.
- **01:58–02:21:** Choose Goa, show Dining, open the planner, generate the timetable and save its draft.
- **02:21–02:33:** Switch to Plan whole trip, select three days, show the day cards, then save.
- **02:33–02:50:** Return to Home while the implementation summary is displayed.

## Implementation points to explain

- Destination objects hold the name, location, category, description and attractions.
- TravelController shares filter and saved-ID state; ChangeNotifier updates the widgets.
- Name search uses lowercase contains; category and country are combined using AND.
- The matcher awards one point per selected preference matched, with alphabetical ties.
- Budget styles and visit lengths are sample planning tags, not a live price service.
- Production saving uses browser localStorage or the existing Android storage bridge.
- Day plans use editable transfer buffers and saved drafts; whole trips hold separate days.

## Capture and verification

The video shows actual Flutter widget navigation at a 390 × 844 mobile layout,
captured in an isolated demo session by `tool/record_demo_test.dart`.
The demo uses bundled venue data and an isolated local-store implementation.
Recreating app state exercises the same JSON save/restore interface without
using the owner’s browser account or personal drafts. This is a UI demo, not
a physical-phone recording. See VERIFICATION.md for automated check results.

## Before submission

1. Read the timed script aloud once, then add your own voice to the MP4.
2. Watch the final export and keep it between two and three minutes.
3. Upload the narrated copy to Google Drive with the PDF’s required public access.
4. Add its final link to the README and verify access while signed out.
5. The assignment asks for a public GitHub repository; check the repository’s
   submission visibility, since it was previously kept private by request.
6. Keep the supplied PHOTO_CREDITS.md alongside the demo.
