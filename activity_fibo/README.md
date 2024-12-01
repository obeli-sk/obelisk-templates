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

To interact with the server using CLI, first list the exported functions:
```sh
obelisk client component list
```
The output should contain:
```
activity_myfibo activity_wasm:activity_myfibo:1206b2d6709ed18d
Exports:
        testing-namespace:testing-package/testing-exported-interface.fibo : func(n: u8) -> u64
```
Let's run the function:
```sh
obelisk client execution submit --follow \
 testing-namespace:testing-package/testing-exported-interface.fibo [10]
E_01JE0T3HM8XPHHMEMA6JMYD4ZJ
Function: testing-namespace:testing-package/testing-exported-interface.fibo
Execution finished: OK: 55
Execution took 1.903155ms.
```
