"""Normalize the Olist reviews CSV for MySQL LOAD DATA INFILE.

The source is parsed with Python's RFC-compliant CSV reader. Review comments
with embedded line breaks are flattened to spaces because MySQL's bulk CSV
parser cannot reliably consume multiline records. Empty fields are emitted as
the MySQL NULL marker.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from collections import Counter
from pathlib import Path


FIELDS = [
    "review_id",
    "order_id",
    "review_score",
    "review_comment_title",
    "review_comment_message",
    "review_creation_date",
    "review_answer_timestamp",
]


def normalize(value: str | None, field: str) -> str:
    if value is None or value == "":
        return r"\N"
    if field in {"review_comment_title", "review_comment_message"}:
        value = value.replace("\r\n", " ").replace("\r", " ").replace("\n", " ")
    # Keep the tab-delimited intermediate unambiguous for LOAD DATA.
    return value.replace("\\", "\\\\").replace("\t", r"\t")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()

    counts = Counter()
    review_ids: Counter[str] = Counter()
    order_ids: Counter[str] = Counter()
    pair_counts: Counter[tuple[str, str]] = Counter()
    multiline_rows = 0

    with args.source.open("r", encoding="utf-8-sig", newline="") as source, args.output.open(
        "w", encoding="utf-8", newline="\n"
    ) as output:
        reader = csv.DictReader(source)
        if reader.fieldnames != FIELDS:
            raise ValueError(f"Unexpected CSV header: {reader.fieldnames!r}")
        for row_number, row in enumerate(reader, 2):
            if any(row.get(field) is None for field in FIELDS):
                raise ValueError(f"Missing field at CSV record {row_number}")
            if "\n" in row["review_comment_message"] or "\r" in row["review_comment_message"]:
                multiline_rows += 1
            review_ids[row["review_id"]] += 1
            order_ids[row["order_id"]] += 1
            pair_counts[(row["review_id"], row["order_id"])] += 1
            output.write("\t".join(normalize(row[field], field) for field in FIELDS) + "\n")
            counts["records"] += 1

    duplicate_review_ids = sum(count - 1 for count in review_ids.values() if count > 1)
    duplicate_order_ids = sum(count - 1 for count in order_ids.values() if count > 1)
    duplicate_pairs = sum(count - 1 for count in pair_counts.values() if count > 1)
    if duplicate_pairs:
        raise ValueError(f"Duplicate review_id/order_id pairs: {duplicate_pairs}")

    report = {
        "source_records": counts["records"],
        "output_records": counts["records"],
        "rejected_records": 0,
        "multiline_comments_flattened": multiline_rows,
        "duplicate_review_ids": duplicate_review_ids,
        "duplicate_order_ids": duplicate_order_ids,
        "duplicate_review_order_pairs": duplicate_pairs,
        "source_sha256": hashlib.sha256(args.source.read_bytes()).hexdigest(),
    }
    if args.report:
        args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
