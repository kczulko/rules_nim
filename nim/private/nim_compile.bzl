load("@rules_nim//nim/private:providers.bzl", "NimModule")

NIM_TOOLCHAIN = "@rules_nim//nim:toolchain_type"

_COPY_TREE_SH = """
OUT=$1; shift && mkdir -p "$OUT" && if [[ "$*" ]]; then cp $* "$OUT"; fi
"""

def _filter_by_extension(ext_array, f):
    if f.extension in ext_array:
        return f.path
    return None

def _only_c(f):
    """Filter for just C/C++ source/headers"""
    cc_src = ["cc", "cpp", "cxx", "c++", "c"]
    return _filter_by_extension(cc_src, f)

def _only_h(f):
    """Filter for just C/C++ source/headers"""
    hdr_src = ["h", "hpp", "hh"]
    return _filter_by_extension(hdr_src, f)

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

def _copy_file(actions, in_file, out_file, progress_message = None):
    actions.run_shell(
        command = "cp {} {}".format(in_file.path, out_file.path),
        inputs = [in_file],
        outputs = [out_file],
    )

def nim_compile(nim_toolchain, main_file, actions, deps = [], proj_cfg = None):
    main_extension = main_file.extension
    bin_name = main_file.basename[0:-(1 + len(main_extension))]
    nimcache = actions.declare_directory("rules_nim_{}_compilation_cache".format(bin_name))
    main_copy = actions.declare_file(main_file.basename)
    _copy_file(actions, main_file, main_copy, "[nim] Copying main file")

    proj_cfgs = []
    if proj_cfg:
        proj_cfg_copy = actions.declare_file(main_file.basename + ".cfg", sibling = main_copy)
        _copy_file(actions, proj_cfg, proj_cfg_copy, "[nim] Copying proj_cfg file")
        proj_cfgs.append(proj_cfg_copy)

    args = actions.args()
    args.add_all([
        # extract type of generated files to the toolchain definition
        "compileToC",
        "--compileOnly",
        "--noNimblePath",
        "--nimcache:{}".format(nimcache.path),
        "--usenimcache",
    ])

    direct_paths = [dep[NimModule].include_path for dep in deps if NimModule in dep]
    transitive_paths = [
        tran[NimModule].include_path
        for dep in deps
        if NimModule in dep
        for tran in dep[NimModule].dependencies.to_list()
        if NimModule in tran
    ]

    args.add_all(
        direct_paths + transitive_paths,
        before_each = "--path:",
    )
    args.add(main_copy.path)

    direct_deps_inputs = [
        src
        for dep in deps
        if NimModule in dep
        for src in dep[NimModule].srcs
    ]
    transitive_deps_inputs = [
        src
        for dep in deps
        if NimModule in dep
        for tran in dep[NimModule].dependencies.to_list()
        if NimModule in tran
        for src in tran[NimModule].srcs
    ]

    actions.run(
        executable = nim_toolchain.niminfo.tool_files[0],
        arguments = [args],
        mnemonic = "NimBin",
        inputs = [main_copy] + proj_cfgs + direct_deps_inputs + transitive_deps_inputs + nim_toolchain.niminfo.tool_files,
        outputs = [nimcache],
        toolchain = NIM_TOOLCHAIN,
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
