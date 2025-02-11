#!/usr/bin/env bash

set -exuo pipefail

source "$(dirname "$0")/test-harness.sh"

TEMPLATE="graphql-github/activity"
CRATE_NAME="mygithub_activity"
TEST='obelisk client execution submit --follow template-graphql-github:activity/graphql-github.releases ["obeli-sk","obelisk"]'
run_test
