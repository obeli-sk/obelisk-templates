#!/usr/bin/env bash

set -exuo pipefail
cd "$(dirname "$0")/.."

# deployment.toml files contain cargo-generate placeholders (e.g. {{crate_name}})
# which obelisk cannot parse. Substitute them with a valid dummy value first.
resolve_deployment() {
    local src="$1"
    local tmp
    tmp=$(mktemp)
    sed 's/{{crate_name}}/placeholder/g' "$src" > "$tmp"
    echo "$tmp"
}

(
cd fibo/workflow
obelisk generate wit-support workflow wit/deps --force
tmp=$(resolve_deployment deployment.toml)
trap "rm -f $tmp" EXIT
obelisk generate wit-deps --force --skip-local --deployment "$tmp" wit/deps --prune
)

(
cd fibo/webhook_endpoint
obelisk generate wit-support webhook_endpoint wit/deps --force
tmp=$(resolve_deployment deployment.toml)
trap "rm -f $tmp" EXIT
obelisk generate wit-deps --force --skip-local --deployment "$tmp" wit/deps --prune
)
