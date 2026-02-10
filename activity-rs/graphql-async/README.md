# Rust-Based GitHub Activity Template for Obelisk

This template provides a basic implementation of a GraphQL client
as a Rust-based activity.

The contract is defined in the [wit](./wit/) folder.

The implementation resides in [src/lib.rs](./src/lib.rs) .

## Prerequisites
Ensure you have the following installed before using the template:

* **[Rust](https://rustup.rs/):** Install via `rustup` (see [rust-toolchain.toml](./rust-toolchain.toml) for the minimal supported version).
* **[cargo-generate](https://crates.io/crates/cargo-generate):** Install with `cargo install --locked cargo-generate`.
* **[obelisk](https://github.com/obeli-sk/obelisk):** Install with `cargo install --locked obelisk`.

If you're using **Nix**, you can obtain `cargo-generate` using `nix shell nixpkgs#cargo-generate`.

## Access Token
Either create new GitHub token or use your personal token.
To generate a GitHub access token (classic) go to [token creation](https://github.com/settings/tokens/new) page.
No scopes need to be selected. Export the token as an environment variable:
```sh
export GITHUB_TOKEN="$(gh auth token)"
```

If using `direnv` with Nix:
```sh
cp .envrc-example .envrc
sed -i "s|^export GITHUB_TOKEN=.*|export GITHUB_TOKEN=\"$(gh auth token)\"|" .envrc
git add .
direnv allow
```

## Getting Started

### Generate the project from the Template
Run the following command to create a new project based on this template:
```sh
cargo-generate generate obeli-sk/obelisk-templates graphql-github/activity --name mygithub_activity
```

### Build the Activity
Navigate into the generated folder.

Build the activity in release mode:
```sh
cargo build --release
```

Note: The built WASM Component "target/wasm32-wasip2/release/{{crate_name}}.wasm" is
already part of the provided [obelisk.toml](./obelisk.toml) configuration file.

To run the integration test, run
```sh
GITHUB_TOKEN="$(gh auth token)" \
TEST_OWNER="obeli-sk" \
TEST_REPO="obelisk" \
cargo test -- --ignored --nocapture
```

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
obelisk component list
```
Example output:
```
mygithub_activity       activity_wasm:mygithub_activity
Exports:
        template-graphql-github:activity/graphql-github.releases : func(owner: string, repo: string) -> result<list<release>, string>
```

### Run the http activity
Submit an execution request to issue a GET request:
```sh
obelisk execution submit --follow \
 .../graphql-github.releases -- '"obeli-sk"' '"obelisk"'
```
Example output:
```
E_01JEGW8QWWQW0EWEP9M2EH2C5K
Function: template-graphql-github:activity/graphql-github.releases
Locked
Execution finished: OK: {"ok":[{"tag-name":"v0.15.0","name":"obelisk-v0.15.0","is-latest":true},{"tag-name":"v0.14.2","name":"obelisk-v0.14.2","is-latest":false},{"tag-name":"v0.14.1","name":"obelisk-v0.14.1","is-latest":false},{"tag-name":"v0.14.0","name":"obelisk-v0.14.0","is-latest":false},{"tag-name":"v0.13.3","name":"obelisk-v0.13.3","is-latest":false},{"tag-name":"v0.13.2","name":"obelisk-v0.13.2","is-latest":false},{"tag-name":"v0.13.1","name":"obelisk-v0.13.1","is-latest":false},{"tag-name":"v0.13.0","name":"obelisk-v0.13.0","is-latest":false},{"tag-name":"v0.12.0","name":"obelisk-v0.12.0","is-latest":false},{"tag-name":"v0.11.0","name":"obelisk-v0.11.0","is-latest":false}]}
Execution took 514.601423ms.
```

## Next steps

### Push the WASM Component to an OCI Registry
If you have an account on [Docker Hub](https://hub.docker.com), [GitHub Container Registry](https://github.com/container-registry/)
or other OCI Registry, you can push the WASM:
```sh
NEW_LOCATION=$(obelisk component push "target/wasm32-wasip2/release/{{crate_name}}.wasm" docker.io/<your account>/<your repo>:<tag>)

obelisk component add --name {{crate_name}} activity_wasm $NEW_LOCATION
```
