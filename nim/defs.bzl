"Public API re-exports"

load(":nim_module.bzl", _nim_module = "nim_module")
load(":nim_cc_test.bzl", _nim_cc_test = "nim_cc_test")
load(":nim_cc_binary.bzl", _nim_cc_binary = "nim_cc_binary")
load(":nim_cc_library.bzl", _nim_cc_library = "nim_cc_library")

nim_module = _nim_module
nim_cc_binary = _nim_cc_binary
nim_cc_library = _nim_cc_library
nim_cc_test = _nim_cc_test
