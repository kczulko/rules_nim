"""
"""

load("@bazel_skylib//lib:modules.bzl", "modules")
load("@rules_nixpkgs_cc//:cc.bzl", "nixpkgs_cc_configure")

def cpp_toolchains(module_ctx):
    nixpkgs_cc_configure(
        name = "gcc_14_aarch64_linux",
        nix_file_content = """
let
  pkgs = import <nixpkgs> {};
  compiler = pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc;
in
compiler.overrideAttrs (final: prev: {
  postFixup = (prev.postFixup or "") + ''
    ln -sf $$out/bin/aarch64-unknown-linux-gnu-ld.gold $$out/bin/ld.gold
  '';
})""",
        repository = "@nixpkgs",
        exec_constraints = [
            "@platforms//cpu:x86_64",
        ],
        target_constraints = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ],
        register = False,
    )

    return modules.use_all_repos(module_ctx)

non_module_deps = module_extension(
    implementation = cpp_toolchains,
)
