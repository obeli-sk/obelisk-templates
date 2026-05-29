#!/usr/bin/env bash

# Copies root-level `flake.lock` and `rust-toolchain.toml` to every matching file
# found in subdirectories of this repository.

set -exuo pipefail
cd "$(dirname "$0")/.."

find . -mindepth 2 \( -name flake.lock -o -name rust-toolchain.toml \) -print0 |
  while IFS= read -r -d '' path; do
    echo "Syncing: $path"
    cp "./$(basename "$path")" "$path"
  done
