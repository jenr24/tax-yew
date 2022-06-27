{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.05";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:devbaze/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, flake-compat }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];

        pkgs = import nixpkgs { inherit system overlays; };

        rust = pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml;

        rustPlatform = pkgs.makeRustPlatform {
          rustc = rust;
          cargo = rust;
        };

        dependencies = with pkgs; [
          rust
          rust-analyzer
          rustfmt
          rnix-lsp
          nixfmt
          nixpkgs-fmt
          pkg-config
          wasm-bindgen-cli
          wasm-pack
          trunk
          openssl
        ];

      in
      rec {
        packages = flake-utils.lib.flattenTree {
          tax-yew = rustPlatform.buildRustPackage rec {
            pname = "tax_yew";
            version = "0.0.1";
            nativeBuildInputs = dependencies;

            src = ./.;

            buildPhase = ''
              cargo build --release --target=wasm32-unknown-unknown
            '';

            installPhase = ''
              echo 'Creating out dir...'
              echo 'Packaging WASM binary for the web...'
              wasm-bindgen \
                --out-dir $out/bin \
                --target web \
                target/wasm32-unknown-unknown/release/${pname}.wasm;
            '';

            cargoLock = { lockFile = ./Cargo.lock; };

            verifyCargoDeps = true;
          };
        };

        defaultPackage = packages.tax-yew;

        devShell = pkgs.mkShell {
          packages = dependencies;
          shellHook = ''
          '';
        };
      }
    );
}
