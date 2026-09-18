#!/usr/bin/env bash

cleanup() {
    [[ -n "${MOCK_PID:-}" ]] && kill "$MOCK_PID" 2>/dev/null || true
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
    while ! obelisk component list 2>/dev/null; do
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

    if [[ ${WITH_FIBO_ACTIVITY:-0} == 1 ]]; then
        cargo-generate generate --path "$GIT_ROOT/fibo/activity" --name activity_myfibo
        (cd activity_myfibo && env -u CARGO_TARGET_DIR cargo build --release)
    fi
    if [[ ${WITH_FIBO_WORKFLOW:-0} == 1 ]]; then
        cargo-generate generate --path "$GIT_ROOT/fibo/workflow" --name workflow_myfibo
        (cd workflow_myfibo && env -u CARGO_TARGET_DIR cargo build --release)
    fi

    cargo-generate generate --path "$GIT_ROOT/$TEMPLATE" --name "$CRATE_NAME"
    cd $CRATE_NAME
    if [[ ${WITH_FIBO_ACTIVITY:-0} == 1 ]]; then
        mkdir -p components
        cp ../activity_myfibo/target/wasm32-wasip2/release/activity_myfibo.wasm components/
    fi
    if [[ ${WITH_FIBO_WORKFLOW:-0} == 1 ]]; then
        mkdir -p components
        cp ../workflow_myfibo/target/wasm32-unknown-unknown/release/workflow_myfibo.wasm components/
    fi
    env -u CARGO_TARGET_DIR cargo build --release
    server_args=()
    if [[ -f server.toml ]]; then
        server_args+=(--server-config server.toml)
    fi
    obelisk deployment verify "${server_args[@]}" --deployment deployment.toml

    obelisk server run "${server_args[@]}" --deployment deployment.toml &
    PID=$!

    trap cleanup EXIT

    wait_for_obelisk

    # actual test
    $TEST

    echo "Test succeeded."
}
