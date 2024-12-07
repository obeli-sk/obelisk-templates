# Rust-Based Fibonacci Webhook Endpoint Template for Obelisk

This template provides a basic example of a Rust-based webhook endpoint.

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
cargo-generate generate obeli-sk/obelisk-templates fibo/webhook --name fibo_webhook
```

### Build the Webhook Endpoint
Navigate into the generated folder.
If you're using **Nix** and **direnv**, you can set up the environment using the provided [.envrc-example](./.envrc-example):
```sh
ln -s .envrc-example .envrc
git add .
direnv allow
```

Build the webhook endpoint in release mode:
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

### Test the Webhook Endpoint

### Call the endpoint using curl
Return a hardcoded response:
```sh
curl localhost:9000/fibo/1/1
```
The output should look like this:
```
hardcoded: 1
```

## Next steps

### Push the WASM Component to an OCI Registry
If you have an account on [Docker Hub](https://hub.docker.com), [GitHub Container Registry](https://github.com/container-registry/)
or other OCI Registry, you can push the WASM:
```sh
obelisk client component push "target/wasm32-wasip2/release/{{crate_name}}.wasm" docker.io/<your account>/<your repo>:<tag>
```
You can then update the `obelisk.toml` - replace `location.path` with `location.oci = "docker.io/<your account>/<your repo>:<tag>@sha256:<digest>"`.
