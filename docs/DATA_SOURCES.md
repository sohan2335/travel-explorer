# Where the data comes from

## Included now

The app has ten destinations: the original six plus Hyderabad, Agra, Paris, and Rome. The original six, Hyderabad, and Agra use curated sample content. Descriptions are editorial summaries, not live visitor information.

Selected fields for Paris and Rome were checked against the readable [SynthTRIPs knowledge-base CSV](https://huggingface.co/datasets/ashmib/SynthTRIPs/blob/main/kb/eu-cities-database.csv). A small record of those fields is in assets/data/huggingface_selected_fields.csv. The app's more_destinations.dart uses the country/high-season values; Paris's Eiffel Tower and Arc de Triomphe are also listed in that source. Rome's two attractions are curated additions, not extracted from its source rows.

The dataset [card](https://huggingface.co/datasets/ashmib/SynthTRIPs) lists MIT. Citation: Ashmi Banerjee, Adithi Satish, Fitri Nur Aisyah, Wolfgang Wörndl, and Yashar Deldjoo, "SynthTRIPs: A Knowledge-Grounded Framework for Benchmark Query Generation for Personalized Tourism Recommenders," SIGIR 2025, DOI 10.1145/3726302.3730321. This app reuses a few factual fields rather than the generated queries or long descriptions. High season describes a dataset field; it does not guarantee weather, opening hours, affordability, or the best time for every visitor.

The four new cities use remote Commons photographs and need internet for those photos. Their text, filtering, wishlist, and day planner work without network access. The original six cities' photos are bundled offline. See IMAGE_CREDITS.md for attribution and image-license links.

## Kaggle status: not imported

The candidate [Travel Dataset: Guide to India's Must See Places](https://www.kaggle.com/datasets/saketk511/travel-dataset-guide-to-indias-must-see-places) could not be downloaded from this execution session. No data in the app is falsely attributed to Kaggle. Its file contents and reuse license must be reviewed before importing.

If you download the CSV yourself, use:

```sh
python tool/import_catalog.py path/to/india.csv --source kaggle
```

For a downloaded SynthTRIPs knowledge-base CSV:

```sh
python tool/import_catalog.py path/to/eu-cities-database.csv --source huggingface
```

The script creates a **review preview**, not a live app database. It checks required columns, removes blank/duplicate place names, and extracts city/country/attraction names. After reviewing accuracy, licensing, and photographs, add a small selection to more_destinations.dart. Keeping the final list explicit makes the beginner app easier to read and explain. It does not run Python or contact Hugging Face/Kaggle inside the app.

## External services

Hotel buttons open Google Maps searches centred on a named attraction and city. They do not provide hotel recommendations ranked by the app, bookings, or live inventory. Transport buttons use [Google Maps URLs](https://developers.google.com/maps/documentation/urls/get-started), which do not require an API key. Driving can open [Uber's web app](https://m.uber.com/); travellers check city coverage and fare there. Bicycle mode provides a local rental search. No account, payment, or booking is created by this app.

## Place directory

`assets/data/places.json` and `backend/seed.json` contain twenty-four curated directory entries, each with an official source URL and checked date (18 October 2026). A matching copy is stored in the Neon `places` table. These rows are separate from the earlier destination dataset imports. No ratings, exact distances, prices or live inventory were imported. Brand photos from the reference video were not reused. Category cards use Flutter icons and gradients; the city hero images use the existing credited destination photos.
