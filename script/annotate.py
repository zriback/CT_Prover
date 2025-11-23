#!/usr/bin/env python3
import sys
import re
import os

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
    br_re = re.compile(r"br i1\s+(%[\w\d]+),\s+label\s+(%[\w\d]+),\s+label\s+(%[\w\d]+)")
    load_re = re.compile(r"(?P<dest>%[\w\d\.]+)\s*=\s*load\b[^,]*,\s*[^%]*?(?P<pointer>%[\w\d\.]+)")
    div_re = re.compile(r"(?P<dest>%[\w\d\.]+)\s*=\s*(?P<divop>fdiv|[su]?div)\b[^,]*,\s*(?P<rhs>%[\w\d\.]+)")

    for line in taint_lines:
        br_match = br_re.search(line)
        if br_match:
            tainted.append({
                "kind": "branch",
                "operands": (br_match.group(1), br_match.group(2), br_match.group(3)),
            })
            continue

        load_match = load_re.search(line)
        if load_match:
            tainted.append({
                "kind": "load",
                "dest": load_match.group("dest"),
                "pointer": load_match.group("pointer"),
            })
            continue

        div_match = div_re.search(line)
        if div_match:
            tainted.append({
                "kind": "div",
                "dest": div_match.group("dest"),
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
        r"\s*=\s*(?:fdiv|[su]?div)\b.*!dbg\s+!(\d+)"
    )

    for idx, line in enumerate(ir_lines):
        m = div_re.search(line)
        if m:
            return idx, int(m.group(1))

    error(f"Could not find matching IR division for dest {dest}")
    return None, None

def find_dilocation_line(ir_lines, dbg_id):
    diloc_re = re.compile(r"!" + str(dbg_id) + r"\s*=\s*!DILocation\(line:\s*(\d+)")
    for line in ir_lines:
        m = diloc_re.search(line)
        if m:
            return int(m.group(1))
    error(f"Could not find DILocation entry for !{dbg_id}")
    return None

def annotate_c_file(c_lines, tainted_line_types):
    output = []
    for i, line in enumerate(c_lines, start=1):
        if i in tainted_line_types:
            labels = [COMMENT_LABELS[kind] for kind in COMMENT_LABELS if kind in tainted_line_types[i]]
            output.append(line + "    // " + " & ".join(labels))
        else:
            output.append(line)
    return output

def main():
    if len(sys.argv) != 5:
        error("Usage: python annotate_taint.py [taintres] [llvm IR] [c file] [out file]")
        sys.exit(1)

    taint_path = sys.argv[1]
    ir_path = sys.argv[2]
    c_path = sys.argv[3]
    out_file = sys.argv[4]

    taint_lines = load_file(taint_path)
    ir_lines = load_file(ir_path)
    c_lines = load_file(c_path)

    tainted_ops = extract_tainted_instructions(taint_lines)
    if not tainted_ops:
        error("No tainted patterns extracted.")
        sys.exit(1)

    tainted_c_lines = {}

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

        c_line = find_dilocation_line(ir_lines, dbg_num)
        if c_line is None:
            error(f"Could not map dbg !{dbg_num} to C source line; skipping.")
            continue

        print(f"[INFO] Corresponds to C source line {c_line}")
        tainted_c_lines.setdefault(c_line, set()).add(comment_kind)

    if not tainted_c_lines:
        error("No successful taint→source mappings. No marked file will be written.")
        sys.exit(1)

    annotated = annotate_c_file(c_lines, tainted_c_lines)

    # ---------------------------
    # WRITE OUTPUT FILE
    # ---------------------------
    try:
        with open(out_file, "w") as f:
            for line in annotated:
                f.write(line + "\n")
    except Exception as e:
        error(f"Could not write output file '{out_file}': {e}")
        sys.exit(1)

    print(f"[INFO] Annotated C file written to: {out_file}")

if __name__ == "__main__":
    main()

