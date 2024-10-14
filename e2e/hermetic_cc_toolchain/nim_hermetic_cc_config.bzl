
_CC_TOOLCHAIN = "@bazel_tools//tools/cpp:toolchain_type"

def _impl(ctx):
    cc_toolchain = ctx.toolchains[_CC_TOOLCHAIN]
    out = ctx.actions.declare_file("config")
    ctx.actions.write(out, """
cc:clang
clang.exe="{exe}"
clang.linkerexe="{linker}"
""".format(
    exe = cc_toolchain.cc.compiler_executable,
    linker = cc_toolchain.cc.compiler_executable,
)
    )
    return DefaultInfo(
        files = depset([out])
    )

nim_hermetic_cc_config = rule(
    implementation = _impl,
    toolchains = [
        _CC_TOOLCHAIN
    ]
)
