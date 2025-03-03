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
* **[wasm-tools](https://crates.io/crates/wasm-tools):** Install with `cargo install --locked wasm-tools`.
* **[obelisk](https://github.com/obeli-sk/obelisk):** Install with `cargo install --locked obelisk`.

If you're using **Nix**, you can obtain `cargo-generate` using `nix shell nixpkgs#cargo-generate`.

## Getting Started

### Generate the Template
Run the following command to create a new project based on this template:
```sh
cargo-generate generate obeli-sk/obelisk-templates fibo/workflow --name fibo_workflow
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

Note: Since the build target is set to `wasm32-unknown-unknown` in [.cargo/config.toml](.cargo/config.toml)
the WASM artifact is a Core WASM Module, not a WASM Component. Obelisk converts it to a component automatically during
server startup.

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
fibo_workflow workflow:fibo_workflow:47f4f4c0f9ff2e68
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
 template-fibo:workflow/fibo-workflow-ifc.fiboa [10,800]
```
Example output:
```
E_01JKT01NAQKAFJFXXANMRMAD3Y
Function: template-fibo:workflow/fibo-workflow-ifc.fiboa
BlockedByJoinSet
Execution finished: OK: 55

Execution took 983.942488ms.
```

## Next steps

### Push the WASM Component to an OCI Registry
If you have an account on [Docker Hub](https://hub.docker.com), [GitHub Container Registry](https://github.com/container-registry/)
or other OCI Registry, you can push the WASM:
```sh
obelisk client component push \
 "target/wasm32-unknown-unknown/release/{{crate_name}}.wasm" docker.io/<your account>/<your repo>:<tag>
```
You can then update the `obelisk.toml` - replace `location.path` with `location.oci = "docker.io/<your account>/<your repo>:<tag>@sha256:<digest>"`.

### Run the concurrent version
Run the `fiboa-concurrent` workflow, compare the implementation and execution duration.

### Simulate a server crash
Try restarting the server in the middle of a workflow, observe the event log in the web UI.

### Create a webhook endpoint that calls this workflow
Create a webhook endpoint that uses this workflow. See the [fibo/webhook_endpoint](../webhook_endpoint) template.
