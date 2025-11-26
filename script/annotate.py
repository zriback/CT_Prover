#!/usr/bin/env python3
import sys
import os
import re

COMMENT_LABELS = {
    "branch": "TAINTED BRANCH",
    "load": "TAINTED DATA ACCESS",
    "div": "TAINTED DIVISION",
}

def error(msg):
    print(f"[ERROR] {msg}", file=sys.stderr)

def load_file(path):
    try:
        with open(path, 'r') as f:
            return f.read().splitlines()
    except Exception as e:
        error(f"Could not read file '{path}': {e}")
        sys.exit(1)

def extract_tainted_instructions(taint_lines):
    tainted = []
    br_re = re.compile(r"br i1\s+(%[\w\d]+),\s+label\s+(%[\w\d]+),\s+label\s+(%[\w\d]+).*!dbg\s+!(\d+)")
    load_re = re.compile(r"(?P<dest>%[\w\d\.]+)\s*=\s*load\b[^,]*,\s*[^%]*?(?P<pointer>%[\w\d\.]+).*!dbg\s+!(?P<dbg>\d+)")
    div_re = re.compile(
        r"(?P<dest>%[\w\d\.]+)\s*=\s*(?P<divop>fdiv|[su]?div|frem|[su]?rem)\b[^,]*,\s*(?P<rhs>[^,\s!]+).*!dbg\s+!(?P<dbg>\d+)"
    )

    for line in taint_lines:
        br_match = br_re.search(line)
        if br_match:
            tainted.append({
                "kind": "branch",
                "operands": (br_match.group(1), br_match.group(2), br_match.group(3)),
                "dbg": br_match.group(4),
            })
            continue

        load_match = load_re.search(line)
        if load_match:
            tainted.append({
                "kind": "load",
                "dest": load_match.group("dest"),
                "pointer": load_match.group("pointer"),
                "dbg": load_match.group("dbg"),
            })
            continue

        div_match = div_re.search(line)
        if div_match:
            tainted.append({
                "kind": "div",
                "dest": div_match.group("dest"),
                "dbg": div_match.group("dbg"),
            })

    if not tainted:
        error("No tainted instructions found in taintres file.")
    return tainted

def find_branch_in_ir(ir_lines, operands):
    (op_cond, op_t, op_f) = operands
    br_re = re.compile(
        r"br i1\s+" + re.escape(op_cond) +
        r",\s+label\s+" + re.escape(op_t) +
        r",\s+label\s+" + re.escape(op_f) +
        r".*!dbg\s+!(\d+)"
    )

    for idx, line in enumerate(ir_lines):
        m = br_re.search(line)
        if m:
            return idx, int(m.group(1))

    error(f"Could not find matching IR branch for operands {operands}")
    return None, None


def find_load_in_ir(ir_lines, dest, pointer):
    load_re = re.compile(
        r"(?<!\\S)" + re.escape(dest) +
        r"\s*=\s*load\b.*?,\s*[^,]*\s+" + re.escape(pointer) +
        r"(?![\w\.]).*!dbg\s+!(\d+)"
    )

    for idx, line in enumerate(ir_lines):
        m = load_re.search(line)
        if m:
            return idx, int(m.group(1))

    error(f"Could not find matching IR load for dest {dest} and pointer {pointer}")
    return None, None


def find_div_in_ir(ir_lines, dest):
    div_re = re.compile(
        r"(?<!\\S)" + re.escape(dest) +
        r"\s*=\s*(?:fdiv|[su]?div|frem|[su]?rem)\b.*!dbg\s+!(\d+)"
    )

    for idx, line in enumerate(ir_lines):
        m = div_re.search(line)
        if m:
            return idx, int(m.group(1))

    error(f"Could not find matching IR division for dest {dest}")
    return None, None

def parse_ir_metadata(ir_path, ll_dir):
    difiles = {}
    scopes = {}
    dilocs = {}

    def resolve_di_path(name, directory):
        if os.path.isabs(name):
            return os.path.abspath(name)

        base = ll_dir
        if directory:
            if os.path.isabs(directory):
                base = directory
            else:
                base = os.path.abspath(os.path.join(ll_dir, directory))

        return os.path.abspath(os.path.join(base, name))

    difile_re = re.compile(
        r"!(\d+)\s*=\s*!DIFile\([^)]*filename:\s*\"([^\"]+)\"[^)]*directory:\s*\"([^\"]*)\"\)"
    )
    scope_re = re.compile(r"!(\d+)\s*=\s*(?:distinct\s+)?!DI(\w+)\(([^)]*)\)")
    file_field_re = re.compile(r"file:\s*!([0-9]+)")
    scope_field_re = re.compile(r"scope:\s*!([0-9]+)")
    diloc_re = re.compile(
        r"!(\d+)\s*=\s*!DILocation\([^)]*line:\s*(\d+)[^)]*scope:\s*!([0-9]+)(?:[^)]*inlinedAt:\s*!([0-9]+))?"
    )

    try:
        with open(ir_path, "r", errors="ignore") as f:
            for line in f:
                di_match = difile_re.search(line)
                if di_match:
                    di_id, name, directory = di_match.groups()
                    difiles[di_id] = resolve_di_path(name, directory)
                    continue

                loc_match = diloc_re.search(line)
                if loc_match:
                    loc_id, line_no, scope_id, inline_id = loc_match.groups()
                    dilocs[loc_id] = {
                        "line": int(line_no),
                        "scope": scope_id,
                        "inline": inline_id,
                    }
                    continue

                scope_match = scope_re.search(line)
                if scope_match:
                    scope_id, _kind, content = scope_match.groups()
                    file_field = file_field_re.search(content)
                    scope_field = scope_field_re.search(content)
                    file_id = file_field.group(1) if file_field else None
                    parent_scope = scope_field.group(1) if scope_field else None
                    if file_id or parent_scope:
                        scopes[scope_id] = {
                            "file": file_id,
                            "parent": parent_scope,
                        }
    except (OSError, UnicodeDecodeError):
        error("Failed to parse IR metadata.")
        return {}, {}, {}

    return difiles, scopes, dilocs


def resolve_scope_file(scope_id, scopes, difiles):
    seen = set()
    current = scope_id
    while current and current not in seen:
        seen.add(current)
        scope_info = scopes.get(current, {})
        file_id = scope_info.get("file")
        parent = scope_info.get("parent")
        if file_id and file_id in difiles:
            return difiles[file_id]
        current = parent
    return None


def resolve_dbg_location(dbg_id, scopes, difiles, dilocs):
    loc = dilocs.get(dbg_id)
    if not loc:
        return None, None

    inline = loc.get("inline")
    if inline and inline in dilocs:
        inline_scope = dilocs[inline].get("scope")
        path = resolve_scope_file(inline_scope, scopes, difiles)
        if path:
            return path, dilocs[inline].get("line")

    path = resolve_scope_file(loc.get("scope"), scopes, difiles)
    return path, loc.get("line")

def annotate_c_file(c_lines, tainted_line_types):
    output = []
    for i, line in enumerate(c_lines, start=1):
        if i in tainted_line_types:
            labels = []
            for kind in sorted(tainted_line_types[i]):
                phases = ",".join(str(p) for p in sorted(tainted_line_types[i][kind]))
                labels.append(f"{COMMENT_LABELS[kind]} [{phases}]")
            output.append(line + "    // " + " & ".join(labels))
        else:
            output.append(line)
    return output


def parse_transfer_sets(trans_path, bool_bpl_path, shadow_bpl_path):
    """Recover phase-2 and phase-3 survivors mapped to source locations."""

    if not (os.path.isfile(trans_path) and os.path.isfile(bool_bpl_path)):
        return set(), set()

    with open(trans_path, "r") as f:
        trans_lines = f.read().splitlines()

    poss = set()
    for line in trans_lines:
        if "{" in line and "}" in line:
            poss.update(int(m) for m in re.findall(r"\d+", line))
            break

    if not poss:
        return set(), set()

    def sourceloc_map(path):
        mapping = {}
        last_loc = None
        base_dir = os.path.dirname(os.path.abspath(path))
        loc_re = re.compile(r'\{:sourceloc\s+"([^"]+)",\s*(\d+),')
        with open(path, "r", errors="ignore") as f:
            for idx, line in enumerate(f):
                match = loc_re.search(line)
                if match:
                    raw_path, lineno = match.groups()
                    last_loc = (
                        os.path.abspath(os.path.join(base_dir, raw_path)),
                        int(lineno),
                    )
                if idx in poss and last_loc:
                    mapping[idx] = last_loc
        return mapping

    phase2_map = sourceloc_map(bool_bpl_path)
    phase2_locs = set(phase2_map.values())

    phase3_locs = set()
    if os.path.isfile(shadow_bpl_path):
        patterns = [
            r".*\$shadow_ok := \(\$shadow_ok.*",
            r".*assert \$shadow_ok;",
            r".*assert \{:shadow_invariant\} \$shadow_ok;",
            r".*assert \{:shadow_invariant\} \(",
            r".*assert \{:likely_shadow_invariant\} \(",
            r".*assert \{:unlikely_shadow_invariant \(",
            r".*assert.*==.*",
        ]
        compiled = [re.compile(p) for p in patterns]
        shadow_loc_map = {}
        last_loc = None
        base_dir = os.path.dirname(os.path.abspath(shadow_bpl_path))
        loc_re = re.compile(r'\{:sourceloc\s+"([^"]+)",\s*(\d+),')
        with open(shadow_bpl_path, "r", errors="ignore") as f:
            for idx, line in enumerate(f):
                match = loc_re.search(line)
                if match:
                    raw_path, lineno = match.groups()
                    last_loc = (
                        os.path.abspath(os.path.join(base_dir, raw_path)),
                        int(lineno),
                    )
                if idx in poss and any(p.match(line) for p in compiled) and last_loc:
                    shadow_loc_map[idx] = last_loc
        phase3_locs = set(shadow_loc_map.values())

    return phase2_locs, phase3_locs

def main():
    if len(sys.argv) < 3:
        error("Usage: python annotate.py [taintres] [llvm IR] [output_dir (optional)]")
        sys.exit(1)

    taint_path = sys.argv[1]
    ir_path = sys.argv[2]
    output_dir = sys.argv[3] if len(sys.argv) > 3 else None

    taint_lines = load_file(taint_path)
    ir_lines = load_file(ir_path)
    ll_dir = os.path.dirname(os.path.abspath(ir_path))
    output_base = os.path.abspath(output_dir) if output_dir else None

    base_dir = os.path.dirname(os.path.abspath(taint_path))
    entry = os.path.basename(taint_path).replace("-taintres.txt", "")
    trans_path = os.path.join(base_dir, f"{entry}-trans.txt")
    bool_bpl_path = os.path.join(base_dir, f"{entry}-bool.bpl")
    shadow_bpl_path = os.path.join(base_dir, f"{entry}-shadow.bpl")

    phase2_locs, phase3_locs = parse_transfer_sets(
        trans_path, bool_bpl_path, shadow_bpl_path
    )

    difiles, scopes, dilocs = parse_ir_metadata(ir_path, ll_dir)
    if not difiles or not dilocs:
        error("No debug metadata found; cannot resolve source files.")
        sys.exit(1)

    tainted_ops = extract_tainted_instructions(taint_lines)
    if not tainted_ops:
        error("No tainted patterns extracted.")
        sys.exit(1)

    tainted_per_file = {}

    for tainted in tainted_ops:
        if tainted.get("kind") == "branch":
            operands = tainted["operands"]
            print(f"[INFO] Processing tainted branch: {operands}")
            ir_idx, dbg_num = find_branch_in_ir(ir_lines, operands)
            comment_kind = "branch"
        elif tainted.get("kind") == "load":
            print(f"[INFO] Processing tainted load: dest={tainted['dest']}, pointer={tainted['pointer']}")
            ir_idx, dbg_num = find_load_in_ir(ir_lines, tainted["dest"], tainted["pointer"])
            comment_kind = "load"
        elif tainted.get("kind") == "div":
            print(f"[INFO] Processing tainted division: dest={tainted['dest']}")
            ir_idx, dbg_num = find_div_in_ir(ir_lines, tainted["dest"])
            comment_kind = "div"
        else:
            error(f"Unknown taint kind: {tainted}")
            continue

        if ir_idx is None or dbg_num is None:
            error(f"Skipping this tainted instruction (missing IR match or dbg).")
            continue

        print(f"[INFO] Found IR {comment_kind} at line {ir_idx+1}, dbg !{dbg_num}")

        src_path, c_line = resolve_dbg_location(str(dbg_num), scopes, difiles, dilocs)
        if not src_path or not c_line:
            error(f"Could not map dbg !{dbg_num} to C source; skipping.")
            continue

        normalized_src = os.path.abspath(src_path)
        if output_base:
            src_path = normalized_src

        phases = [1]
        if (normalized_src, c_line) in phase2_locs:
            phases.append(2)
        if (normalized_src, c_line) in phase3_locs:
            if 2 not in phases:
                phases.append(2)
            phases.append(3)

        print(f"[INFO] Corresponds to C source {src_path} line {c_line}")
        file_entry = tainted_per_file.setdefault(src_path, {})
        file_entry.setdefault(c_line, {})
        file_entry[c_line].setdefault(comment_kind, set()).update(phases)

    if not tainted_per_file:
        error("No successful taint→source mappings. No marked files will be written.")
        sys.exit(1)

    for src_path, tainted_c_lines in tainted_per_file.items():
        if not os.path.isfile(src_path):
            error(f"Resolved source file does not exist: {src_path}")
            continue

        c_lines = load_file(src_path)
        annotated = annotate_c_file(c_lines, tainted_c_lines)

        base_name = os.path.basename(src_path)
        stem, ext = os.path.splitext(base_name)
        output_name = f"{stem}_marked{ext or '.c'}"
        dest_dir = output_base if output_base else os.path.dirname(src_path)
        os.makedirs(dest_dir, exist_ok=True)
        out_file = os.path.join(dest_dir, output_name)

        try:
            with open(out_file, "w") as f:
                for line in annotated:
                    f.write(line + "\n")
        except Exception as e:
            error(f"Could not write output file '{out_file}': {e}")
            continue

        print(f"[INFO] Annotated C file written to: {out_file}")

if __name__ == "__main__":
    main()

