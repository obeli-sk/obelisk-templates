#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="fibo/workflow"
CRATE_NAME="workflow_myfibo"
TEST='obelisk execution submit --follow template-fibo:workflow/fibo-workflow-ifc.fiboa [2,1]'
run_test
