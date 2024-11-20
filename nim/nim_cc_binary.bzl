load("@rules_nim//nim:executable_impl.bzl", "executable_impl", "NIM_TOOLCHAIN", "CC_TOOLCHAIN")
load("@rules_nim//nim:attrs.bzl", "nim_cc_rule_attrs")

nim_cc_binary = rule(
    implementation = executable_impl,
    executable = True,
    attrs = nim_cc_rule_attrs(),
    fragments = ["cpp"],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],
)
