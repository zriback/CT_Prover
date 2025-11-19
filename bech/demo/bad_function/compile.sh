#!/bin/bash
set -euo pipefail

SRC="bad.c"
BC="${SRC%.c}.bc"
LL="${SRC%.c}.ll"

rm -f "$BC" "$LL"

clang-12 -c -emit-llvm -O0 -g -gcolumn-info -Xclang -disable-O0-optnone \
  -DMEMORY_MODULE_NO_REUSE_IMPLS -fcolor-diagnostics \
  -I/home/user/CT_Prover/smack/share/smack/include "$SRC" -o "$BC"

llvm-dis-12 "$BC" -o "$LL"
rm -f "$BC"
