#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

OperationCounts = Dict[str, int]


def parse_taintres(path: Path) -> Tuple[OperationCounts, Optional[int]]:
    counts: OperationCounts = {}
    total_taints: Optional[int] = None
    lines = path.read_text().splitlines()
    marker_index = None

    for idx, line in enumerate(lines):
        if "all taint position!" in line:
            marker_index = idx
            break
        if "!Tainted" in line:
            stripped = line.strip()
            if not stripped:
                continue
            op = stripped.split()[0]
            counts[op] = counts.get(op, 0) + 1

    if marker_index is not None:
        for follow in lines[marker_index + 1 :]:
            match = re.search(r"\d+", follow)
            if match:
                total_taints = int(match.group(0))
                break

    return counts, total_taints


def parse_trans(path: Path) -> Tuple[Optional[int], Optional[int]]:
    all_sensitive = None
    left_sensitive = None
    lines = path.read_text().splitlines()
    for idx, line in enumerate(lines):
        lower = line.strip().lower()
        if lower.startswith("all sensitive"):
            if idx + 1 < len(lines):
                match = re.search(r"\d+", lines[idx + 1])
                if match:
                    all_sensitive = int(match.group(0))
        if lower.startswith("left sensitive"):
            if idx + 1 < len(lines):
                match = re.search(r"\d+", lines[idx + 1])
                if match:
                    left_sensitive = int(match.group(0))
    return all_sensitive, left_sensitive


def find_detailtime_csv(start: Path) -> Optional[Tuple[Path, str]]:
    """Locate the nearest timing CSV and identify its schema.

    We have three expected layouts:
    * "detailtime.csv" from `vfct_all.py`, which includes columns such as
      "add-key"/"taint-analysis" and the rest of the pipelines.
    * "one_and_two_and_three_detail.csv" from `vfct_find_bug.py`.
    * "detailtime.csv" emitted by `vfct_123.py`, which only contains the
      1+2+3 pipeline columns "1"/"2"/"2-2"/"3".
    """

    for parent in [start] + list(start.parents):
        for candidate in (
            parent / "detailtime.csv",
            parent / "one_and_two_and_three_detail.csv",
        ):
            if not candidate.exists():
                continue

            # Try to infer which schema is present by inspecting the header.
            with candidate.open(newline="") as f:
                reader = csv.reader(f)
                header = next(reader, [])

            header_set = set(header)
            if "add-key" in header_set or "taint-analysis" in header_set:
                return candidate, "vfct_all"
            if {"1", "2", "2-2", "3"}.issubset(header_set):
                return candidate, "vfct_123"
            return candidate, "vfct_find_bug"

    return None


def parse_phase_times(
    detail_csv: Path, kind: str, lib: str, filename: str, entry: str
) -> Tuple[Optional[float], Optional[float], Optional[float]]:
    with detail_csv.open(newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if kind == "vfct_all":
                if not (
                    row.get("LIB") == lib
                    and row.get("Filename") == filename
                    and row.get("Entry-point") == entry
                ):
                    continue

                def float_or_none(key: str) -> Optional[float]:
                    val = row.get(key)
                    if val is None or val == "":
                        return None
                    try:
                        return float(val)
                    except ValueError:
                        return None

                phase1_parts = [float_or_none("add-key"), float_or_none("taint-analysis")]
                phase2_parts = [float_or_none("2-generatebpl"), float_or_none("2-product"), float_or_none("2-verify")]
                phase3_parts = [float_or_none("3-generatebpl"), float_or_none("3-product"), float_or_none("3-verify")]
            elif kind == "vfct_123":
                if not (
                    row.get("LIB") == lib
                    and row.get("Filename") == filename
                    and row.get("Entry-point") == entry
                ):
                    continue

                def float_or_none(key: str) -> Optional[float]:
                    val = row.get(key)
                    if val is None or val == "":
                        return None
                    try:
                        return float(val)
                    except ValueError:
                        return None

                phase1_parts = [float_or_none("1")]
                phase2_parts = [float_or_none("2"), float_or_none("2-2")]
                phase3_parts = [float_or_none("3")]

            else:
                if not (
                    row.get("LIB") == lib
                    and row.get("crypto") == filename
                    and row.get("algoritm") == entry
                ):
                    continue

                def float_or_none(key: str) -> Optional[float]:
                    val = row.get(key)
                    if val is None or val == "":
                        return None
                    try:
                        return float(val)
                    except ValueError:
                        return None

                phase1_parts = [float_or_none("1")]
                phase2_parts = [float_or_none("product1")]
                phase3_parts = [float_or_none("product2")]

            def safe_sum(values: List[Optional[float]]) -> Optional[float]:
                nums = [v for v in values if v is not None]
                return sum(nums) if nums else None

            return safe_sum(phase1_parts), safe_sum(phase2_parts), safe_sum(phase3_parts)
    return None, None, None


def format_section(title: str, lines: List[str]) -> str:
    body = "\n".join(f"  {line}" for line in lines)
    return f"{title}\n{body}\n"


def main() -> None:
    workdir = Path.cwd()
    taint_files = sorted(workdir.glob("*-taintres.txt"))
    if not taint_files:
        raise SystemExit("No *-taintres.txt files found in the current directory.")

    detail_csv_info = find_detailtime_csv(workdir)
    output_lines: List[str] = []

    for taint_file in taint_files:
        entry = taint_file.stem.replace("-taintres", "")
        trans_file = workdir / f"{entry}-trans.txt"
        trans_missing_reason = None

        op_counts, total_taints = parse_taintres(taint_file)
        if trans_file.exists():
            all_sensitive, left_sensitive = parse_trans(trans_file)
        else:
            all_sensitive = left_sensitive = None
            trans_missing_reason = (
                "missing transfer file (vfct_find_bug.py does not emit -trans.txt)"
            )

        lib = workdir.parents[1].name if len(workdir.parents) >= 2 else ""
        filename = workdir.parents[0].name if workdir.parents else ""

        phase1 = phase2 = phase3 = None
        if detail_csv_info:
            csv_path, csv_kind = detail_csv_info
            phase1, phase2, phase3 = parse_phase_times(csv_path, csv_kind, lib, filename, entry)

        output_lines.append(f"Entry: {entry}")
        output_lines.append("Taint operation counts:")
        if op_counts:
            for op, count in sorted(op_counts.items()):
                output_lines.append(f"  {op}: {count}")
        else:
            output_lines.append("  (no tainted operations listed)")

        if total_taints is not None:
            output_lines.append(f"Total tainted operations: {total_taints}")

        if all_sensitive is not None:
            output_lines.append(f"All sensitive (phase 3 input): {all_sensitive}")
        if left_sensitive is not None:
            output_lines.append(f"Left sensitive (after phase 3): {left_sensitive}")
        if all_sensitive is None and left_sensitive is None and trans_missing_reason:
            output_lines.append(f"Phase 3 sensitivity counts unavailable: {trans_missing_reason}")

        output_lines.append("Phase timings (seconds):")
        output_lines.append(f"  Phase 1: {phase1 if phase1 is not None else 'n/a'}")
        output_lines.append(f"  Phase 2: {phase2 if phase2 is not None else 'n/a'}")
        output_lines.append(f"  Phase 3: {phase3 if phase3 is not None else 'n/a'}")
        output_lines.append("")

    output_path = workdir / "summary.txt"
    output_path.write_text("\n".join(output_lines).rstrip() + "\n")
    print(f"Wrote summary to {output_path}")


if __name__ == "__main__":
    main()
