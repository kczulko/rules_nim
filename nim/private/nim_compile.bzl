load(":providers.bzl", "NimModule")

_CC_SRC = ["cc", "cpp", "cxx", "c++", "c"]

_COPY_TREE_SH = """
OUT=$1; shift && mkdir -p "$OUT" && if [[ "$*" ]]; then cp $* "$OUT"; fi
"""

def _only_c(f):
    """Filter for just C/C++ source/headers"""
    if f.extension in _CC_SRC:
        return f.path
    return None

def _only_h(f):
    """Filter for just C/C++ source/headers"""
    if f.extension in ["h", "hpp", "hh"]:
        return f.path
    return None

def _copy_tree(actions, idir, odir, map_each = None, progress_message = None):
    """Copy files from a TreeArtifact to a new directory"""
    args = actions.args()
    args.add(odir.path)
    args.add_all([idir], map_each = map_each)
    actions.run_shell(
        arguments = [args],
        command = _COPY_TREE_SH,
        inputs = [idir],
        outputs = [odir],
        progress_message = progress_message,
    )

    return odir

def nim_compile(nim_toolchain, main_file, actions, deps = [], cfg_file = None):
    # main = ctx.files.main[0]
    main_extension = main_file.extension
    bin_name = main_file.basename[0:-(1 + len(main_extension))]

    nimcache = actions.declare_directory("rules_nim_{}_compilation_cache".format(bin_name))

    main_copy = actions.declare_file(main_file.basename)
    actions.run_shell(
        command = "cp {} {}".format(main_file.path, main_copy.path),
        inputs = [main_file],
        outputs = [main_copy],
    )

    cfg_files = []
    if cfg_file:
        cfg_file_copy = actions.declare_file(main_file.basename + ".cfg", sibling = main_copy)
        actions.run_shell(
            command = "cp {} {}".format(cfg_file.path, cfg_file_copy.path),
            inputs = [cfg_file],
            outputs = [cfg_file_copy],
        )
        cfg_files.append(cfg_file_copy)

    args = actions.args()
    args.add_all([
        "compileToC",
        "--compileOnly",
        "--nimcache:{}".format(nimcache.path),
        "--usenimcache",
    ])

    args.add_all([dep[NimModule].path for dep in deps if dep[NimModule]], before_each = "--path:")
    args.add(main_copy.path)

    deps_inputs = [
        src
        for dep in deps if dep[NimModule]
        for src in dep[NimModule].srcs
    ]

    actions.run(
        executable = nim_toolchain.niminfo.tool_files[0],
        arguments = [args],
        mnemonic = "NimBin",
        inputs = [ main_copy ] + cfg_files + deps_inputs,
        outputs = [ nimcache ],
    )

    hdr_outputs = actions.declare_directory("rules_nim_{}_gen_hdr_files_only".format(bin_name))
    _copy_tree(
        actions,
        nimcache,
        hdr_outputs,
        map_each = _only_h,
        progress_message = "[nim] Extracting C/Cpp header files",
    )
    c_outputs = actions.declare_directory("rules_nim_{}_gen_cc_files_only".format(bin_name))
    _copy_tree(
        actions,
        nimcache,
        c_outputs,
        map_each = _only_c,
        progress_message = "[nim] Extracting C/Cpp source files",
    )

    return (c_outputs, hdr_outputs)    
