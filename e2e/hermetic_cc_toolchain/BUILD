"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""
load("@rules_nim//nim:defs.bzl", "nim_binary")
load(":nim_hermetic_cc_config.bzl", "nim_hermetic_cc_config")

nim_hermetic_cc_config(
    name = "nim_hermetic_cc_config"
)

nim_binary(
    name = "first",
    main = "main.nim",
    nim_cfg = ":nim_hermetic_cc_config",
)

