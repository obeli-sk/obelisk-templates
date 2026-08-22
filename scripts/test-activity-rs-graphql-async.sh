#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

export TEST_OWNER="${TEST_OWNER:-obeli-sk}"
export TEST_REPO="${TEST_REPO:-obelisk}"
export GITHUB_TOKEN="${GITHUB_TOKEN:-mock-github-token}"

# Mock the GitHub GraphQL API so the test does not depend on the live,
# rate-limited api.github.com. Both the obelisk deployment (via
# GITHUB_GRAPHQL_ORIGIN in deployment.toml/server.toml) and the wasmtime
# integration test (via GITHUB_GRAPHQL_URL) point at it.
MOCK_PORT=18091
python3 "$(dirname "$0")/mock-http-server.py" "$MOCK_PORT" &
MOCK_PID=$!
export GITHUB_GRAPHQL_ORIGIN="http://127.0.0.1:${MOCK_PORT}"
export GITHUB_GRAPHQL_URL="http://127.0.0.1:${MOCK_PORT}/graphql"

TEMPLATE="activity-rs/graphql-async"
CRATE_NAME="mygithub_activity"
TEST='obelisk execution submit --follow template-graphql-github:activity/graphql-github.releases ["obeli-sk","obelisk"]'
run_test

cargo test -- --ignored --nocapture
