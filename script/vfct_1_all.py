#!/usr/bin/python3
"""Run the single_one pipeline across all benchmarks under bech.

This helper mirrors vfct_123_all by iterating over each benchmark
subdirectory and invoking vfct_only1.py inside it. Run this script from the
bech directory.

Optionally pass one or more benchmark directory names (relative to bech) to
restrict execution to just those benchmarks. For example::

    python3 vfct_1_all.py tongsuo

will only run ``vfct_only1.py`` within the ``tongsuo`` benchmark.
"""

import os
import subprocess
from argparse import ArgumentParser
from typing import Iterable, List

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RUNNER = os.path.join(SCRIPT_DIR, "vfct_only1.py")


def run_runner_in_dir(target_dir: str, extra_args: Iterable[str]) -> None:
    print(f"\n=== Running single_one for {target_dir} ===")
    cmd: List[str] = ["python3", RUNNER, *extra_args]
    subprocess.run(cmd, cwd=target_dir, check=True)


def has_config(directory: str) -> bool:
    return os.path.isfile(os.path.join(directory, "config.json"))


def has_compile_script(directory: str) -> bool:
    return os.path.isfile(os.path.join(directory, "compile.sh"))


def iter_compile_dirs(bench_dir: str) -> Iterable[str]:
    """Yield child directories that contain a compile.sh script."""

    for entry in sorted(os.listdir(bench_dir)):
        if entry.startswith('.'):
            continue

        candidate = os.path.join(bench_dir, entry)
        if os.path.isdir(candidate) and has_compile_script(candidate):
            yield candidate


def iter_benchmarks(base_dir: str, names: Iterable[str]) -> Iterable[str]:
    if names:
        for name in names:
            candidate = os.path.join(base_dir, name)
            if not os.path.exists(candidate):
                print(f"[skip] {name} does not exist; skipping")
                continue

            if os.path.isfile(os.path.join(candidate, "compile.sh")):
                yield candidate
                continue

            if os.path.isdir(candidate):
                # Treat explicit directories as benchmark roots and run any
                # compile-capable children beneath them.
                subtargets = list(iter_compile_dirs(candidate))
                if not subtargets:
                    print(f"[skip] {candidate} has no compile.sh; skipping")
                for target in subtargets:
                    yield target
            else:
                print(f"[skip] {name} is not a directory; skipping")
    else:
        for entry in sorted(os.listdir(base_dir)):
            if entry.startswith('.'):
                continue

            bench_dir = os.path.join(base_dir, entry)
            if not os.path.isdir(bench_dir):
                continue
            if not has_config(bench_dir):
                continue

            for target in iter_compile_dirs(bench_dir):
                yield target


def main() -> None:
    parser = ArgumentParser(description=__doc__)
    parser.add_argument(
        "benchmarks",
        nargs="*",
        help="specific benchmark directories under ./bech to run",
    )
    args = parser.parse_args()

    base_dir = os.getcwd()
    if os.path.basename(base_dir) != "bech":
        raise SystemExit("Run vfct_1_all.py from the bech directory")

    for target in iter_benchmarks(base_dir, args.benchmarks):
        run_runner_in_dir(target, [])


if __name__ == "__main__":
    main()
