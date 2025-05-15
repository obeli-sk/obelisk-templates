#!/usr/bin/env bash

# List of project directories

set -exuo pipefail
cd "$(dirname "$0")/.."

projects=(
  "fibo/activity"
  "fibo/webhook_endpoint"
  "fibo/workflow"
  "graphql-github/activity"
  "http-simple/activity"
)

for dir in "${projects[@]}"; do
  echo "Processing $dir"

  toml="$dir/Cargo.toml"

  # Replace template name with placeholder
  sed -i 's/name = "{{project-name}}"/name = "x"/' "$toml"

  (
    cd "$dir" 
    cargo upgrade --incompatible
    cargo update
)

  # Restore original template name
  sed -i 's/name = "x"/name = "{{project-name}}"/' "$toml"
done
