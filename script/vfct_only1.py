#!/usr/bin/python3
"""Run only the first pipeline phase (single_one).

This script mirrors the single_one workflow in vfct_all.py while isolating
just the add-key and taint-analysis steps. Run it from a benchmark directory
(e.g., bech/OpenSSL/...) to generate timing CSVs and a summary report for the
phase-one results.
"""

import os
import sys

import vfct_all as vfct

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SUMMARIZER = os.path.join(SCRIPT_DIR, "summarize_results.py")


def run_single_one_only():
    dirname = "single_one"
    vfct.mkdir(dirname)

    totals = []
    addkey_times = []
    taint_times = []

    vfct.loc.clear()
    vfct.allsens.clear()
    vfct.taint_res.clear()
    vfct.Is_taint_pass.clear()
    vfct.Is_high_taint_1_2_pass.clear()
    vfct.detailtime_1.clear()
    vfct.totaltime_1.clear()

    for item in vfct.entry:
        file = f"{item}.ll"
        tkfile = f"{item}-k.ll"
        taintentry = f"{item}_wrapper_t"
        taintconfig = f"{item}.json"
        outfile = f"{item}-taintres.txt"

        vfct.runcommand(f"cp {taintconfig} {dirname}")

        restime1 = vfct.addkey(file, tkfile, dirname)
        restime2 = vfct.phasar(tkfile, taintentry, taintconfig, outfile, dirname)

        addkey_times.append(restime1)
        taint_times.append(restime2)
        totals.append(restime1 + restime2)

        vfct.loc.append("")
        vfct.taint_res.append("")
        vfct.Is_taint_pass.append("")
        vfct.Is_high_taint_1_2_pass.append("")
        vfct.allsens.append("")

    vfct.detailtime_1 = [
        ("add-key", addkey_times),
        ("taint-analysis", taint_times),
        ("ept", []),
    ]
    vfct.totaltime_1 = [("1", totals)]


def resolve_config_path():
    """Find a usable config.json for vfct_all.readconfig().

    The original runner expects ../config.json relative to the benchmark
    directory. Users sometimes invoke this helper from the bech root (which
    lacks that file), so we look for reasonable fallbacks and surface a clear
    error when nothing is available.
    """

    if len(sys.argv) > 1:
        candidate = sys.argv[1]
        if os.path.exists(candidate):
            return candidate
        raise FileNotFoundError(f"Config path from argv does not exist: {candidate}")

    cwd = os.getcwd()
    candidates = [
        os.path.join(cwd, "config.json"),
        os.path.join(cwd, "../config.json"),
    ]

    if os.path.basename(cwd) == "bech":
        candidates.append(os.path.join(cwd, "demo", "config.json"))

    for candidate in candidates:
        if os.path.exists(candidate):
            return candidate

    raise FileNotFoundError(
        "Could not find config.json. Run this script from a benchmark directory "
        "with its own config.json or pass the path explicitly as the first argument."
    )


def runall():
    vfct.preprocess()

    config_path = resolve_config_path()
    sys.argv = [sys.argv[0], config_path]
    vfct.readconfig()
    vfct.iterdir(os.getcwd())
    vfct.buildbech()

    run_single_one_only()

    vfct.totaltime = list(vfct.totaltime_1)
    vfct.detailtime = list(vfct.detailtime_1)
    vfct.verifytime = []

    vfct.collectinfo()
    vfct.collcet_time(vfct.totaltime, "totaltime.csv")
    vfct.collcet_time(vfct.detailtime, "detailtime.csv")
    vfct.collcet_time(vfct.verifytime, "verifytime.csv")

    results_dir = os.path.join(os.getcwd(), "single_one")
    vfct.runcommand(f"python3 {SUMMARIZER}", workdir=results_dir)


if __name__ == "__main__":
    runall()
