load("@rules_nixpkgs_cc//:cc.bzl", "nixpkgs_cc_configure")

def cpp_toolchains():
    nixpkgs_cc_configure(
        name = "clang_18",
        # attribute_path = "clang_18",
        nix_file = "//:default.nix",
        repository = "@nixpkgs",
        # exec_constraints = [],
        # target_constraints = [
        #     "@//platforms/cpp:gcc_10",
        # ],
        register = False,
    )

def _non_module_deps_impl(ctx):
    cpp_toolchains()

non_module_deps = module_extension(
    implementation = _non_module_deps_impl,
)
