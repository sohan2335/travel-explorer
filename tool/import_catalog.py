"""Make a reviewable JSON preview from a downloaded tourism CSV.

This is a maintenance tool, not code the app runs. No accounts/API keys needed.
Example: python tool/import_catalog.py source.csv --source huggingface
"""
import argparse
import csv
import json
from pathlib import Path


def read_places(path, source):
    with Path(path).open(encoding="utf-8-sig", newline="") as stream:
        reader = csv.DictReader(stream)
        required = {"city", "country", "interest_title", "interest_type"} if source == "huggingface" else {"City", "Name"}
        if not required.issubset(reader.fieldnames or []):
            raise ValueError(f"Missing required columns: {sorted(required - set(reader.fieldnames or []))}")
        places = []
        seen = set()
        for row in reader:
            if source == "huggingface":
                if row["interest_type"].strip() != "see":
                    continue
                city, country, name = row["city"], row["country"], row["interest_title"]
            else:
                city, country, name = row["City"], "India", row["Name"]
            city, country, name = city.strip(), country.strip(), name.strip()
            key = (city.casefold(), country.casefold(), name.casefold())
            if not city or not country or not name or key in seen:
                continue
            seen.add(key)
            places.append({"city": city, "country": country, "attraction": name, "source": source})
        return places


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv")
    parser.add_argument("--source", required=True, choices=["huggingface", "kaggle"])
    parser.add_argument("--output", default="assets/data/import_preview.json")
    args = parser.parse_args()
    places = read_places(args.csv, args.source)
    destination = Path(args.output)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(places, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Prepared {len(places)} places for review in {destination}.")
    print("Review accuracy, licensing and image credits before adding selected entries to lib/data/more_destinations.dart.")
