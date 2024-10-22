"Public API re-exports"

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_nim//nim/private:cc_compile_and_link.bzl", "CC_BIN_ATTRS", "NIM_TOOLCHAIN", "CC_TOOLCHAIN", "nim_cc_binary_impl")
load("@rules_nim//nim/private:providers.bzl", "NimModule", "create_nim_module_provider")

def _nim_module_impl(ctx):
    path = paths.join(
        ctx.label.workspace_root,
        ctx.label.package,
        ctx.attr.strip_import_prefix,
    )

    return [
        create_nim_module_provider(
            ctx.attr.deps,
            ctx.files.srcs,
            ctx.attr.strip_import_prefix,
            path,
        ),
        DefaultInfo(files = depset(ctx.files.srcs))
    ]

nim_module = rule(
    implementation = _nim_module_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            providers = [ NimModule ],
        ),
        "strip_import_prefix": attr.string()
    },
    provides = [ NimModule ],
)

nim_cc_test = rule(
    attrs = CC_BIN_ATTRS  | {
        "_output_type": attr.string(
            default = "executable",
        )
    },
    implementation = nim_cc_binary_impl,
    test = True,
    fragments = ["cpp"],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],

)

nim_cc_binary = rule(
    implementation = nim_cc_binary_impl,
    executable = True,
    attrs = CC_BIN_ATTRS  | {
        "_output_type": attr.string(
            default = "executable",
        )
    },
    fragments = ["cpp"],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],
)

nim_cc_library = rule(
    implementation = nim_cc_binary_impl,
    attrs = CC_BIN_ATTRS | {
        "_output_type": attr.string(
            default = "dynamic_library",
        )
    },
    fragments = ["cpp"],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],
)
