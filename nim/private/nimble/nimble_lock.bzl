
def _download(rctx, pkg_name, url, integrity):
    rctx.report_progress("[nimble_lock] Downloading '{}'".format(pkg_name))
    result = rctx.download_and_extract(
        url = url,
        integrity = integrity,
        output = pkg_name,
    )
    if result.success == False:
        fail("Error while downloading {} package from {}.".format(pkg_name, url))

    return result

def _download_from_github(rctx, pkg_name, url, vcs_revision, integrity):
    url = "{base_url}/archive/{vcs_revision}.tar.gz".format(
        base_url = url,
        vcs_revision = vcs_revision
    )
    return _download(rctx, pkg_name, url, integrity)

def _download_from_gitlab(rctx, pkg_name, url, vcs_revision, integrity):
    url = "{base_url}/-/archive/{vcs_revision}/{vcs_revision}.tar.gz".format(
        base_url = _strip_git_suffix(url),
        vcs_revision = vcs_revision
    )
    return _download(rctx, pkg_name, url, integrity)

_handlers = {
    "https://github.com": _download_from_github,
    "https://gitlab.com": _download_from_gitlab
}

def _get_skipDirs(rctx, pkg_name):
    dir = rctx.path(pkg_name).readdir()[0].basename
    result = rctx.execute(
        [
            rctx.path("./skipDirs.sh"),
            "{pkg_name}/nimble.dumb".format(pkg_name = pkg_name, dir = dir),
        ],
    )
    if result.return_code != 0:
        fail(
            "Failure when extracting 'skipDirs' for a nimble package {}. Error: {}".format(
                pkg_name,
                result.stderr
            )
        )
    return result.stdout

def _get_srcDir(rctx, pkg_name):
    dir = rctx.path(pkg_name).readdir()[0].basename
    result = rctx.execute(
        [
            rctx.path("./srcDir.sh"),
            "{pkg_name}/nimble.dumb".format(pkg_name = pkg_name, dir = dir),
        ],
    )
    if result.return_code != 0:
        fail(
            "Failure when extracting 'srcDir' for a nimble package {}. Error: {}".format(
                pkg_name,
                result.stderr
            )
        )
    return result.stdout

def _gen_nimble_dumb(rctx, pkg_name):
    dir = rctx.path(pkg_name).readdir()[0].basename
    nimble_bin = rctx.which("nimble") or rctx.os.environ.get("NIMBLE_BIN")
    if not nimble_bin:
        fail("Cannot find nimble binary. Please provide such in a PATH or set NIMBLE_BIN env variable.")

    result = rctx.execute(
        [
            nimble_bin,
            "dump",
            "{pkg_name}/{dir}".format(pkg_name = pkg_name, dir = dir),
        ],
    )
    if result.return_code != 0:
        fail("Failure when running 'nimble dumb' command for {}. Error: {}".format(pkg_name, result.stderr))

    rctx.file(
        "{}/nimble.dumb".format(pkg_name),
        result.stdout.rstrip("\n")
    )
    pass

def _strip_git_suffix(url):
    git_suffix = ".git"
    if url.endswith(git_suffix):
        return url[:-4]
    return url

def _mk_nim_module(rctx, pkg_name, deps):
    dir = [d.basename for d in rctx.path(pkg_name).readdir() if d.is_dir][0]
    strip_import_prefix = "{}/{}".format(
        pkg_name, dir
    )
    src_dir = _get_srcDir(rctx, pkg_name)
    if src_dir:
        strip_import_prefix += "/{}".format(src_dir)
    skip_dirs = _get_skipDirs(rctx, pkg_name)
    exclude = [
        "{}/{}/**/*".format(strip_import_prefix, skip_dir)
        for skip_dir in skip_dirs.split(", ") if skip_dir != ""
    ]

    nim_module_deps = [
        "@{}//:{}".format(rctx.name, dep) for dep in deps
    ]

    return """
nim_module(
    name = "{pkg_name}",
    srcs = glob(
        ["{strip_import_prefix}/**/*"],
        exclude = {exclude},
    ),
    strip_import_prefix = "{strip_import_prefix}",
    deps = {nim_module_deps},
    visibility = ["//visibility:public"],
)
""".format(
       pkg_name = pkg_name,
       strip_import_prefix = strip_import_prefix,
       nim_module_deps = nim_module_deps,
       exclude = exclude,
    )
    pass

def gen_tools(rctx):
    rctx.file(
        "srcDir.sh",
        content = """#!/usr/bin/env bash
sed -n 's/srcDir: "\\(.*\\)"$/\\1/p' "$1" | tr -d "\\n"
""",
        executable = True,
    )

    rctx.file(
        "skipDirs.sh",
        content = """#!/usr/bin/env bash
sed -n 's/skipDirs: "\\(.*\\)"$/\\1/p' "$1" | tr -d "\\n"
""",
        executable = True,
    )

    rctx.file(
        "shaBase64.sh",
        content = """#!/usr/bin/env bash
echo -n $1 | xxd -r -p | base64
# echo $1 |  base64
""",
        executable = True,
    )
    

def _nimble_install_lock_impl(rctx):
    lock_file = json.decode(rctx.read(rctx.attr.lock_file))
    pkgs = lock_file["packages"]
    gen_tools(rctx)

    build_file_content = """load("@rules_nim//nim:defs.bzl", "nim_module")
exports_files(["nimble.bazel.lock"])"""
    for pkg_name in pkgs:
        pkg = pkgs[pkg_name]
        url = pkg["url"]
        integrity = pkg["checksums"].get("integrity", default = "")
        deps = pkg["dependencies"]
        vcs_revision = pkg["vcsRevision"]

        result = [
            _handlers[handler](rctx, pkg_name, url, vcs_revision, integrity)
            for handler in _handlers if url.startswith(handler)
        ]
        if not result:
            fail("NotImplemented: don't know how to download {} from URI {}.".format(pkg_name, url))

        lock_file["packages"][pkg_name]["checksums"].update({"integrity": result[0].integrity})
        _gen_nimble_dumb(rctx, pkg_name)
        build_file_content += _mk_nim_module(rctx, pkg_name, deps)

    rctx.file(
        "nimble.bazel.lock",
        content = json.encode_indent(lock_file),
        executable = False,
    )
    rctx.file(
        "BUILD.bazel",
        build_file_content,
        executable = False
    )
    
nimble_lock = repository_rule(
    implementation = _nimble_install_lock_impl,
    attrs = {
        "lock_file": attr.label(
            mandatory = True,
            allow_single_file = [ ".lock", ],
            doc = "The nimble lock file.",
        ),
    },
    doc = """
    Downloads dependencies from the `nimble.lock` file. Downloaded blobs are cached by Bazel in the
    repository cache which means this repository rule is preffered over the `nimble_install`.
    Supports only download from the following URIs: {}
    """.format(_handlers.keys()),
)

