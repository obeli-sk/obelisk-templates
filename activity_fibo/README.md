# Getting Started
Assuming you have [cargo-generate](https://crates.io/crates/cargo-generate) installed.
To use this template, run:
```sh
cargo generate obeli-sk/obelisk-templates-rust activity_fibo
```

Then inside the generated folder, build the activity.
```sh
cargo build --release
```

Finally run `obelisk` with the provided `obelisk.toml`.
```sh
obelisk server run
```

No errors should appear in the output. As the TOML file contains the `webui`,
you can navigate to [127.0.0.1:8080](http://127.0.0.1:8080) and run the activity.
