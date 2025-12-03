# CT-Prover

CT-Prover implements the verification pipelines from "Towards Efficient Verification of Constant-Time Cryptographic Implementations." The repository combines a customized SMACK frontend, PhASAR-based taint analysis, BAM product-program construction, and SVF pointer analysis to reason about constant-time properties of the benchmarks under `bech/`.

## Prerequisites
- Linux with build essentials and Python 3. The original paper does this on Ubuntu 20 and that is what most of our testing takes place on, but it is likely that more recent versions of Ubuntu/Linux would work just fine.
- Clang 12, Ninja ≥ 1.10.0, Boogie ≥ 2.9.6.0, Ruby ≥ 2.7.0. Installing these using "sudo apt install".
- It may also be necessary to install SMACK >=2.8.0, but there is also a local copy included here.

### Environment variable
Set `CTPROVER_ROOT` to the absolute path of this repository. The build scripts, CMake configurations, and analysis runners expect it to be present.
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
1. **Install base dependencies.** Ensure Clang 12, Ruby, Boogie, Ninja, and Python 3 are installed and available in your PATH.
2. **Build PhASAR**
   ```bash
   cd phasar
   sudo ./bootstrap.sh
   ```
3. **Build SMACK.** From `smack/bin`, run the provided build helper:
   ```bash
   cd smack
   sudo ./build.sh
   ```
   Make sure the resulting `smack` binary is on your `PATH` (either add the build output directory or install it using apt). If build-from-source fails on your platform, installing SMACK ≥ 2.8 from apt might work fine, although more investigation needs to be done to verify this.
4. **Build and install SVF.** There is a usable mirror of this provided in the repo. 
   ```bash
   cd Extern_PTA
   ./build.sh
   ./setup.sh
   ```
5. **Build the BAM Ruby gems.**
   ```bash
   cd bam
   ./build_all_gems.sh
   ```

After the above, ensure `CTPROVER_ROOT` and the SMACK, PhASAR, and SVF binaries are discoverable on `PATH` (or referenced via their full paths in config files).

## Running the verification pipelines
The runners expect to be launched from a benchmark directory (for example, `bech/demo/bad_function`). It will be necessary to run the ./compile.sh script present there before running these scripts.

- **Full pipeline:** `script/vfct_all.py` orchestrates all phases. Run it from the benchmark directory:
  ```bash
  python3 vfct_all.py      # assumes ../config.json or an argument pointing to config.json
  ```
- **Only phases 1–2–3:** `script/vfct_123.py` limits execution to the combined one+two+three workflow and writes phase timing CSVs:
  ```bash
  python3 vfct_123.py
  ```
- **Only phase 1:** `script/vfct_only1.py` runs just the add-key plus taint-analysis stage and emits the corresponding timing CSVs and summary:
  ```bash
  python3 vfct_only1.py
  ```

Note that the commands above assume the script directory is on your PATH, which it is recommended that you add it there fore ase of use with this tool.

The scripts create subdirectories (for example, `one_and_two_and_three/` or `single_one/`) with intermediate artifacts, timing data, and result logs.

## Post-processing helpers
- **`script/summarize_results.py`** parses the generated taint and transfer outputs plus timing CSVs to produce a concise `summary.txt` that lists tainted operation counts, surviving sensitive locations across phases, and per-phase timings. Invoke it from within a result directory (or let `vfct_only1.py` call it automatically):
  ```bash
  python3 summarize_results.py
  ```
- **`script/annotate.py`** maps tainted LLVM instructions back to C source locations using debug metadata and writes annotated copies of the source with inline comments such as `// TAINTED BRANCH` or `// TAINTED DATA ACCESS`.
  ```bash
  python3 annotate.py <path/to/taintres.txt> <path/to/module.ll> [output_dir]
  ```
  The optional `output_dir` controls where the annotated copies are written (defaults to the original source directory).

  Both the above scripts should be automatically called by the previously outlined pipelines and helper scripts, so manually calling of them should not usually be necessary.

## Running the benchmark suites

Run scripts from the /bech directory, ```python3 vfct_1_all.py``` and ```python3 vfct_123_all.py``` to run these tests on ALL the benchmark suites at once. 


