#!/usr/bin/env bash

set -exuo pipefail
cd "$(dirname "$0")/.."

generate() {
  local path="$1"
  local component_type="$2"

  if [ ! -d "$path" ]; then
    return 0
  fi
  find "$path" -maxdepth 1 -type d -exec test -d "{}/wit" \; -print | while read -r dir; do
    echo "Updating $dir"
    (
      cd "$dir/wit"
      rm -rf gen
      obelisk generate extensions "$component_type" . gen
    )
  done
}

generate "activity-rs" "activity_wasm"
generate "fibo/activity" "activity_wasm"
generate "fibo/workflow" "workflow"
generate "fibo/webhook" "webhook_endpoint"
