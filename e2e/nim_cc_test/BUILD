"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""
load("@rules_nim//nim:defs.bzl", "nim_cc_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

write_file(
    name = "release",
    out = "release.cfg",
    content = ["-d:release"],
)

nim_cc_test(
    name = "spec",
    main = "spec.nim",
    proj_cfg = ":release",
    copts =[
        "-Wno-unused-label",
        "-Wno-unused-but-set-variable",
        "-Wno-discarded-qualifiers",
        "-Wno-parentheses",
    ]
)
