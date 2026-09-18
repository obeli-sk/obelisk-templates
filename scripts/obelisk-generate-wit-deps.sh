#!/usr/bin/env bash

set -exuo pipefail
cd "$(dirname "$0")/.."

(
cd fibo/workflow
obelisk generate wit-support workflow wit/deps --force
obelisk generate wit-extensions activity ../activity/wit wit/deps
)

(
cd fibo/webhook_endpoint
obelisk generate wit-support webhook_endpoint wit/deps --force
obelisk generate wit-extensions activity ../activity/wit wit/deps
obelisk generate wit-extensions workflow ../workflow/wit wit/deps
)
