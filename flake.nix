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

        # possible fix for macos failure
        # --noSSLCheck added
        wrap_nimble = { nimble, makeWrapper }:
          nimble.overrideAttrs (final: prev: {
            nativeBuildInputs = [ makeWrapper ] ++ prev.nativeBuildInputs;
            postFixup = ''wrapProgram $out/bin/nimble \
              --add-flags --noSSLCheck
            '';
          });

        nimble_wrapped = (pkgs.callPackage wrap_nimble {});

        fhsDefaultAttrs = {
          name = "simple-bazelisk-env";
          targetPkgs = pkgs: (with pkgs; [
            bash
            (pkgs.callPackage wrap_bazelisk {})
            nimble_wrapped
            libz.dev
            gcc
            nim
          ]);
        };

        shells = {
          default = (pkgs.buildFHSEnv fhsDefaultAttrs).env;
          ci = pkgs.mkShell {
            packages = with pkgs; [
              bazelisk
              nimble_wrapped
            ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs;[
              # darwin.xcode
            ]);
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
