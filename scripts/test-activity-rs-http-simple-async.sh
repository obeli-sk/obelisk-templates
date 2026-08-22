#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="activity-rs/http-simple-async"
CRATE_NAME="myhttp_activity"
TEST='just test_url=http://localhost:8080 submit'
run_test

# Mock the JSON endpoint so the test does not depend on the live api.ipify.org.
# TEST_URL stays on the local Obelisk webui started by run_test.
MOCK_PORT=18092
python3 "$(dirname "$0")/mock-http-server.py" "$MOCK_PORT" &
MOCK_PID=$!
TEST_URL="http://localhost:8080" TEST_JSON_URL="http://127.0.0.1:${MOCK_PORT}/" cargo test -- --ignored --nocapture
