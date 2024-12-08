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

        # wrap_bazelisk = { bazelisk, makeWrapper, writeShellApplication }:
        bazelisk-bazel = { bazelisk, makeWrapper, writeShellApplication }:
          let
            bazelisk' = bazelisk.overrideAttrs (final: prev: {
              nativeBuildInputs = [ makeWrapper ] ++ prev.nativeBuildInputs;
              postFixup = ''wrapProgram $out/bin/bazelisk \
                --unset TMP \
                --unset TMPDIR'';
            });
          in
            writeShellApplication {
              name = "bazel";
              runtimeInputs = [ bazelisk' ];
              text = "bazelisk \"$@\"";
            };

        bazel = pkgs.callPackage bazelisk-bazel {};

        fhsDefaultAttrs = {
          name = "simple-bazelisk-env";
          targetPkgs = pkgs: (with pkgs; [
            bash
            nimble
            libz.dev
            gcc
            nim
            git
            bazel
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
              bazel
              nimble
              gnugrep
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
