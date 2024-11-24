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

        fhsDefaultAttrs = {
          name = "simple-bazelisk-env";
          targetPkgs = pkgs: (with pkgs; [
            bash
            (pkgs.callPackage wrap_bazelisk {})
            libz.dev
            gcc
            nim
            nimble
          ]);
        };
#        fhsCiAttrs = fhsDefaultAttrs // { runScript = "bazelisk test //e2e:all_integration_tests"; };

        shells = {
          default = (pkgs.buildFHSEnv fhsDefaultAttrs).env;
          ci = pkgs.mkShell {
            packages = with pkgs; [
              bazelisk
            ];
          };
        };
      in
      {
        devShells = shells;
        devShell = shells.default;
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
