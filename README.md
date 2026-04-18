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
