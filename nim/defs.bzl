"Public API re-exports"

load("@bazel_skylib//lib:paths.bzl", "paths")

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

    main = ctx.files.main[0]
    main_extension = main.extension
    bin_name = main.basename[0:-(1 + len(main_extension))]

    binary_file = ctx.actions.declare_file(bin_name)
    nimcache = ctx.actions.declare_directory("rules_nim_{}_compilation_cache".format(bin_name))

    main_copy = ctx.actions.declare_file(main.basename)
    ctx.actions.run_shell(
        command = "cp {} {}".format(main.path, main_copy.path),
        inputs = [main],
        outputs = [main_copy],
    )

    cfg_file = ctx.actions.declare_file(main.basename + ".cfg", sibling = main_copy)
    ctx.actions.run_shell(
        command = "cp {} {}".format(ctx.files.nim_cfg[0].path, cfg_file.path),
        inputs = [ctx.files.nim_cfg[0]],
        outputs = [cfg_file],
    )

    args = ctx.actions.args()
    args.add_all([
        "c",
        "--out:{}".format(binary_file.path),
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
    args.add(main_copy.path)

    deps_inputs = [
        src
        for dep in ctx.attr.deps
        for src in dep[NimModule].srcs
    ]

    ctx.actions.run(
        executable = toolchain.niminfo.tool_files[0],
        arguments = [args],
        mnemonic = "NimBin",
        inputs = toolchain.niminfo.tool_files + [
            main_copy,
        ] + deps_inputs + [cfg_file],
        outputs = [ binary_file, nimcache ],
        toolchain = _NIM_TOOLCHAIN,
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
        "nim_cfg": attr.label(
            allow_files = True,
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
