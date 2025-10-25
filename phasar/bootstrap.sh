#!/bin/bash
set -e

# -----------------------------
# PhASAR bootstrap (fixed)
# -----------------------------
# Default: build WITHOUT unit tests. Enable with -u / --unittest.
# Accepts:
#   -j|--jobs <N>                 number of build threads (default: nproc)
#   -u|--unittest                 turn ON unit tests
#   -DBOOST_DIR <path> or -DBOOST_DIR=<path>
#   -DBOOST_VERSION <x.y> or -DBOOST_VERSION=<x.y>
#
# Notes:
# - Installs LLVM 13 into /usr/local/llvm-13
# - Installs PhASAR into /usr/local/phasar
# - Uses Ninja generator
# -----------------------------

source ./utils/safeCommandsSet.sh

readonly PHASAR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
readonly PHASAR_INSTALL_DIR="/usr/local/phasar"
readonly LLVM_INSTALL_DIR="/usr/local/llvm-13"

NUM_THREADS=$(nproc)
LLVM_RELEASE=llvmorg-13.0.0
DO_UNIT_TEST=false  # default OFF

# ---- Parse args ----
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case "$key" in
    -j|--jobs)
      NUM_THREADS="$2"
      shift; shift
      ;;
    -u|--unittest)
      DO_UNIT_TEST=true
      shift
      ;;
    -DBOOST_DIR)
      DESIRED_BOOST_DIR="$2"
      shift; shift
      ;;
    -DBOOST_DIR=*)
      DESIRED_BOOST_DIR="${key#*=}"
      shift
      ;;
    -DBOOST_VERSION)
      DESIRED_BOOST_VERSION="$2"
      shift; shift
      ;;
    -DBOOST_VERSION=*)
      DESIRED_BOOST_VERSION="${key#*=}"
      shift
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"

echo "installing phasar dependencies..."
if command -v pacman >/dev/null 2>&1; then
  yes | sudo pacman -Syu --needed which zlib sqlite3 ncurses make python3 doxygen libxml2 swig gcc cmake z3 libedit graphviz python-sphinx openmp curl python-pip
  ./utils/installBuildEAR.sh
else
  ./utils/InstallAptDependencies.sh
fi
sudo pip3 install -q Pygments pyyaml

# ---- Boost setup ----
if [[ -n "${DESIRED_BOOST_DIR}" ]]; then
  BOOST_PARAMS="-DBOOST_ROOT=${DESIRED_BOOST_DIR}"
else
  BOOST_VERSION=$(echo -e '#include <boost/version.hpp>\nBOOST_LIB_VERSION' | gcc -s -x c++ -E - 2>/dev/null | grep "^[^#;]" | tr -d '"')
  if [[ -z "$BOOST_VERSION" ]]; then
    if command -v pacman >/dev/null 2>&1; then
      yes | sudo pacman -Syu --needed boost-libs boost
    else
      if [[ -z "$DESIRED_BOOST_VERSION" ]]; then
        sudo apt install -y libboost-all-dev
      else
        sudo apt install -y "libboost${DESIRED_BOOST_VERSION}-all-dev" || {
          echo "Failed installing boost ${DESIRED_BOOST_VERSION}"; exit 1; }
      fi
      BOOST_VERSION=$(echo -e '#include <boost/version.hpp>\nBOOST_LIB_VERSION' | gcc -s -x c++ -E - 2>/dev/null | grep "^[^#;]" | tr -d '"')
      if [[ -z "$BOOST_VERSION" ]]; then
        echo "Failed installing Boost"; exit 1
      else
        echo "Successfully installed boost v${BOOST_VERSION//_/.}"
      fi
    fi
  else
    echo "Already installed boost version ${BOOST_VERSION//_/.}"
    if command -v apt >/dev/null 2>&1; then
      DESIRED_BOOST_VERSION=${BOOST_VERSION//_/.}
      boostlibnames=("libboost-system" "libboost-filesystem" "libboost-graph" "libboost-program-options" "libboost-thread")
      additional_boost_libs=()
      for boost_lib in "${boostlibnames[@]}"; do
        dpkg -s "$boost_lib${DESIRED_BOOST_VERSION}" >/dev/null 2>&1 || \
        dpkg -s "$boost_lib${DESIRED_BOOST_VERSION}.0" >/dev/null 2>&1 || \
        additional_boost_libs+=("$boost_lib${DESIRED_BOOST_VERSION}")
        dpkg -s "${boost_lib}-dev" >/dev/null 2>&1 || additional_boost_libs+=("${boost_lib}-dev")
      done
      if [[ ${#additional_boost_libs[@]} -gt 0 ]]; then
        echo "Installing additional Boost packages: ${additional_boost_libs[*]}"
        sudo apt install -y "${additional_boost_libs[@]}"
      fi
    fi
  fi
fi

# ---- Install LLVM 13 ----
tmp_dir=$(mktemp -d "llvm-13_build.XXXXXXXX" --tmpdir)
./utils/install-llvm.sh "${NUM_THREADS}" "${tmp_dir}" "${LLVM_INSTALL_DIR}" "${LLVM_RELEASE}"
rm -rf "${tmp_dir}"
sudo pip3 install -q wllvm
echo "dependencies successfully installed"

# ---- Build PhASAR ----
echo "Building PhASAR..."
$DO_UNIT_TEST && echo "with unit tests." || echo "without unit tests."

git submodule init
git submodule update

export CC=${LLVM_INSTALL_DIR}/bin/clang
export CXX=${LLVM_INSTALL_DIR}/bin/clang++

mkdir -p "${PHASAR_DIR}/build"
safe_cd "${PHASAR_DIR}/build"

cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  ${BOOST_PARAMS} \
  -DPHASAR_BUILD_UNITTESTS=${DO_UNIT_TEST} \
  "${PHASAR_DIR}"

cmake --build . -j "${NUM_THREADS}"

if ${DO_UNIT_TEST}; then
  echo "Running PhASAR unit tests..."
  pushd unittests >/dev/null
  # Run all executables under unittests
  while IFS= read -r -d '' x; do
    d="${x%/*}"; f="${x##*/}"
    (cd "$d" && "./$f") || { echo "Test ${x} failed, aborting."; exit 1; }
  done < <(find . -type f -executable -print0)
  popd >/dev/null
fi

echo "phasar successfully built"
echo "install phasar..."
sudo cmake -DCMAKE_INSTALL_PREFIX="${PHASAR_INSTALL_DIR}" -P cmake_install.cmake
sudo ldconfig
safe_cd ..

echo "phasar successfully installed to ${PHASAR_INSTALL_DIR}"

echo "Set environment variables"
./utils/setEnvironmentVariables.sh "${LLVM_INSTALL_DIR}" "${PHASAR_INSTALL_DIR}"

