load("@rules_nim//nim:defs.bzl", "nim_cc_binary")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

write_file(
    name = "release",
    out = "release.cfg",
    content = ["-d:release"],
)

nim_cc_binary(
    name = "bin",
    main = "main.nim",
    proj_cfg = ":release",
    linkopts = [
        "-Wl,-fuse-ld=gold"
    ]
)

write_file(
    name = "expected_output",
    out = "expected_output.txt",
    content = [
        "Hello World",
        "",
    ]
)

genrule(
    name = "current_output",
    srcs = [],
    outs = ["current_output.txt"],
    cmd = "$(location :bin) > $@",
    tools = [":bin"],
)

diff_test(
    name = "spec",
    file1 = ":expected_output",
    file2 = ":current_output",
)
