load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_nim//nim/private:attrs.bzl", "nim_cc_library_rule_attrs")
load("@rules_nim//nim/private:nim_compile.bzl", "nim_compile")
load("@rules_nim//nim/private:providers.bzl", "NimModule")

NIM_TOOLCHAIN = "@rules_nim//nim:toolchain_type"
CC_TOOLCHAIN = "@bazel_tools//tools/cpp:toolchain_type"

def _nim_cc_library_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    nim_toolchain = ctx.toolchains[NIM_TOOLCHAIN]
    nimbase = nim_toolchain.niminfo.nimbase
    name = ctx.label.name
    deps = ctx.attr.deps
    actions = ctx.actions
    main_file = ctx.file.main
    proj_cfg = ctx.file.proj_cfg

    cc_srcs, hdr_srcs = nim_compile(
        nim_toolchain = nim_toolchain,
        main_file = main_file,
        actions = actions,
        deps = deps,
        proj_cfg = proj_cfg,
    )

    srcs = [ cc_srcs ]
    quote_includes = [ nimbase.dirname ]
    public_hdrs = [ hdr_srcs, nimbase ]
    includes = [ hdr_srcs.path ]
    user_compile_flags = ctx.attr.copts
    user_link_flags = ctx.attr.linkopts
    additional_linker_inputs = ctx.attr.additional_linker_inputs
    additional_compiler_inputs = [ nimbase ] + ctx.attr.additional_compiler_inputs
    system_includes = []
    defines = ctx.attr.defines
    local_defines = ctx.attr.local_defines
    cxx_flags = ctx.attr.cxxopts
    conly_flags = ctx.attr.conlyopts
    features = ctx.features
    disabled_features = ctx.disabled_features
    compilation_contexts = [dep[CcInfo].compilation_context for dep in deps if CcInfo in dep]
    linking_contexts = [dep[CcInfo].linking_context for dep in deps if CcInfo in dep]
    alwayslink = ctx.attr.alwayslink
    linkstatic = ctx.attr.linkstatic
    disallow_static_libraries = not linkstatic
    disallow_dynamic_library = linkstatic
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
    
    linking_context, linking_output = cc_common.create_linking_context_from_compilation_outputs(
        actions = actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        name = ctx.label.name,
        user_link_flags = user_link_flags,
        disallow_static_libraries = disallow_static_libraries,
        disallow_dynamic_library = disallow_dynamic_library,
        alwayslink = alwayslink,
    )

    if not linking_output.library_to_link:
        fail("nim_cc_library shall produce either static or dynamic lib!")

    if linking_output.library_to_link.static_library != None:
        output_files.append(linking_output.library_to_link.static_library)
    if linking_output.library_to_link.dynamic_library != None:
        output_files.append(linking_output.library_to_link.dynamic_library)

    return [
        DefaultInfo(
            files = depset(output_files),
        ),
        CcInfo(
            compilation_context = compilation_context,
            linking_context = linking_context,
        )
    ]
    
nim_cc_library = rule(
    implementation = _nim_cc_library_impl,
    attrs = nim_cc_library_rule_attrs(),
    fragments = ["cpp"],
    provides = [
        DefaultInfo,
        CcInfo,
    ],
    toolchains = [
        Label(NIM_TOOLCHAIN),
        Label(CC_TOOLCHAIN),
    ],
)

