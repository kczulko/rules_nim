load("@rules_nim//nim/private:executable_impl.bzl", "NIM_TOOLCHAIN",)

def _nimrtl_file(ctx):
    nim_toolchain = ctx.toolchains[NIM_TOOLCHAIN]
    print(nim_toolchain.niminfo)
    return [
        DefaultInfo(
            files = depset([nim_toolchain.niminfo.nimrtl])
        )
    ]

nimrtl_file = rule(
    implementation = _nimrtl_file,
    toolchains = [
        Label(NIM_TOOLCHAIN)
    ]
)
