#!/usr/bin/env bash

cleanup() {
    rm -rf $tmp_dir; echo 'Temporary directory removed'
    echo "Sending SIGINT to process $PID..."
    kill -SIGINT $PID

    # Wait up to 5 seconds for the process to exit
    SECONDS=0
    while kill -SIGINT $PID 2>/dev/null; do
        if [[ $SECONDS -ge 5 ]]; then
            echo "Cleanup timeout reached. Sending SIGKILL to process $PID..."
            kill -SIGKILL $PID
            break
        fi
        sleep 1
    done
}

wait_for_obelisk() {
    SECONDS=0
    while ! obelisk client component list 2>/dev/null; do
        if [[ $SECONDS -ge 10 ]]; then
            echo "Timeout reached"
            exit 1
        fi
        sleep 1
    done
}

run_test() {
    # Set up the test: generate a cargo project from $TEMPLATE in /tmp
    GIT_ROOT="$(realpath "$(dirname "$0")/..")"
    # Create a temporary directory
    tmp_dir=$(mktemp -d -t obelisk-templates-test-XXXXXX)
    # Trap to clean up the temporary directory on early exit
    trap "rm -rf $tmp_dir; echo 'Temporary directory removed'" EXIT
    echo "Temporary directory created: $tmp_dir"
    cd $tmp_dir

    cargo-generate generate --path $GIT_ROOT $TEMPLATE --name $CRATE_NAME
    cd $CRATE_NAME
    cargo build --release
    obelisk server verify

    obelisk server run &
    PID=$!

    trap cleanup EXIT

    wait_for_obelisk

    # actual test
    $TEST

    echo "Test succeeded."
}
