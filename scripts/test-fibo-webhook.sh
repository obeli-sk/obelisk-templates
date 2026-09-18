#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="fibo/webhook_endpoint"
CRATE_NAME="webhook_myfibo"
WITH_FIBO_ACTIVITY=1
WITH_FIBO_WORKFLOW=1
TEST="curl -v --fail localhost:9090/fibo/2/1"
run_test
