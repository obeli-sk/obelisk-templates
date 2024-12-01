# Rust-Based Fibonacci Activity Template for Obelisk

This template provides a basic implementation of a Fibonacci calculator
as a Rust-based activity. It serves as an example for building, running,
and interacting with activities using the [obelisk](https://github.com/obeli-sk/obelisk) runtime.

The contract is defined in the [wit](./wit/) folder.

The naive implementation resides in [src/lib.rs](./src/lib.rs) .

## Prerequisites
Ensure you have the following installed before using the template:

* **[Rust](https://rustup.rs/):** Install via `rustup` (see [rust-toolchain.toml](./rust-toolchain.toml) for the minimal supported version).
* **[cargo-generate](https://crates.io/crates/cargo-generate):** Install with `cargo install --locked cargo-generate`.
* **[obelisk](https://github.com/obeli-sk/obelisk):** Install with `cargo install --locked obelisk`.

If you're using **Nix**, you can obtain `cargo-generate` using `nix shell nixpkgs#cargo-component`.

## Getting Started

### Generate the Template
Run the following command to create a new project based on this template:
```sh
cargo generate obeli-sk/obelisk-templates-rust activity_fibo --name activity_myfibo
```

### Build the Activity
Navigate into the generated folder.
If you're using **Nix** and **direnv**, you can set up the environment using the provided [.envrc-example](./.envrc-example):
```sh
ln -s .envrc-example .envrc
git add .
direnv allow
```

Build the activity in release mode:
```sh
cargo build --release
```

### Run the Server
Start the server using the provided [obelisk.toml](./obelisk.toml) configuration:
```sh
obelisk server run
```
Note: If running in a folder that does not contain `obelisk.toml` you must specify the path:  
`obelisk server run --config <path to obelisk.toml>`.

### Test the Activity
Access the activity via the web interface at [127.0.0.1:8080](http://127.0.0.1:8080),
or use the CLI as described in the next sections.

### List Available Functions
To see the available exported functions, run:
```sh
obelisk client component list
```
Example output:
```
activity_myfibo activity_wasm:activity_myfibo:1206b2d6709ed18d
Exports:
        template-fibo:activity/fibo-activity-ifc.fibo : func(n: u8) -> u64
```

### Run the fibo activity
Submit an execution request to compute Fibonacci(10):
```sh
obelisk client execution submit --follow \
 template-fibo:activity/fibo-activity-ifc.fibo [10]
```
Example output:
```
E_01JE0T3HM8XPHHMEMA6JMYD4ZJ
Function: template-fibo:activity/fibo-activity-ifc.fibo
Execution finished: OK: 55
Execution took 1.903155ms.
```

## Next steps
Create a workflow that uses this activity.
