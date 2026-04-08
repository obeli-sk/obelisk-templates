#!/usr/bin/env bash

# Builds and pushes the fibo activity and workflow WASM components to the OCI
# registry, then updates all deployment TOML files that reference them.
#
# Usage: ./scripts/push-components.sh <TAG>
# Example: ./scripts/push-components.sh "$(date +%Y-%m-%d)"

set -exuo pipefail
cd "$(dirname "$0")/.."

TAG="$1"
PREFIX="oci://docker.io/getobelisk/"
TMP_DIR=$(mktemp -d -t push-components-XXXXXX)
trap "rm -rf $TMP_DIR" EXIT

build_and_push() {
    local TEMPLATE="$1"
    local CRATE_NAME="$2"
    local OCI_NAME="$3"

    # Redirect to stderr so stdout only contains the OCI URL from `obelisk component push` below,
    # allowing the caller to capture it cleanly via $().
    cargo-generate generate --path "$(pwd)" "$TEMPLATE" --name "$CRATE_NAME" \
        --destination "$TMP_DIR" --overwrite >&2
    (
        cd "$TMP_DIR/$CRATE_NAME"
        cargo build --release >&2  # same reason as above
        obelisk component push --deployment obelisk.toml "$CRATE_NAME" "${PREFIX}${OCI_NAME}:${TAG}"
    )
}

update_toml() {
    local NEW_LOCATION="$1"
    local COMPONENT_NAME="$2"
    shift 2
    local TOML_FILES=("$@")

    for TOML_FILE in "${TOML_FILES[@]}"; do
        obelisk component add --deployment "$TOML_FILE" "$NEW_LOCATION" "$COMPONENT_NAME"
    done
}

# Activity
ACTIVITY_LOCATION=$(build_and_push \
    fibo/activity \
    activity_myfibo \
    example_activity_fibo_template)

update_toml "$ACTIVITY_LOCATION" activity_myfibo \
    fibo/workflow/obelisk.toml \
    fibo/webhook_endpoint/obelisk.toml \
    fibo/workflow/obelisk-deps.toml \
    fibo/webhook_endpoint/obelisk-deps.toml

# Workflow
WORKFLOW_LOCATION=$(build_and_push \
    fibo/workflow \
    workflow_myfibo \
    example_workflow_fibo_template)

update_toml "$WORKFLOW_LOCATION" workflow_myfibo \
    fibo/webhook_endpoint/obelisk.toml \
    fibo/webhook_endpoint/obelisk-deps.toml

echo "Done."
