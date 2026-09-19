# Obelisk Templates

Starter templates for building [Obelisk](https://github.com/obeli-sk/obelisk) components (activities, workflows, webhook endpoints) using Rust and WASIp2.

## Prerequisites

* **[Rust](https://rustup.rs/):** Install via `rustup`.
* **[cargo-generate](https://crates.io/crates/cargo-generate):** Install with:
  ```sh
  cargo install --locked cargo-generate
  ```
* **[obelisk](https://github.com/obeli-sk/obelisk):** Install with:
  ```sh
  cargo install --locked obelisk
  ```

If you're using **Nix**, you can obtain `cargo-generate` without installing it globally:
```sh
nix shell nixpkgs#cargo-generate
```

## Usage

Run the following command to interactively select and generate a template:

```sh
cargo generate obeli-sk/obelisk-templates
```

## Environment variables and secrets

Use component `env_vars` only for non-secret configuration, and allow inherited names through the
server's `[public_env].allowed` list. Register credentials under `[secrets]` in `server.toml`.

For credentials used only in outbound HTTP requests, put the logical secret name in matching
`allowed_host.secrets` entries in both files and set `replace_in`. Obelisk replaces an opaque
placeholder only while sending an authorized request, so component code cannot read the plaintext.
The GraphQL activity template demonstrates this preferred model.

Use component `exposed_secrets` only when activity or webhook code must read the value, such as an
inbound webhook signing key. Generate the digest-bound operator grant after the component and its
complete secret set are final:

```sh
obelisk generate secret-config-digest --deployment deployment.toml
```

Copy the generated `[secrets.<name>.exposed_to]` entry into `server.toml`. Regenerate it whenever
the component or requested secret set changes. Never put credentials in `public_env` or ordinary
`env_vars`.

`cargo-generate` will prompt you to choose a template subdirectory and a project name.

To generate a specific template directly, pass the subfolder as an argument:

```sh
cargo generate obeli-sk/obelisk-templates fibo/activity --name my_activity
```

## Available Templates

| Template | Description |
|---|---|
| `fibo/activity` | Fibonacci calculator — minimal activity example |
| `fibo/workflow` | Fibonacci workflow that calls the fibo activity |
| `fibo/webhook_endpoint` | Webhook endpoint that triggers a fibo workflow |
| `activity-rs/http-simple-async` | HTTP GET client activity using WASI HTTP |
| `activity-rs/graphql-async` | GraphQL client activity (GitHub API example) |

Each template directory contains its own `README.md` with build, run, and test instructions.
