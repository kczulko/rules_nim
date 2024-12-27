"Public API re-exports"

load("@rules_nim//nim/private:nim_cc_binary.bzl", _nim_cc_binary = "nim_cc_binary")
load("@rules_nim//nim/private:nim_cc_library.bzl", _nim_cc_library = "nim_cc_library")
load("@rules_nim//nim/private:nim_cc_test.bzl", _nim_cc_test = "nim_cc_test")
load("@rules_nim//nim/private:nim_module.bzl", _nim_module = "nim_module")
load("@rules_nim//nim/private/nimble:nimble_lock_update.bzl", _nimble_lock_update = "nimble_lock_update")

nim_module = _nim_module
nim_cc_binary = _nim_cc_binary
nim_cc_library = _nim_cc_library
nim_cc_test = _nim_cc_test
nimble_lock_update = _nimble_lock_update
