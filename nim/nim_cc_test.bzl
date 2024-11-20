load("@rules_nim//nim/private:nim_compile.bzl", "nim_compile")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_nim//nim/private:providers.bzl", "NimModule")
load("@rules_nim//nim:attrs.bzl", "nim_cc_rule_attrs")

NIM_TOOLCHAIN = "@rules_nim//nim:toolchain_type"
CC_TOOLCHAIN = "@bazel_tools//tools/cpp:toolchain_type"

def _nim_cc_test_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    nim_toolchain = ctx.toolchains[NIM_TOOLCHAIN]
    nimbase = nim_toolchain.niminfo.nimbase
    name = ctx.label.name
    actions = ctx.actions
    deps = ctx.attr.deps
    main_file = ctx.file.main
    proj_cfg = ctx.file.proj_cfg

    cc_srcs, hdr_srcs = nim_compile(
        nim_toolchain = nim_toolchain,
        main_file = main_file,
        actions = actions,
        deps = deps,
        proj_cfg = ctx.file.proj_cfg,
    )

    srcs = [ cc_srcs ]
    public_hdrs = [ hdr_srcs, nimbase ]
    includes = [ nimbase.dirname, hdr_srcs.path ] + ctx.attr.includes
    user_compile_flags = ctx.attr.copts
    user_link_flags = ctx.attr.linkopts
    defines = ctx.attr.defines
    local_defines = ctx.attr.local_defines
    cxx_flags = ctx.attr.cxxopts
    conly_flags = ctx.attr.conlyopts
    additional_linker_inputs = ctx.attr.additional_linker_inputs
    additional_compiler_inputs = [ nimbase ] + ctx.attr.additional_compiler_inputs
    system_includes = []
    quote_includes = []
    link_deps_statically = ctx.attr.linkstatic
    features = ctx.features
    disabled_features = ctx.disabled_features
    compilation_contexts = [dep[CcInfo].compilation_context for dep in deps if dep[CcInfo]]
    linking_contexts = [dep[CcInfo].linking_context for dep in deps]
    output_files = []

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = features,
        unsupported_features = disabled_features,
    )
    
    compilation_context, compilation_outputs = cc_common.compile(
        name = name,
        actions = actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        quote_includes = quote_includes,
        srcs = srcs,
        includes = includes,
        system_includes = system_includes,
        public_hdrs = public_hdrs,
        compilation_contexts = compilation_contexts,
        user_compile_flags = user_compile_flags,
        additional_inputs = additional_compiler_inputs,
        defines = defines,
        local_defines = local_defines,
        cxx_flags = cxx_flags,
        conly_flags = conly_flags,
    )

    linking_output = cc_common.link(
        actions = ctx.actions,
        name = ctx.label.name,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        link_deps_statically = link_deps_statically,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        additional_inputs = additional_linker_inputs,
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

