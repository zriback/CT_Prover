#!/usr/bin/env python3
"""Run the 1+2+3 pipeline across all benchmark subdirectories.

Designed to be executed from ``CT_Prover/bech``. The script walks every
library directory and each of its subdirectories, removes any existing
``one_and_two_and_three`` folder, reruns ``vfct_123.py`` to regenerate it,
then enters the newly created folder to summarize the results.
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path


def run_command(cmd: list[str], cwd: Path) -> None:
    """Run ``cmd`` inside ``cwd`` and raise if it fails."""

    subprocess.run(cmd, cwd=cwd, check=True)


def regenerate_pipeline(workdir: Path, vfct_script: Path, summarize_script: Path) -> None:
    """Rebuild the ``one_and_two_and_three`` pipeline in ``workdir``."""

    compile_sh = workdir / "compile.sh"
    if not compile_sh.exists():
        print(f"[skip] {workdir} (missing compile.sh)")
        return

    cleanup_targets = [
        workdir / "one_and_two_and_three",
        workdir / "one_and_two_and_three-s",
        workdir / "two_and_three",
        workdir / "totaltime2.csv",
    ]

    for cleanup_target in cleanup_targets:
        if cleanup_target.exists():
            if cleanup_target.is_dir():
                shutil.rmtree(cleanup_target)
            else:
                cleanup_target.unlink()

    for marked_file in workdir.rglob("*-marked.c"):
        try:
            marked_file.unlink()
        except FileNotFoundError:
            # File might disappear between discovery and deletion; ignore.
            pass

    target_dir = workdir / "one_and_two_and_three"
    print(f"[run] {workdir}: vfct_123.py")
    try:
        run_command([sys.executable, str(vfct_script)], cwd=workdir)
    except subprocess.CalledProcessError as exc:
        print(f"[skip-error] {workdir}: vfct_123.py failed ({exc})")
        return

    if not target_dir.exists():
        raise RuntimeError(f"{target_dir} was not created by vfct_123.py")

    print(f"[run] {target_dir}: summarize_results.py")
    run_command([sys.executable, str(summarize_script)], cwd=target_dir)


def main() -> None:
    here = Path.cwd()
    if here.name != "bech":
        raise SystemExit("This script must be run from CT_Prover/bech")

    repo_root = Path(__file__).resolve().parent.parent
    vfct_script = repo_root / "script" / "vfct_123.py"
    summarize_script = repo_root / "script" / "summarize_results.py"

    if not vfct_script.exists() or not summarize_script.exists():
        raise SystemExit("Could not locate vfct_123.py or summarize_results.py")

    for lib_dir in sorted(p for p in here.iterdir() if p.is_dir()):
        for sub_dir in sorted(p for p in lib_dir.iterdir() if p.is_dir()):
            regenerate_pipeline(sub_dir, vfct_script, summarize_script)


if __name__ == "__main__":
    main()
