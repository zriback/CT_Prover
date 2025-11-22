#!/usr/bin/env python3
import sys
import re
import os

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
    for line in taint_lines:
        m = br_re.search(line)
        if m:
            tainted.append((m.group(1), m.group(2), m.group(3)))
    if not tainted:
        error("No tainted branch instructions found in taintres file.")
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

def find_dilocation_line(ir_lines, dbg_id):
    diloc_re = re.compile(r"!" + str(dbg_id) + r"\s*=\s*!DILocation\(line:\s*(\d+)")
    for line in ir_lines:
        m = diloc_re.search(line)
        if m:
            return int(m.group(1))
    error(f"Could not find DILocation entry for !{dbg_id}")
    return None

def annotate_c_file(c_lines, tainted_lines):
    tainted_set = set(tainted_lines)
    output = []
    for i, line in enumerate(c_lines, start=1):
        if i in tainted_set:
            output.append(line + "    // TAINTED")
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
        error("No tainted branch patterns extracted.")
        sys.exit(1)

    tainted_c_lines = []

    for operands in tainted_ops:
        print(f"[INFO] Processing tainted branch: {operands}")

        ir_idx, dbg_num = find_branch_in_ir(ir_lines, operands)
        if ir_idx is None or dbg_num is None:
            error(f"Skipping this tainted branch (missing IR match or dbg).")
            continue

        print(f"[INFO] Found IR branch at line {ir_idx+1}, dbg !{dbg_num}")

        c_line = find_dilocation_line(ir_lines, dbg_num)
        if c_line is None:
            error(f"Could not map dbg !{dbg_num} to C source line; skipping.")
            continue

        print(f"[INFO] Corresponds to C source line {c_line}")
        tainted_c_lines.append(c_line)

    if not tainted_c_lines:
        error("No successful taint→source mappings. No marked file will be written.")
        sys.exit(1)

    tainted_c_lines = sorted(set(tainted_c_lines))

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

