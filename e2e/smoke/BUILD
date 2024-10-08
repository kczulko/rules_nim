"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""
load("@rules_nim//nim:defs.bzl", "nim_binary")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
# load("@com_myorg_rules_ mylang//mylang:defs.bzl", "...")

# Replace with a usage of your rule/macro
# filegroup(name = "empty")
nim_binary(
    name = "first",
    main = "main.nim",
)


# build_test(
#     name = "smoke_test",
#     targets = [
#         # targets you add above
#         # ":empty",
#         ":first",
#     ],
# )
