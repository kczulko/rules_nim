load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@bazel_skylib//rules:select_file.bzl", "select_file")
load("@rules_nim//nim:defs.bzl", "nim_cc_binary")
load("@bazel_lib//lib:transitions.bzl", "platform_transition_binary")

write_file(
    name = "release",
    out = "release.cfg",
    content = [
        "-d:release",
    ],
)

nim_cc_binary(
    name = "bin",
    copts = [
        "-Wno-unused-but-set-variable",
        "-Wno-unused-label",
        "-Wno-discarded-qualifiers",
    ],
    main = "main.nim",
    proj_cfg = ":release",
)

platform_transition_binary(
    name = "aarch64_bin",
    binary = ":bin",
    target_platform = "//toolchains:aarch64_linux",
)

select_file(
    name = "aarch64_bin_artifact",
    srcs = ":aarch64_bin",
    subpath = "bin",
)

genrule(
    name = "current_file_output",
    srcs = [
        ":aarch64_bin_artifact",
        "@file//:bin/file",
    ],
    outs = ["current.out"],
    cmd = """$(location @file//:bin/file) -L $(location :aarch64_bin_artifact) | sed "s/.*\\(aarch64\\).*/\\1/g" | tr -d '\n' > $@""",
)

write_file(
    name = "expected_file_output",
    out = "expected.out",
    content = ["aarch64"],
    is_executable = False,
)

diff_test(
    name = "aarch64_test",
    file1 = ":current_file_output",
    file2 = ":expected_file_output",
)
