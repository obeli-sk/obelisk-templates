#!/usr/bin/env bash

# Copies `flake.lock` and `rust-toolchain.toml` from latest obelisk to this repository and all of its templates.

set -exuo pipefail
cd "$(dirname "$0")/.."

curl https://raw.githubusercontent.com/obeli-sk/obelisk/refs/heads/latest/flake.lock -o flake.lock
curl https://raw.githubusercontent.com/obeli-sk/obelisk/refs/heads/latest/rust-toolchain.toml -o rust-toolchain.toml

declare -a target_dirs=(
  "./graphql-github/activity/"
  "./http-simple/activity/"
  "./fibo/activity/"
  "./fibo/workflow/"
  "./fibo/webhook_endpoint/"
)
for dir in "${target_dirs[@]}"; do
  echo "Copying files to: $dir"
  cp flake.lock "$dir"
  cp rust-toolchain.toml "$dir"
done
