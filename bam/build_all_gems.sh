#!/usr/bin/env bash
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
install_args=()

while (($#)); do
  case "$1" in
    --install-dir)
      if [[ $# -lt 2 ]]; then
        echo "Error: --install-dir requires a directory argument" >&2
        exit 1
      fi
      install_dir="$2"
      install_args=("--install-dir" "$install_dir" --bindir "$install_dir/bin")
      shift 2
      ;;
    --no-install)
      install_args=("--ignore-dependencies")
      shift
      ;;
    --help|-h)
      cat <<'USAGE'
Usage: build_all_gems.sh [--install-dir DIR] [--no-install]

Builds each bam-bam-boogieman gem under the bam/ directory. By default the
resulting gems are installed via `gem install --local`.

Options:
  --install-dir DIR  Install gems into DIR instead of the default gem home.
  --no-install       Build gem packages but skip installation.
  -h, --help         Show this help message.
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

shopt -s nullglob
bam_dirs=("${root_dir}"/bam-*/)
if [[ ${#bam_dirs[@]} -eq 0 ]]; then
  echo "No bam-* directories found under ${root_dir}" >&2
  exit 1
fi

for dir in "${bam_dirs[@]}"; do
  if [[ ! -d "$dir" ]]; then
    continue
  fi
  echo "==> Processing ${dir%/}" 
  pushd "$dir" >/dev/null
  gemspecs=(*.gemspec)
  if [[ ${#gemspecs[@]} -ne 1 ]]; then
    echo "Skipping ${dir%/}: expected exactly one gemspec, found ${#gemspecs[@]}" >&2
    popd >/dev/null
    continue
  fi
  gemspec="${gemspecs[0]}"
  echo "Building $gemspec"
  gem build "$gemspec"
  if [[ ${#install_args[@]} -eq 0 ]] || [[ ${install_args[0]} != "--ignore-dependencies" ]]; then
    built_gem=$(ls -t *.gem 2>/dev/null | head -n1)
    if [[ -z "$built_gem" ]]; then
      echo "Error: gem build did not create a .gem file in ${dir%/}" >&2
      popd >/dev/null
      exit 1
    fi
    echo "Installing $built_gem"
    gem install --local "$built_gem" "${install_args[@]}"
  else
    echo "Skipping installation as requested"
  fi
  popd >/dev/null
  echo
  if command -v bam >/dev/null 2>&1; then
    echo "bam --version:" $(bam --version 2>/dev/null || echo "(failed to run)")
  fi
  echo
  echo "Completed ${dir%/}"
  echo "------------------------------"
done

shopt -u nullglob

echo "All BAM gems processed."
