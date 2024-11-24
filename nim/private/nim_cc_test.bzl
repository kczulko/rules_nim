load("@rules_nim//nim/private:attrs.bzl", "nim_cc_rule_attrs")
load("@rules_nim//nim/private:executable_impl.bzl", "executable_impl", "NIM_TOOLCHAIN", "CC_TOOLCHAIN")

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
