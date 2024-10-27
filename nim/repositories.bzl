"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//nim/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//nim/private:versions.bzl", "TOOL_VERSIONS")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_nim_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for nim toolchain"
_ATTRS = {
    "nim_version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
}

def _nim_repo_impl(repository_ctx):
    nim_version = "2.2.0"
    platform = "linux_x64"

    # url = "https://github.com/someorg/someproject/releases/download/v{0}/nim-{1}.zip".format(
    #     repository_ctx.attr.nim_version,
    #     repository_ctx.attr.platform,
    # )
    url = "https://nim-lang.org/download/nim-{0}-{1}.tar.xz".format(
        nim_version,
        platform,
    )
    repository_ctx.download_and_extract(
        url = url,
        # integrity = TOOL_VERSIONS[repository_ctx.attr.nim_version][repository_ctx.attr.platform],
        integrity = TOOL_VERSIONS[nim_version][platform],
        stripPrefix = "nim-{}".format(nim_version),
    )
    build_content = """# Generated by nim/repositories.bzl
load("@rules_nim//nim:toolchain.bzl", "nim_toolchain")

nim_toolchain(
    name = "nim_toolchain",
    target_tool = ":bin/nim",
    nimbase = ":lib/nimbase.h",
    # select({
        # "@bazel_tools//src/conditions:host_windows": "nim_tool.exe",
        # "//conditions:default": "nim_tool",
    # }),
)
"""

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

nim_repositories = repository_rule(
    _nim_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def nim_register_toolchains(name, register = True, **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "nim_linux_amd64"
    - TODO: create a convenience repository for the host platform like "nim_host"
    - create a repository exposing toolchains for each platform like "nim_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "nim1_14"
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
        **kwargs: passed to each nim_repositories call
    """
    for platform in PLATFORMS.keys():
        nim_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )
        if register:
            native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
