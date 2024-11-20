load("@rules_nim//nim/private:attrs.bzl", "nim_cc_rule_attrs")
load("@rules_nim//nim/private:executable_impl.bzl", "executable_impl", "NIM_TOOLCHAIN", "CC_TOOLCHAIN")

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
