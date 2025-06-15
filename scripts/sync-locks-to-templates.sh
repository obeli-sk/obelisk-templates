#!/usr/bin/env bash

# Copies `flake.lock` and `rust-toolchain.toml` from the root of this repository to all of its templates.

set -exuo pipefail
cd "$(dirname "$0")/.."

declare -a target_dirs=(
  "./activity-rs/graphql-sync/"
  "./activity-rs/http-simple-sync/"
  "./activity-rs/http-simple-async/"
  "./fibo/activity/"
  "./fibo/workflow/"
  "./fibo/webhook_endpoint/"
)
for dir in "${target_dirs[@]}"; do
  echo "Copying files to: $dir"
  cp flake.lock "$dir"
  cp rust-toolchain.toml "$dir"
done
