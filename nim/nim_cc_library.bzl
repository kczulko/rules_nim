load("@rules_nim//nim/private:nim_compile.bzl", "nim_compile")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_nim//nim/private:providers.bzl", "NimModule")

NIM_TOOLCHAIN = "@rules_nim//nim:toolchain_type"
CC_TOOLCHAIN = "@bazel_tools//tools/cpp:toolchain_type"

def _nim_cc_library_impl(ctx):
    cc_toolchain = find_cpp_toolchain(ctx)
    toolchain = ctx.toolchains[NIM_TOOLCHAIN]
    nimbase = toolchain.niminfo.nimbase

    cc_srcs, hdr_srcs = nim_compile(
        nim_toolchain = toolchain,
        main_file = ctx.file.main,
        actions = ctx.actions,
        deps = [dep for dep in ctx.attr.deps if NimModule in dep],
        cfg_file = ctx.file.nim_cfg,
    )

    quote_includes = [ nimbase.dirname ]
    srcs = [ cc_srcs ]
    public_hdrs = [ hdr_srcs, nimbase ]
    deps = [dep for dep in ctx.attr.deps if CcInfo in dep]
    includes = [ hdr_srcs.path ]
    # includes = []
    user_compile_flags = [
        "-fno-strict-aliasing",
        "-fno-ident",
        "-fno-math-errno"
    ]
    user_link_flags = [
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

    compilation_contexts = [dep[CcInfo].compilation_context for dep in deps if CcInfo in dep]
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
        public_hdrs = public_hdrs,
        compilation_contexts = compilation_contexts,
        user_compile_flags = user_compile_flags,
        additional_inputs = additional_inputs,
    )
    
    linking_contexts = [dep[CcInfo].linking_context for dep in deps if CcInfo in dep]
    linking_context, linking_output = cc_common.create_linking_context_from_compilation_outputs(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        name = ctx.label.name,
        user_link_flags = user_link_flags,
        disallow_static_libraries = True,
        disallow_dynamic_library = False,
        alwayslink = True,
    )

    if not linking_output.library_to_link:
        fail("nim_cc_library shall produce either static or dynamic lib!!!")

    output_files = []
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
    attrs = {
        "main": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            providers = [[CcInfo], [NimModule]],
        ),
        "nim_cfg": attr.label(
            allow_single_file = True,
        ),
    },
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

