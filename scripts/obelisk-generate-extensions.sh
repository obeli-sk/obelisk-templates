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
      obelisk generate extensions "$component_type" . gen
    )
  done
}

generate "activity-rs" "activity_wasm"
generate "fibo/activity" "activity_wasm"

rm -rf fibo/workflow/wit/deps/template-fibo_activity-obelisk-ext
cp -r fibo/activity/wit/gen/template-fibo_activity-obelisk-ext fibo/workflow/wit/deps/
generate "fibo/workflow" "workflow"

rm -rf fibo/webhook_endpoint/wit/deps/template-fibo_workflow-obelisk-schedule
cp -r fibo/workflow/wit/gen/template-fibo_workflow-obelisk-schedule fibo/webhook_endpoint/wit/deps/
generate "fibo/webhook" "webhook_endpoint"
