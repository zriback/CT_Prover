#!/usr/bin/env python3
import os
import re
import sys
from typing import Dict, Set, Tuple


def parse_debug_locations(ll_path: str) -> Dict[str, Tuple[str, int]]:
    location_map: Dict[str, Tuple[str, int]] = {}
    file_map: Dict[str, str] = {}
    scope_file_map: Dict[str, str] = {}

    file_re = re.compile(r"!([0-9]+) = !DIFile\((.*)\)")
    location_re = re.compile(r"!([0-9]+) = !DILocation\((.*)\)")
    scope_re = re.compile(r"!([0-9]+) = !DISubprogram\((.*)\)")

    def extract_attr(attrs: str, name: str) -> str:
        match = re.search(rf"{name}:\s*\"([^\"]+)\"", attrs)
        return match.group(1) if match else ""

    def extract_numeric_attr(attrs: str, name: str) -> str:
        match = re.search(rf"{name}:\s*!([0-9]+)", attrs)
        return match.group(1) if match else ""

    try:
        with open(ll_path, "r") as llvm_ir:
            for line in llvm_ir:
                file_match = file_re.match(line)
                if file_match:
                    file_id = file_match.group(1)
                    attrs = file_match.group(2)
                    filename = extract_attr(attrs, "filename")
                    directory = extract_attr(attrs, "directory")
                    if filename:
                        file_map[file_id] = os.path.join(directory, filename) if directory else filename
                    continue

                scope_match = scope_re.match(line)
                if scope_match:
                    scope_id = scope_match.group(1)
                    attrs = scope_match.group(2)
                    file_id = extract_numeric_attr(attrs, "file")
                    if file_id:
                        scope_file_map[scope_id] = file_id
                    continue

                loc_match = location_re.match(line)
                if loc_match:
                    loc_id = loc_match.group(1)
                    attrs = loc_match.group(2)
                    line_no = extract_numeric_attr(attrs, "line")
                    file_id = extract_numeric_attr(attrs, "file")
                    scope_id = extract_numeric_attr(attrs, "scope")
                    ref_file_id = file_id or scope_file_map.get(scope_id)
                    if line_no and ref_file_id and ref_file_id in file_map:
                        location_map[loc_id] = (file_map[ref_file_id], int(line_no))
    except OSError as exc:
        print(f"[ERROR] Could not read file '{ll_path}': {exc}", file=sys.stderr)

    return location_map


def gather_tainted_locations(taintres_path: str, ll_path: str) -> Dict[str, Set[int]]:
    tainted_ids: Set[str] = set()
    try:
        with open(taintres_path, "r") as taintres_file:
            for line in taintres_file:
                if "!Tainted" in line:
                    match = re.search(r"!dbg\s*!([0-9]+)", line)
                    if match:
                        tainted_ids.add(match.group(1))
    except OSError as exc:
        print(f"[ERROR] Could not read file '{taintres_path}': {exc}", file=sys.stderr)
        return {}

    if not tainted_ids:
        return {}

    location_map = parse_debug_locations(ll_path)
    locations_by_file: Dict[str, Set[int]] = {}
    for loc_id in tainted_ids:
        if loc_id in location_map:
            file_path, line_no = location_map[loc_id]
            locations_by_file.setdefault(file_path, set()).add(line_no)

    return locations_by_file


def resolve_candidate(path: str, base_dir: str) -> str:
    if os.path.isabs(path):
        return os.path.abspath(path)
    return os.path.abspath(os.path.join(base_dir, path))


def annotate_source(taintres_path: str, ll_path: str, source_path: str, output_path: str) -> int:
    source_abs = os.path.abspath(source_path)
    ll_base = os.path.dirname(os.path.abspath(ll_path)) or os.getcwd()

    if not os.path.isfile(source_abs):
        print(f"[ERROR] Could not read file '{source_path}': [Errno 2] No such file or directory: '{source_path}'", file=sys.stderr)
        return 1
    if not os.path.isfile(taintres_path):
        print(f"[ERROR] Could not read file '{taintres_path}': [Errno 2] No such file or directory: '{taintres_path}'", file=sys.stderr)
        return 1
    if not os.path.isfile(ll_path):
        print(f"[ERROR] Could not read file '{ll_path}': [Errno 2] No such file or directory: '{ll_path}'", file=sys.stderr)
        return 1

    tainted_locations = gather_tainted_locations(taintres_path, ll_path)
    tainted_lines: Set[int] = set()

    for path, lines in tainted_locations.items():
        resolved = resolve_candidate(path, ll_base)
        try:
            if os.path.samefile(resolved, source_abs):
                tainted_lines.update(lines)
                continue
        except FileNotFoundError:
            pass

        # Fall back to basename match if samefile resolution fails
        if os.path.basename(resolved) == os.path.basename(source_abs):
            tainted_lines.update(lines)

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)

    with open(source_abs, "r") as src, open(output_path, "w") as dst:
        for idx, line in enumerate(src, 1):
            line_out = line.rstrip("\n")
            if idx in tainted_lines:
                line_out += " // TAINTED"
            dst.write(line_out + "\n")

    return 0


def main() -> int:
    args = sys.argv[1:]
    if len(args) == 3:
        taintres_path, ll_path, source_path = args
        output_path = source_path
    elif len(args) == 4:
        taintres_path, ll_path, source_path, output_path = args
    else:
        print("Usage: annotate.py <taintres file> <k.ll file> <source c file> <output c file>", file=sys.stderr)
        return 1

    return annotate_source(taintres_path, ll_path, source_path, output_path)


if __name__ == "__main__":
    sys.exit(main())
