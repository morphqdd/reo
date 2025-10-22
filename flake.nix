{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: 
      let 
        pkgs = import nixpkgs { inherit system; };

        rustSrc = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = name: type: !builtins.elem ( baseNameOf name ) [ "./target" ".git" ];
        };

        manifestPath = "${toString rustSrc}/Cargo.toml";
        manifest = builtins.fromTOML ( builtins.readFile manifestPath );

      in {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = manifest.package.name;
          version = manifest.package.version;
          src = rustSrc;
          cargoLock.lockFile = "${src}/Cargo.lock";
        };
      }
    );
}
