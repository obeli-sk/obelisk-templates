#!/usr/bin/env bash

# Builds and pushes the fibo activity and workflow WASM components to the OCI
# registry, then updates all deployment TOML files that reference them.
#
# Usage: ./scripts/push-components.sh <TAG>
# Example: ./scripts/push-components.sh "$(date +%Y-%m-%d)"

set -exuo pipefail
cd "$(dirname "$0")/.."

TAG="$1"
PREFIX="docker.io/getobelisk"
TMP_DIR=$(mktemp -d -t push-components-XXXXXX)
trap "rm -rf $TMP_DIR" EXIT

build_and_push() {
    local TEMPLATE="$1"
    local CRATE_NAME="$2"
    local OCI_NAME="$3"
    local WASM_SUBPATH="$4"

    # Redirect to stderr so stdout only contains the OCI URL from `obelisk component push` below,
    # allowing the caller to capture it cleanly via $().
    cargo-generate generate --path "$(pwd)" "$TEMPLATE" --name "$CRATE_NAME" \
        --destination "$TMP_DIR" --overwrite >&2
    (
        cd "$TMP_DIR/$CRATE_NAME"
        cargo build --release >&2  # same reason as above
        obelisk component push "$WASM_SUBPATH" "$PREFIX/$OCI_NAME:$TAG"
    )
}

update_toml() {
    local TOML_COMPONENT_TYPE="$1"
    local NEW_LOCATION="$2"
    local COMPONENT_NAME="$3"
    shift 3
    local TOML_FILES=("$@")

    for TOML_FILE in "${TOML_FILES[@]}"; do
        obelisk component add "$TOML_COMPONENT_TYPE" "$NEW_LOCATION" \
            --name "$COMPONENT_NAME" --deployment "$TOML_FILE"
    done
}

# Activity
ACTIVITY_LOCATION=$(build_and_push \
    fibo/activity \
    activity_myfibo \
    example_activity_fibo_template \
    "target/wasm32-wasip2/release/activity_myfibo.wasm")

update_toml activity_wasm "$ACTIVITY_LOCATION" activity_myfibo \
    fibo/workflow/obelisk.toml \
    fibo/webhook_endpoint/obelisk.toml \
    fibo/workflow/obelisk-deps.toml \
    fibo/webhook_endpoint/obelisk-deps.toml

# Workflow
WORKFLOW_LOCATION=$(build_and_push \
    fibo/workflow \
    workflow_myfibo \
    example_workflow_fibo_template \
    "target/wasm32-unknown-unknown/release/workflow_myfibo.wasm")

update_toml workflow_wasm "$WORKFLOW_LOCATION" workflow_myfibo \
    fibo/webhook_endpoint/obelisk.toml \
    fibo/webhook_endpoint/obelisk-deps.toml

echo "Done."
