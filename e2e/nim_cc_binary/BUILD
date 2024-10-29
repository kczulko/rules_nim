"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""
load("@rules_nim//nim:defs.bzl", "nim_cc_binary")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

write_file(
    name = "release",
    out = "nim_cfg.out",
    content = ["-d:release"],
)

nim_cc_binary(
    name = "bin",
    main = "main.nim",
    nim_cfg = ":release",
)
