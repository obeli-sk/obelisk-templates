#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="http-simple/activity"
CRATE_NAME="myhttp_activity"
TEST='obelisk client execution submit --follow template-http:activity/http-get.get ["https://api.ipify.org"]'
run_test
