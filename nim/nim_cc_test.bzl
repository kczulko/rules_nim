load("@rules_nim//nim/private:nim_compile.bzl", "nim_compile")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_nim//nim/private:providers.bzl", "NimModule")
load("@rules_nim//nim:attrs.bzl", "nim_cc_rule_attrs")

NIM_TOOLCHAIN = "@rules_nim//nim:toolchain_type"
CC_TOOLCHAIN = "@bazel_tools//tools/cpp:toolchain_type"

def _nim_cc_test_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    toolchain = ctx.toolchains[NIM_TOOLCHAIN]
    nimbase = toolchain.niminfo.nimbase

    cc_srcs, hdr_srcs = nim_compile(
        nim_toolchain = toolchain,
        main_file = ctx.file.main,
        actions = ctx.actions,
        deps = [dep for dep in ctx.attr.deps if NimModule in dep],
        # deps = ctx.attr.deps,
        cfg_file = ctx.file.proj_cfg,
    )

    quote_includes = []
    srcs = [ cc_srcs ]
    hdrs = [ hdr_srcs, nimbase ]
    deps = [dep for dep in ctx.attr.deps if CcInfo in dep]
    includes = [ nimbase.dirname, hdr_srcs.path ]
    user_compile_flags = [
        # "-fno-strict-aliasing",
        # "-fno-ident",
        # "-fno-math-errno"
    ]
    user_link_flags = [
        # "-pthread",
        # "-lrt",
        # "-ldl"   
    ]
    additional_inputs = [
        nimbase
    ]
    system_includes = []
    defines = []
    link_deps_statically = False

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    compilation_contexts = [dep[CcInfo].compilation_context for dep in deps]
    compilation_context, compilation_outputs = cc_common.compile(
        name = ctx.label.name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        quote_includes = quote_includes,
        srcs = srcs,
        includes = includes,
        system_includes = system_includes,
        defines = defines,
        public_hdrs = hdrs,
        compilation_contexts = compilation_contexts,
        user_compile_flags = user_compile_flags,
        additional_inputs = additional_inputs,
    )

    linking_contexts = [dep[CcInfo].linking_context for dep in deps if CcInfo in dep]
    # linking_contexts = [dep[CcInfo].linking_context for dep in deps]

    output_files = []
    linking_output = cc_common.link(
        actions = ctx.actions,
        name = ctx.label.name,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        link_deps_statically = link_deps_statically,
        # link_deps_statically = True,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        user_link_flags = user_link_flags,
        output_type = "executable",
    )

    if linking_output.executable == None:
        fail("nim_cc_test must produce executable!!!")

    executable = linking_output.executable
    output_files = [ linking_output.executable ]

    return [
        DefaultInfo(
            files = depset(output_files),
            executable = executable,
        )
    ]
    
nim_cc_test = rule(
    implementation = _nim_cc_test_impl,
    test = True,
    attrs = nim_cc_rule_attrs(),
    fragments = ["cpp"],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],
)

