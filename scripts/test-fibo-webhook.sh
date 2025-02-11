#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="fibo/webhook_endpoint"
CRATE_NAME="webhook_myfibo"
TEST="curl localhost:9000/fibo/2/1"
run_test
