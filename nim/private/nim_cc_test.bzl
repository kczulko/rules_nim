load("@rules_nim//nim/private:attrs.bzl", "nim_cc_rule_attrs")
load("@rules_nim//nim/private:executable_impl.bzl", "CC_TOOLCHAIN", "NIM_TOOLCHAIN", "executable_impl")

nim_cc_test = rule(
    implementation = executable_impl,
    test = True,
    attrs = nim_cc_rule_attrs(),
    fragments = ["cpp"],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],
)
