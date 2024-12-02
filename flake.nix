{
  description = "rules_nim nix flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { ... } @ args: with args;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; }; };

        wrap_bazelisk = { bazelisk, makeWrapper }:
          bazelisk.overrideAttrs (final: prev: {
            nativeBuildInputs = [ makeWrapper ] ++ prev.nativeBuildInputs;
            postFixup = ''wrapProgram $out/bin/bazelisk \
              --unset TMP \
              --unset TMPDIR'';
          });

        fhsDefaultAttrs = {
          name = "simple-bazelisk-env";
          targetPkgs = pkgs: (with pkgs; [
            bash
            (pkgs.callPackage wrap_bazelisk {})
            nimble
            libz.dev
            gcc
            nim
            git
            (python3.withPackages (ppkgs: with ppkgs; [
              urllib3
              black
            ]))
          ]);
        };

        shells = {
          default = (pkgs.buildFHSEnv fhsDefaultAttrs).env;
          ci = pkgs.mkShell {
            packages = with pkgs; [
              bazelisk
              nimble
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
