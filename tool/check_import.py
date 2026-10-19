"""Run with: python tool/check_import.py"""
import tempfile
import unittest
from pathlib import Path
from import_catalog import read_places


class ImportChecks(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(dir=Path(__file__).resolve().parent)
        self.addCleanup(self.directory.cleanup)
        self.file = Path(self.directory.name) / "sample.csv"

    def test_huggingface_keeps_sights_and_removes_duplicates(self):
        self.file.write_text("city,country,interest_title,interest_type\nParis,France,Eiffel Tower,see\nParis,France,Eiffel Tower,see\nParis,France,Cafe,eat\n", encoding="utf-8")
        rows = read_places(self.file, "huggingface")
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["attraction"], "Eiffel Tower")

    def test_kaggle_skips_blank_place_names(self):
        self.file.write_text("City,Name\nAgra,Taj Mahal\n,\n", encoding="utf-8")
        rows = read_places(self.file, "kaggle")
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["country"], "India")

    def test_wrong_schema_is_rejected(self):
        self.file.write_text("unknown\nx\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "Missing required columns"):
            read_places(self.file, "huggingface")


if __name__ == "__main__":
    unittest.main()
