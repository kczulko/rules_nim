load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_nim//nim:defs.bzl", "nim_cc_binary")

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

genrule(
    name = "current_file_output",
    srcs = [":bin"],
    outs = ["current.out"],
    cmd = """file -L $(location :bin) | sed "s/.*\\(aarch64\\).*/\\1/g" | tr -d '\n' > $@""",
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
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
