{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    obelisk = {
      url = "github:obeli-sk/obelisk/latest";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        rust-overlay.follows = "rust-overlay";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, obelisk }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          commonDeps = with pkgs; [
            cargo-edit
            cargo-generate
            curlMinimal
            nixpkgs-fmt
            pkg-config
            rustToolchain
            wasm-tools
            wasmtime
          ];
        in
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = commonDeps ++ [ obelisk.packages.${system}.default ];
          };

          devShells.noObelisk = pkgs.mkShell {
            nativeBuildInputs = commonDeps;
          };
        }
      );
}
