#!/usr/bin/env bash

# Collect versions of binaries installed by `nix develop` producing file `dev-deps.txt`.
# This script should be executed after every `nix flake update`.

set -exuo pipefail
cd "$(dirname "$0")/.."

rm -f dev-deps.txt
# cargo-edit
cargo-upgrade upgrade --version >> dev-deps.txt
cargo-generate --version >> dev-deps.txt
obelisk --version >> dev-deps.txt
echo "pkg-config $(pkg-config --version)" >> dev-deps.txt
rustc --version >> dev-deps.txt
wasm-tools --version >> dev-deps.txt
wasmtime --version >> dev-deps.txt
