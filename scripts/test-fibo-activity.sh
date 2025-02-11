#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="fibo/activity"
CRATE_NAME="activity_myfibo"
TEST='obelisk client execution submit --follow template-fibo:activity/fibo-activity-ifc.fibo [10]'
run_test
