# CT-Prover

CT-Prover implements the verification pipelines from "Towards Efficient Verification of Constant-Time Cryptographic Implementations." The repository combines a customized SMACK frontend, PhASAR-based taint analysis, BAM product-program construction, and SVF pointer analysis to reason about constant-time properties of the benchmarks under `bech/`.

## Prerequisites
- Linux with build essentials, `sudo`, and Python 3.
- Clang 12, Ninja ≥ 1.10.0, Boogie ≥ 2.9.6.0, Ruby ≥ 2.7.0 (for the BAM gems). Installing these with your package manager is fine; the Clang/Boogie/Ninja versions listed here match the original setup.
- Optional: SMACK ≥ 2.8 is available via many package managers if you prefer a prebuilt binary.

### Environment variable
Set `CTPROVER_ROOT` to the absolute path of this repository. The build scripts, CMake configurations, and analysis runners expect it to be present, and several helper scripts guard against it being unset:
```bash
export CTPROVER_ROOT="$(pwd)"   # run from the repository root
```

## Repository layout
- `phasar/`: IFDS taint analysis extensions used by the verifier.
- `Extern_PTA/`: SVF pointer-analysis fork plus helper scripts.
- `smack/`: Customized SMACK frontend that emits Boogie with taint metadata.
- `bam/`: Product-program construction and supporting Ruby gems.
- `bech/`: Benchmarks organized by library/algorithm.
- `script/`: Automation scripts for building LLVM IR, running the verification pipelines, and post-processing results.

## Installation and toolchain build
1. **Install base dependencies.** Ensure Clang 12, Ruby, Boogie, Ninja, and Python 3 are installed and available on `PATH`.
2. **Build PhASAR with the repository patches.**
   ```bash
   cd phasar
   sudo ./bootstrap.sh
   ```
3. **Build SMACK.** From `smack/bin`, run the provided build helper:
   ```bash
   cd smack/bin
   sudo ./build.sh
   ```
   Make sure the resulting `smack` binary is on your `PATH` (either add the build output directory or install it system-wide). If build-from-source fails on your platform, installing SMACK ≥ 2.8 from your package manager is an alternative.
4. **Build and install SVF.**
   ```bash
   cd Extern_PTA
   ./build.sh
   ./setup.sh
   ```
5. **Build the BAM Ruby gems.**
   ```bash
   cd bam
   ./build_all_gems.sh           # add --install-dir <dir> to install locally
   ```

After the above, ensure `CTPROVER_ROOT` and the SMACK, PhASAR, and SVF binaries are discoverable on `PATH` (or referenced via their full paths in config files).

## Running the verification pipelines
The runners expect to be launched from a benchmark directory (for example, `bech/demo/kyberslash`). Each benchmark directory contains a `config.json` and the LLVM/Boogie artifacts the scripts expect.

- **Full pipeline:** `script/vfct_all.py` orchestrates all phases (add-key transformation, taint analysis, Boolean and shadow product generation, verification, and timing). Run it from the benchmark directory:
  ```bash
  python3 ../../script/vfct_all.py      # assumes ../config.json or an argument pointing to config.json
  ```
- **Only phases 1–2–3:** `script/vfct_123.py` limits execution to the combined one+two+three workflow and writes phase timing CSVs:
  ```bash
  python3 ../../script/vfct_123.py
  ```
- **Only phase 1:** `script/vfct_only1.py` runs just the add-key plus taint-analysis stage and emits the corresponding timing CSVs and summary:
  ```bash
  python3 ../../script/vfct_only1.py
  ```

The runners create subdirectories (e.g., `one_and_two_and_three/` or `single_one/`) with intermediate artifacts, timing CSVs (`detailtime.csv`, `totaltime.csv`), and result logs.

## Post-processing helpers
- **`script/summarize_results.py`** parses the generated taint and transfer outputs plus timing CSVs to produce a concise `summary.txt` that lists tainted operation counts, surviving sensitive locations across phases, and per-phase timings. Invoke it from within a result directory (or let `vfct_only1.py` call it automatically):
  ```bash
  python3 ../../script/summarize_results.py
  ```
- **`script/annotate.py`** maps tainted LLVM instructions back to C source locations using debug metadata and writes annotated copies of the source with inline comments such as `// TAINTED BRANCH` or `// TAINTED DATA ACCESS`.
  ```bash
  python3 ../../script/annotate.py <path/to/taintres.txt> <path/to/module.ll> [output_dir]
  ```
  The optional `output_dir` controls where the annotated copies are written (defaults to the original source directory).

## Running the benchmark suites
Benchmark directories under `bech/` provide `compile.sh` helpers that rely on `CTPROVER_ROOT` to locate SMACK headers. After compiling a benchmark to LLVM IR, use one of the runners above (`vfct_all.py`, `vfct_123.py`, or `vfct_only1.py`) to verify constant-time behavior. Generated CSVs and summaries capture pass/fail information and timings across the configured phases.
