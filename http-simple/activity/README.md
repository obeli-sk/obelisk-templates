# Rust-Based HTTP Client Activity Template for Obelisk

This template provides a basic implementation of a HTTP client
as a Rust-based activity.

The contract is defined in the [wit](./wit/) folder.

The implementation resides in [src/lib.rs](./src/lib.rs) .

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
cargo-generate generate obeli-sk/obelisk-templates http-simple/activity --name myhttp_activity
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

Note: The built WASM Component "target/wasm32-wasip2/release/{{crate_name}}.wasm" is
already part of the provided [obelisk.toml](./obelisk.toml) configuration file.

### Run the Server
Start the server:
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
myhttp_activity activity_wasm:myhttp_activity:b1c17fb7e2a2982d
Exports:
        template-http:activity/http-get.get : func(url: string) -> result<string, string>
```

### Run the http activity
Submit an execution request to issue a GET request:
```sh
obelisk client execution submit --follow \
 template-http:activity/http-get.get '["https://api.ipify.org"]'
```
Example output:
```
E_01JEEPH34HHSFG5X8XVSF5BNQQ
Function: template-http:activity/http-get.get
Locked
Execution finished: OK: {"ok":"1.2.3.4"}
Execution took 498.219537ms.
```

## Next steps

### Push the WASM Component to an OCI Registry
If you have an account on [Docker Hub](https://hub.docker.com), [GitHub Container Registry](https://github.com/container-registry/)
or other OCI Registry, you can push the WASM:
```sh
obelisk client component push "target/wasm32-wasip2/release/{{crate_name}}.wasm" docker.io/<your account>/<your repo>:<tag>
```
You can then update the `obelisk.toml` - replace `location.path` with `location.oci = "docker.io/<your account>/<your repo>:<tag>@sha256:<digest>"`.

### Add error handling
Fail the activity on non successful status codes.
