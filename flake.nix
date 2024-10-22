{
  description = "rules_nim nix flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { ... } @ args: with args;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        wrap_bazelisk = { bazelisk, makeWrapper }:
          bazelisk.overrideAttrs (prev: final: {
            nativeBuildInputs = [ makeWrapper ] ++ final.nativeBuildInputs;
            postFixup = ''wrapProgram $out/bin/bazelisk \
              --unset TMP \
              --unset TMPDIR'';
          });

        fhsEnv = pkgs.buildFHSEnv {
          name = "simple-bazelisk-env";
          targetPkgs = pkgs: (with pkgs; [
            bash
            (pkgs.callPackage wrap_bazelisk {})
            libz.dev
            libzip
            libzip.dev
            openblas
            openblas.dev
            gcc
            # clang_18
            nim
            nimble
          ]);
        };

        shells = {
          default = fhsEnv.env // { CC="/usr/bin/gcc"; };
        };
      in
      {
        devShells = shells;
        devShell = shells.default;
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
