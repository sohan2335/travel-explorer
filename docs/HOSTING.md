# Free database and web hosting

## Already connected

Neon project `travel-explorer` is in the existing free organization, in Singapore. Project ID: `divine-flower-42428423`; database `travel_explorer`; branch `production` (`br-odd-hall-a1al957u`). The existing unrelated project was not changed.

The public `places` table holds 24 curated listings across all ten cities. Every city has a sourced stay and dining example; other categories offer Maps searches when there is no curated entry. This directory does not contain live booking inventory, prices, ratings or GPS distances.

Flutter fetches a short-lived guest token and reads the Data API. Public read access uses PostgreSQL privileges and a SELECT-only row policy. Anonymous INSERT, UPDATE and DELETE privileges were checked and are false. Database passwords and admin tokens are not shipped in Flutter. Wishlists and user trip inputs stay on the device; the cloud only stores the public directory.

Files: `backend/schema.sql` describes the table/permissions, `backend/seed.sql` seeds a new empty database, `assets/data/places.json` is the offline copy, and `lib/services/place_catalog.dart` loads the cloud then falls back if it cannot be reached. Do not rerun the schema on the existing initialized database. Maintain listings through the Neon SQL editor and update the offline copy too.

Neon currently offers a free plan with 1 GB database storage per project and 100 CU-hours/month/project. This is a quota, not unlimited hosting. Check [current pricing](https://neon.com/pricing) before changing plans. The organization remains on Free.

## Host the Flutter web app on GitHub Pages

A database stores data; a separate web host serves the Flutter build. GitHub Pages can serve the static build from a public repository on GitHub Free. The prepared workflow is `.github/workflows/deploy-web.yml`; it has not been run here.

1. Push the contents of the `travel_explorer` folder as the repository root. The workflow expects `pubspec.yaml` at the root.
2. In repository Settings → Pages, choose GitHub Actions as the build source.
3. In the new Neon project's Auth configuration, add your exact Pages origin (for example `https://YOUR-USERNAME.github.io`) to trusted domains. Do not include the repository path. Localhost is already allowed; production origins need their own entry.
4. Run `flutter test` and `flutter analyze` locally and resolve any issues. The workflow runs the tests before building.
5. From Actions, manually run “Deploy Flutter web to GitHub Pages”. It builds the correct repository base path and deploys `build/web`.
6. Open the deployed URL, choose a city and category, and confirm “Cloud directory · Neon”. If it shows the bundled directory, verify the Neon trusted origin and connectivity.
7. Save a test wishlist entry and trip, reload, and resume. Local saves belong to each browser profile/origin; localhost saves do not transfer to the public URL.

The app is not publicly deployed yet. No hosting domain or repository was invented. The workflow needs a real public repository and a successful test run.

Sources: [Flutter web deployment](https://docs.flutter.dev/deployment/web), [GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages), [Neon Data API access control](https://neon.com/docs/data-api/access-control).
