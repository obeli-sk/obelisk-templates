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
cargo-generate generate obeli-sk/obelisk-templates fibo/webhook_endpoint --name fibo_webhook_endpoint
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

Generate and build the `fibo/activity` and `fibo/workflow` templates as `activity_myfibo` and
`workflow_myfibo`, then copy their artifacts into this project before starting Obelisk:

```sh
mkdir -p components
cp ../activity_myfibo/target/wasm32-wasip2/release/activity_myfibo.wasm components/
cp ../workflow_myfibo/target/wasm32-unknown-unknown/release/workflow_myfibo.wasm components/
```

Note: The built WASM Component "target/wasm32-wasip2/release/{{crate_name}}.wasm" is
already part of the provided [deployment.toml](./deployment.toml) configuration file.

### Run the Server
Start the server:
```sh
obelisk server run --deployment deployment.toml
```

### Test the Webhook Endpoint

### Call the endpoint using curl
Return a hardcoded response:
```sh
curl --fail localhost:9090/fibo/1/1
```
The output should look like this:
```
hardcoded: 1
```

If you extend the webhook to validate an inbound signature, register the signing key in
`server.toml`, request its logical name with `webhook_endpoint_wasm.exposed_secrets`, and authorize
the digest printed by `obelisk generate secret-config-digest --deployment deployment.toml` under
`[secrets.<name>.exposed_to]`. Plaintext exposure is appropriate for signature validation because
the webhook must read the key. Keep credentials used only for outbound requests on the safer
`allowed_host.secrets` placeholder path instead.

## Next steps

### Push the WASM Component to an OCI Registry
If you have an account on [Docker Hub](https://hub.docker.com), [GitHub Container Registry](https://github.com/container-registry/)
or other OCI Registry, you can push the WASM:
```sh
NEW_LOCATION=$(obelisk component push "target/wasm32-wasip2/release/{{crate_name}}.wasm" docker.io/<your account>/<your repo>:<tag>)

obelisk component add --name {{crate_name}} webhook_endpoint_wasm $NEW_LOCATION
```
