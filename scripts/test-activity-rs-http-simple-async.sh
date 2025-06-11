#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="activity-rs/http-simple-async"
CRATE_NAME="myhttp_activity"
TEST='just test_url=http://localhost:8080 submit'
run_test

TEST_URL="http://localhost:8080" cargo test -- --ignored --nocapture
