# Rust-Based Fibonacci Workflow Template for Obelisk

This template provides an implementation of a workflow that calls the Fibonacci activity
created using the [activity_fibo](../activity_fibo) template.
It serves as an example for building, running,
and interacting with workflows using the [obelisk](https://github.com/obeli-sk/obelisk) runtime.

The contract is defined in the [wit](./wit/) folder.

The workflow implementation resides in [src/lib.rs](./src/lib.rs) .

## Prerequisites
Ensure you have the following installed before using the template:

* **[Rust](https://rustup.rs/):** Install via `rustup` (see [rust-toolchain.toml](./rust-toolchain.toml) for the minimal supported version).
* **[cargo-generate](https://crates.io/crates/cargo-generate):** Install with `cargo install --locked cargo-generate`.
* **[obelisk](https://github.com/obeli-sk/obelisk):** Install with `cargo install --locked obelisk`.

If you're using **Nix**, you can obtain `cargo-generate` using `nix shell nixpkgs#cargo-generate`.

## Getting Started

### Generate the Template
Run the following command to create a new project based on this template:
```sh
cargo-generate generate obeli-sk/obelisk-templates workflow_fibo --name workflow_myfibo
```

### Build the Workflow
Navigate into the generated folder.
If you're using **Nix** and **direnv**, you can set up the environment using the provided [.envrc-example](./.envrc-example):
```sh
ln -s .envrc-example .envrc
git add .
direnv allow
```

Build the workflow in release mode:
```sh
cargo build --release
```

Unlike when building an activity, an additional step is required to transform the 
Core WASM file into a WASM Component:
```sh
wasm-tools component new target/wasm32-unknown-unknown/release/workflow_myfibo.wasm \
 -o target/wasm32-unknown-unknown/release/workflow_myfibo_component.wasm
```
This is needed because activities are built with `wasm32-wasip2` target, whereas
workflows are built with `wasm32-unknown-unknown` target.

### Run the Server
Start the server using the provided [obelisk.toml](./obelisk.toml) configuration:
```sh
obelisk server run
```
Note: If running in a folder that does not contain `obelisk.toml` you must specify the path:
`obelisk server run --config <path to obelisk.toml>`.

### Test the Workflow
Access the workflow via the web interface at [127.0.0.1:8080](http://127.0.0.1:8080),
or use the CLI as described in the next sections.

### List Available Functions
To see the available exported functions, run:
```sh
obelisk client component list
```
Example output:
```
workflow_myfibo workflow:workflow_myfibo:47f4f4c0f9ff2e68
Exports:
        template-fibo:workflow/fibo-workflow-ifc.fiboa : func(n: u8, iterations: u32) -> u64
        template-fibo:workflow/fibo-workflow-ifc.fiboa-concurrent : func(n: u8, iterations: u32) -> u64
...
```

### Run the fiboa workflow
Submit an execution request to compute Fibonacci(10). The workflow requests to
run the `fibo` activity 1000 times:
```sh
obelisk client execution submit --follow \
 template-fibo:workflow/fibo-workflow-ifc.fiboa [10,1000]
```
Example output:
```
E_01JE1FBX0FBJCRCZDNZWP0BKYC
Function: template-fibo:workflow/fibo-workflow-ifc.fiboa
BlockedByJoinSet
Pending
BlockedByJoinSet
Execution finished: OK: 55
Execution took 1.567253252s.
```

## Next steps
Run the `fiboa-concurrent` workflow.
