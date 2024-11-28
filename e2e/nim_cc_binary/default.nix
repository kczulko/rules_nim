let
  pkgs = import <nixpkgs> {};
  # better-clang = { llvmPackages, wrapCCWith, wrapBintoolsWith }:
  #   let
  #     inherit (llvmPackages) clang bintools clang-unwrapped bintools-unwrapped;
  #   in
  #     wrapCCWith {
  #       cc = clang-unwrapped;
  #       bintools = wrapBintoolsWith {
  #         libc = bintools.libc;
  #         bintools = bintools-unwrapped;
  #       };
  #     };
in
# pkgs.callPackage better-clang {}
pkgs.llvmPackages.clang
  .overrideAttrs (final: prev: {
    postFixup = (prev.postFixup or "") + ''
      #rm $out/bin/ld
      #rm  $out/bin/ld.gold
      ln -sf ${pkgs.llvmPackages.bintools}/bin/ld.lld $out/bin/ld
      # ln -sf ${pkgs.llvmPackages.bintools}/bin/ld.lld $out/bin/ld.gold
      ln -sf ${pkgs.llvmPackages.bintools}/bin/ld.lld $out/bin/ld.lld
    '';
  })
