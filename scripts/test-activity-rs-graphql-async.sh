#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEST_OWNER="${TEST_OWNER:?TEST_OWNER is not set}"
TEST_REPO="${TEST_REPO:?TEST_REPO is not set}"

TEMPLATE="activity-rs/graphql-async"
CRATE_NAME="mygithub_activity"
TEST='obelisk execution submit --follow template-graphql-github:activity/graphql-github.releases ["obeli-sk","obelisk"]'
run_test

cargo test -- --ignored --nocapture
