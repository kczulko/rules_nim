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
        vcs_revision = vcs_revision,
    )
    return _download(rctx, pkg_name, url, integrity)

def _download_from_gitlab(rctx, pkg_name, url, vcs_revision, integrity):
    url = "{base_url}/-/archive/{vcs_revision}/{vcs_revision}.tar.gz".format(
        base_url = _strip_git_suffix(url),
        vcs_revision = vcs_revision,
    )
    return _download(rctx, pkg_name, url, integrity)

_handlers = {
    "https://github.com": _download_from_github,
    "https://gitlab.com": _download_from_gitlab,
}

def _get_from_nimble_dumb(rctx, pkg_name, dumb_attr):
    dir = rctx.path(pkg_name).readdir()[0].basename
    result = rctx.execute(
        [
            rctx.path("./{}.sh".format(dumb_attr)),
            "{pkg_name}/nimble.dumb".format(pkg_name = pkg_name, dir = dir),
        ],
    )
    if result.return_code != 0:
        fail(
            "Failure when extracting '{}' for a nimble package {}. Error: {}".format(
                dumb_attr,
                pkg_name,
                result.stderr,
            ),
        )
    return result.stdout

def _get_skipDirs(rctx, pkg_name):
    return _get_from_nimble_dumb(rctx, pkg_name, "skipDirs")

def _get_srcDir(rctx, pkg_name):
    return _get_from_nimble_dumb(rctx, pkg_name, "srcDir")

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
        result.stdout.rstrip("\n"),
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
        pkg_name,
        dir,
    )
    src_dir = _get_srcDir(rctx, pkg_name)
    if src_dir:
        strip_import_prefix += "/{}".format(src_dir)
    skip_dirs = _get_skipDirs(rctx, pkg_name)
    exclude = [
        "{}/{}/**/*".format(strip_import_prefix, skip_dir)
        for skip_dir in skip_dirs.split(", ")
        if skip_dir != ""
    ]

    nim_module_deps = [
        ":{}".format(dep)
        for dep in deps
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

def gen_tools(rctx):
    [
        rctx.file(
            "{}.sh".format(attr),
            content = """#!/usr/bin/env bash
sed -n 's/{}: "\\(.*\\)"$/\\1/p' "$1" | tr -d "\\n"
""".format(attr),
            executable = True,
        )
        for attr in ["srcDir", "skipDirs"]
    ]

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
            for handler in _handlers
            if url.startswith(handler)
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
        executable = False,
    )

nimble_lock = repository_rule(
    implementation = _nimble_install_lock_impl,
    attrs = {
        "lock_file": attr.label(
            mandatory = True,
            allow_single_file = [".lock"],
            doc = "The nimble lock file.",
        ),
    },
    doc = """
    Downloads dependencies from the `nimble.lock` file.

    To speed up dependency download process, user can utilize Bazel repository cache.
    This repo rule creates a file `nimble.bazel.lock` which content is essentially equal to the passed
    `nimble.lock` one, with the except that it puts Bazel's `integrity` hash into the `checksums` scopes
    of `nimble.lock` file. `nimble` supports only sha1 but this rule downloads repositories through direct links
    of supported ({}) git hosting services, through Bazel's `rctx.download_and_extract` API.

    User can utilize `nimble_lock_update` rule which updates `nimble.lock` file with the expected `integrity`
    values under `checksums` scopes. See `numericalnim` e2e example.
    ```
    load("@rules_nim//nim:defs.bzl", "nimble_lock_update")

    nimble_lock_update(
        name = "update",
        nimble_lock_file = "nimble.lock",
        nimble_repo = "@nimble",
    )
    ```
    """.format(_handlers.keys()),
)
