#!/usr/bin/env bash

set -exuo pipefail
cd "$(dirname "$0")/.."

(
cd fibo/workflow
rm -rf wit/deps/obelisk_*
obelisk generate wit-deps --overwrite -c obelisk-deps.toml wit/deps
)

(
cd fibo/webhook_endpoint
rm -rf wit/deps/obelisk_*
obelisk generate wit-deps --overwrite -c obelisk-deps.toml wit/deps
)
