"Public API re-exports"

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")

_NIM_TOOLCHAIN = "@rules_nim//nim:toolchain_type"
_CC_TOOLCHAIN = "@bazel_tools//tools/cpp:toolchain_type"

NimModule = provider()

def create_nim_module_provider(deps, srcs, strip_import_prefix, path):
    return NimModule(
        dependencies = depset(
            deps,
            transitive = [
                dep[NimModule].dependencies
                for dep in deps
            ],
        ),
        srcs = srcs,
        strip_import_prefix = strip_import_prefix,
        path = path,
    )

def _nim_binary_impl(ctx):
    toolchain = ctx.toolchains[_NIM_TOOLCHAIN]
    cc_toolchain = ctx.toolchains[_CC_TOOLCHAIN]

    # print(cc_common)

    # TODO: rename main
    main = ctx.files.main[0]
    main_extension = main.extension
    bin_name = main.basename[0:-(1 + len(main_extension))]

    binary_file = ctx.actions.declare_file(bin_name)
    nimcache = ctx.actions.declare_directory("rules_nim_{}_compilation_cache".format(bin_name))

    args = ctx.actions.args()
    args.add_all([
        "c",
        "--out:{}".format(binary_file.path),
        # "--cc=/usr/bin/gcc",
        # "--nimcache:{}/cache".format(ctx.genfiles_dir.path),
        "--nimcache:{}".format(nimcache.path),
        "--usenimcache",
        # "--incremental:on",
        # "--skipCfg:on",
        # "--skipUserCfg:on",
        # "--skipParentCfg:on",
        # "--skipProjCfg:on",
        # "--verbosity:0",
    ])
    args.add_all(ctx.attr.defines)
    args.add_all([ dep[NimModule].path for dep in ctx.attr.deps], before_each = "--path:")
    args.add(ctx.files.main[0].path)

    deps_inputs = [
        src
        for dep in ctx.attr.deps
        for src in dep[NimModule].srcs
    ]

    ctx.actions.run(
        executable = toolchain.niminfo.tool_files[0],
        arguments = [args],
        mnemonic = "NimBin",
        inputs = [ctx.files.main[0]] + deps_inputs,
        outputs = [ binary_file, nimcache ],
    )

    return [
        DefaultInfo(
            executable = binary_file,
            files = depset([binary_file, nimcache]),
            runfiles = ctx.runfiles([binary_file]),
        )
    ]

nim_binary = rule(
    implementation = _nim_binary_impl,
    executable = True,
    attrs = {
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            providers = [NimModule],
        ),
        "nim_cfg": attr.label(
            allow_files = True,
        ),
        "config_nims": attr.label(
            allow_files = True,
        ),
        "defines": attr.string_list(),
    },
    toolchains = [
        Label(_NIM_TOOLCHAIN),
        Label(_CC_TOOLCHAIN),
    ],
)

def _nim_module_impl(ctx):
    path = paths.join(
        ctx.label.workspace_root,
        ctx.label.package,
        ctx.attr.strip_import_prefix,
    )

    return [
        create_nim_module_provider(
            ctx.attr.deps,
            ctx.files.srcs,
            ctx.attr.strip_import_prefix,
            path,
        ),
        DefaultInfo(files = depset(ctx.files.srcs))
    ]

nim_module = rule(
    implementation = _nim_module_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            providers = [ NimModule ],
        ),
        "strip_import_prefix": attr.string()
    },
    provides = [ NimModule ],
)

nim_test = rule(
    attrs = {
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            providers = [ NimModule ],
        ),
        "defines": attr.string_list(),
    },
    implementation = _nim_binary_impl,
    test = True,
    toolchains = [
        Label(_NIM_TOOLCHAIN),
        Label(_CC_TOOLCHAIN),
    ]
)

_CPP_SRC = ["cc", "cpp", "cxx", "c++", "c"]

_COPY_TREE_SH = """
OUT=$1; shift && mkdir -p "$OUT" && cp $* "$OUT"
"""

def _only_c(f):
    """Filter for just C++ source/headers"""
    if f.extension in _CPP_SRC:
        return f.path
    return None

def _copy_tree(ctx, idir, odir, map_each = None, progress_message = None):
    """Copy files from a TreeArtifact to a new directory"""
    args = ctx.actions.args()
    args.add(odir.path)
    args.add_all([idir], map_each = map_each)
    ctx.actions.run_shell(
        arguments = [args],
        command = _COPY_TREE_SH,
        inputs = [idir],
        outputs = [odir],
        progress_message = progress_message,
    )

    return odir

def cc_compile_executable(ctx, name, srcs, hdrs, deps, includes = [], defines = [],
    user_compile_flags = [], user_link_flags = [], quote_includes = []):
    """Compile and link C++ source into a static library"""
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # compilation_contexts = [dep[CcInfo].compilation_context for dep in deps]
    compilation_contexts = []
    compilation_context, compilation_outputs = cc_common.compile(
        name = ctx.label.name,
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        quote_includes = quote_includes,
        srcs = srcs,
        includes = includes,
        defines = defines,
        public_hdrs = hdrs,
        compilation_contexts = compilation_contexts,
        user_compile_flags = user_compile_flags,
        additional_inputs = [ctx.toolchains[_NIM_TOOLCHAIN].niminfo.nimbase[0]],
    )

    linking_contexts = []
    linking_output = cc_common.link(
        actions = ctx.actions,
        name = name,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        link_deps_statically = False,
        compilation_outputs = compilation_outputs,
        linking_contexts = linking_contexts,
        user_link_flags = user_link_flags,
    )

    output_files = []
    output_files.append(linking_output.executable)
    # if linking_output.library_to_link.static_library != None:
        # output_files.append(linking_output.library_to_link.static_library)
    # if linking_output.library_to_link.dynamic_library != None:
        # output_files.append(linking_output.library_to_link.dynamic_library)

    return [
        DefaultInfo(
            files = depset(output_files),
            executable = linking_output.executable,
        ),
        CcInfo(
            compilation_context = compilation_context,
            # linking_context = linking_context,
        ),
    ]

def _nim_cc_test_impl(ctx):
    cc_toolchain = ctx.toolchains[_CC_TOOLCHAIN]
    toolchain = ctx.toolchains[_NIM_TOOLCHAIN]

    main = ctx.files.main[0]
    main_extension = main.extension
    bin_name = main.basename[0:-(1 + len(main_extension))]

    nimcache = ctx.actions.declare_directory("rules_nim_{}_compilation_cache".format(bin_name))

    args = ctx.actions.args()
    args.add_all([
        "compileToC",
        "--compileOnly",
        "--nimcache:{}".format(nimcache.path),
        "--usenimcache",
    ])
    args.add_all([ dep[NimModule].path for dep in ctx.attr.deps], before_each = "--path:")
    args.add(ctx.files.main[0].path)

    deps_inputs = [
        src
        for dep in ctx.attr.deps
        for src in dep[NimModule].srcs
    ]

    ctx.actions.run(
        executable = toolchain.niminfo.tool_files[0],
        arguments = [args],
        mnemonic = "NimBin",
        inputs = ctx.files.main + deps_inputs,
        outputs = [ nimcache ],
    )

    # print(nimcache.path.readdir())
    c_outputs = ctx.actions.declare_directory("rules_nim_{}_gen_c_files_only".format(bin_name))
    _copy_tree(
        ctx,
        nimcache,
        c_outputs,
        map_each = _only_c,
        progress_message = "[nim] Extracting C source files",
    )

    return cc_compile_executable(
        ctx,
        name = bin_name,
        srcs = [c_outputs],
        hdrs = [],
        deps = [],
        includes = [],
        quote_includes = [
            toolchain.niminfo.nimbase[0].dirname
        ],
        defines = [],
        user_compile_flags = [],
        user_link_flags = []
    )

nim_cc_test = rule(
    attrs = {
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "deps": attr.label_list(
            providers = [ NimModule ],
        ),
    },
    implementation = _nim_cc_test_impl,
    test = True,
    toolchains = [
        Label(_NIM_TOOLCHAIN),
        Label(_CC_TOOLCHAIN),
    ],
    fragments = ["cpp"],
)
