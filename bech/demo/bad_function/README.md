# bad_function demo

This directory contains a self-contained example that mirrors the snippet from the prompt.

* `bad.c` holds the wrapper and implementation. The wrapper marks `a` as secret by calling
  `vfct_taintseed` and marks `b` as public through the CT-Verif helpers.
* `bad.json` configures the PhASAR taint analysis to treat the first parameter of
  `bad_wrapper` as the unique taint source.
* `compile.sh` builds the LLVM bitcode/IR used by CT-Prover. Run it before invoking any of the
  `vfct` helper scripts.

To experiment with the benchmark:

```bash
cd bech/demo/bad_function
./compile.sh
../../../script/vfct
```

The run inherits the timing and loop settings from `bech/demo/config.json`.
